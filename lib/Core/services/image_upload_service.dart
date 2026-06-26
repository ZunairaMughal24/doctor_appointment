import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../constants/app_colors.dart';
import '../widgets/modern_bottom_sheet.dart';

/// Centralises picking (camera or gallery) and uploading doctor profile photos
/// to Supabase Storage, and persisting the public URL on the doctor record in
/// Firestore. Shared by the doctor sign-up flow and the profile screen.
class ImageUploadService {
  ImageUploadService._();

  static final ImagePicker _picker = ImagePicker();

  /// Guards against a second pick being launched while one is still active.
  /// A rapid double-tap (or re-opening the chooser before the OS picker
  /// returns) otherwise throws `PlatformException(already_active)` — the most
  /// common image_picker crash, and the one that halts the debugger on tap.
  static bool _picking = false;

  /// Shows a camera/gallery chooser sheet, then returns the picked file — or
  /// null if the user cancels (either the chooser or the picker) or an error
  /// occurs. Never throws: any picker error is logged in detail and surfaced as
  /// a null result so the caller can simply ignore it.
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
      // The actual platform error — code is the useful part:
      //   already_active        → a pick was already running (now guarded)
      //   photo_access_denied   → gallery permission denied
      //   camera_access_denied  → camera permission denied
      //   no_available_camera   → device/emulator has no camera
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

  /// Uploads [file] to the Supabase storage bucket at `{uid}.jpg` (overwriting
  /// any previous photo) and returns its public URL. A cache-buster query param
  /// is appended so a re-uploaded photo refreshes immediately. Logs every step
  /// so the exact failure is visible in the console.
  static Future<String> uploadDoctorPhoto(String uid, File file) async {
    debugPrint('[PhotoUpload] start — uid=$uid file="${file.path}"');

    if (!SupabaseConfig.isConfigured) {
      debugPrint('[PhotoUpload] ABORT — Supabase not configured '
          '(url/anonKey still placeholders in supabase_config.dart)');
      throw StateError(
          'Supabase is not configured — set SUPABASE_URL / SUPABASE_ANON_KEY in .env');
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
      debugPrint('[PhotoUpload] success — publicUrl=$url');
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } on StorageException catch (e) {
      // The Supabase-side error — the most useful part of the log:
      //   statusCode 404 → bucket "${SupabaseConfig.photoBucket}" doesn't exist
      //   statusCode 403 / "row-level security" → missing insert/update policy
      //   "Bucket not found" → name mismatch (check it matches the dashboard)
      debugPrint('[PhotoUpload] StorageException — statusCode=${e.statusCode} '
          'error="${e.error}" message="${e.message}"');
      throw Exception('Image upload failed: ${e.message}');
    } catch (e, st) {
      debugPrint('[PhotoUpload] unexpected error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  /// Uploads [file] and merges the resulting URL onto the doctor's Firestore
  /// record (`doctors/{uid}.imageUrl`). Returns the stored URL.
  static Future<String> setDoctorPhoto(String uid, File file) async {
    final url = await uploadDoctorPhoto(uid, file);
    debugPrint('[PhotoUpload] writing imageUrl to doctors/$uid');
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(uid)
        .set({'imageUrl': url}, SetOptions(merge: true));
    debugPrint('[PhotoUpload] doctors/$uid.imageUrl saved');
    return url;
  }

  /// Uploads [file] and merges the URL onto the patient's user record
  /// (`users/{uid}.imageUrl`). Used for non-doctor profile photos, which stay
  /// on the profile screen only. Returns the stored URL.
  static Future<String> setUserPhoto(String uid, File file) async {
    final url = await uploadDoctorPhoto(uid, file);
    debugPrint('[PhotoUpload] writing imageUrl to users/$uid');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'imageUrl': url}, SetOptions(merge: true));
    debugPrint('[PhotoUpload] users/$uid.imageUrl saved');
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
