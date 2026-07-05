import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../constants/app_colors.dart';
import '../widgets/modern_bottom_sheet.dart';
import '../errors/exceptions.dart';

/// Centralises picking (camera or gallery) and uploading profile photos
/// to Supabase Storage, and persisting the public URL in Firestore.
/// Shared by the doctor sign-up flow and the profile screen.
class ImageUploadService {
  ImageUploadService._();

  static final ImagePicker _picker = ImagePicker();

  /// Guards against a second pick being launched while one is still active.
  static bool _picking = false;

  // ── Error mapping (belongs here, not in ViewModel) ────────────────────────

  /// Converts any exception into an [ImageUploadException] with a
  /// human-readable message. This is the single place where raw errors
  /// are translated to user-facing copy.
  static ImageUploadException _mapException(Object e, String tag) {
    final raw = e.toString().toLowerCase();
    debugPrint('[$tag] _mapException — raw error: $e');

    if (raw.contains('socket') ||
        raw.contains('network') ||
        raw.contains('host lookup') ||
        raw.contains('failed host') ||
        raw.contains('connection refused') ||
        raw.contains('clientexception')) {
      return const ImageUploadException(
          'Could not connect to the image storage server. Please verify your internet connection, or make sure the storage URL in the configuration (.env) is active and correct.');
    }
    if (raw.contains('permission') ||
        raw.contains('denied') ||
        raw.contains('forbidden') ||
        raw.contains('row-level security') ||
        raw.contains('violates') ||
        raw.contains('403')) {
      return const ImageUploadException(
          'Upload permission denied. Please contact support if this persists.');
    }
    if (raw.contains('bucket not found') ||
        raw.contains('404') ||
        raw.contains('not found')) {
      return const ImageUploadException(
          'Storage bucket not found. Please contact support.');
    }
    if (raw.contains('too large') ||
        raw.contains('payload') ||
        raw.contains('413')) {
      return const ImageUploadException(
          'This photo is too large. Please pick an image under 5 MB.');
    }
    if (raw.contains('not configured') || raw.contains('placeholder')) {
      return const ImageUploadException(
          'Cloud storage is not set up yet. Please contact support.');
    }
    return const ImageUploadException(
        'Something went wrong while uploading your photo. Please try again.');
  }

  // ── Picker ────────────────────────────────────────────────────────────────

  /// Shows a camera/gallery chooser sheet, then returns the picked file — or
  /// null if the user cancels or a picker error occurs. Never throws.
  static Future<File?> pickWithChooser(BuildContext context) async {
    debugPrint('[ImagePicker] pickWithChooser() — showing chooser sheet');
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ModernBottomSheet(
        title: 'Add a photo',
        subtitle: 'Choose how to add your profile photo',
        icon: Icons.add_a_photo_rounded,
        child: Row(
          children: [
            Expanded(
              child: _PhotoSourceTile(
                icon: Icons.photo_camera_rounded,
                label: 'Camera',
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PhotoSourceTile(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      debugPrint('[ImagePicker] chooser dismissed — no source selected');
      return null;
    }
    debugPrint('[ImagePicker] source selected: $source');

    if (_picking) {
      debugPrint('[ImagePicker] aborted — a pick is already in progress');
      return null;
    }
    _picking = true;

    try {
      debugPrint('[ImagePicker] calling pickImage(source: $source)…');
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (picked == null) {
        debugPrint('[ImagePicker] user cancelled the picker (null result)');
        return null;
      }

      final file = File(picked.path);
      final exists = await file.exists();
      final length = exists ? await file.length() : 0;
      debugPrint('[ImagePicker] picked: path="${picked.path}" '
          'exists=$exists bytes=$length');
      if (!exists || length == 0) {
        debugPrint('[ImagePicker] picked file missing/empty — discarding');
        return null;
      }
      return file;
    } on PlatformException catch (e, st) {
      debugPrint('[ImagePicker] PlatformException: code="${e.code}" '
          'message="${e.message}" details="${e.details}"');
      debugPrint('$st');
      return null;
    } catch (e, st) {
      debugPrint('[ImagePicker] unexpected error: $e');
      debugPrint('$st');
      return null;
    } finally {
      _picking = false;
      debugPrint('[ImagePicker] pick finished — guard released');
    }
  }

  // ── Upload core ───────────────────────────────────────────────────────────

  /// Uploads [file] to the Supabase storage bucket at `{uid}.jpg` (overwriting
  /// any previous photo) and returns its public URL with a cache-buster.
  /// Throws [ImageUploadException] with a user-friendly message on failure.
  static Future<String> uploadDoctorPhoto(String uid, File file) async {
    debugPrint('[PhotoUpload] start — uid=$uid file="${file.path}"');

    if (!SupabaseConfig.isConfigured) {
      debugPrint('[PhotoUpload] ABORT — Supabase not configured');
      throw const ImageUploadException(
          'Cloud storage is not set up yet. Please contact support.');
    }

    final String path = '$uid.jpg';
    try {
      final bucket = Supabase.instance.client.storage.from(
        SupabaseConfig.photoBucket,
      );
      final int bytes = await file.length();
      debugPrint('[PhotoUpload] uploading $bytes bytes → '
          'bucket="${SupabaseConfig.photoBucket}" path="$path"');

      await bucket.upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );

      final url = bucket.getPublicUrl(path);
      final publicUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[PhotoUpload] success — publicUrl=$publicUrl');
      return publicUrl;
    } on StorageException catch (e, st) {
      debugPrint('[PhotoUpload] StorageException — '
          'statusCode=${e.statusCode} error="${e.error}" message="${e.message}"');
      debugPrint('$st');
      throw _mapException(e, 'PhotoUpload');
    } catch (e, st) {
      debugPrint('[PhotoUpload] unexpected error: $e');
      debugPrint('$st');
      throw _mapException(e, 'PhotoUpload');
    }
  }

  // ── Firestore persistence ─────────────────────────────────────────────────

  /// Uploads [file] and writes the URL to `doctors/{uid}.imageUrl`.
  static Future<String> setDoctorPhoto(String uid, File file) async {
    debugPrint('[DoctorPhoto] setDoctorPhoto — uid=$uid');
    final url = await uploadDoctorPhoto(uid, file);
    debugPrint('[DoctorPhoto] writing imageUrl to Firestore: doctors/$uid');
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .set({'imageUrl': url}, SetOptions(merge: true));
      debugPrint('[DoctorPhoto] doctors/$uid.imageUrl saved ✓');
    } catch (e, st) {
      debugPrint('[DoctorPhoto] Firestore write failed: $e');
      debugPrint('$st');
      throw _mapException(e, 'DoctorPhoto');
    }
    return url;
  }

  /// Uploads [file] and writes the URL to `users/{uid}.imageUrl`.
  /// Used for patient profile photos.
  static Future<String> setUserPhoto(String uid, File file) async {
    debugPrint('[PatientPhoto] setUserPhoto — uid=$uid');
    final int bytes = await file.length();
    debugPrint('[PatientPhoto] file: path="${file.path}" size=$bytes bytes');

    if (!SupabaseConfig.isConfigured) {
      debugPrint('[PatientPhoto] ABORT — Supabase not configured');
      throw const ImageUploadException(
          'Cloud storage is not set up yet. Please contact support.');
    }

    final url = await uploadDoctorPhoto(uid, file);
    debugPrint('[PatientPhoto] upload success — url=$url');
    debugPrint('[PatientPhoto] writing imageUrl to Firestore: users/$uid');
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'imageUrl': url}, SetOptions(merge: true));
      debugPrint('[PatientPhoto] users/$uid.imageUrl saved ✓');
    } catch (e, st) {
      debugPrint('[PatientPhoto] Firestore write failed: $e');
      debugPrint('$st');
      throw _mapException(e, 'PatientPhoto');
    }
    return url;
  }
}

/// A tappable source card (Camera / Gallery) used in the photo chooser sheet.
class _PhotoSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: Column(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLighter,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
