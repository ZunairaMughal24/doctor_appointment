import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';

/// Uploads profile photos to Supabase Storage and persists the public URL
/// in Firestore. Shared by the doctor sign-up flow and the profile screen.
abstract class ProfilePhotoRemoteDataSource {
  Future<String> setDoctorPhoto(String uid, File file);
  Future<String> setUserPhoto(String uid, File file);
  Future<void> deleteDoctorPhoto(String uid);
  Future<void> deleteUserPhoto(String uid);
}

class ProfilePhotoRemoteDataSourceImpl implements ProfilePhotoRemoteDataSource {
  final FirebaseFirestore firestore;

  const ProfilePhotoRemoteDataSourceImpl({required this.firestore});

  /// Converts any exception into an [ImageUploadException] with a
  /// human-readable message. The single place raw errors are translated
  /// to user-facing copy.
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

  Future<String> _uploadToStorage(String uid, File file) async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[PhotoUpload] ABORT — Supabase not configured');
      throw const ImageUploadException(
          'Cloud storage is not set up yet. Please contact support.');
    }

    final String path = '$uid.jpg';
    try {
      final bucket =
          Supabase.instance.client.storage.from(SupabaseConfig.photoBucket);
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
      debugPrint('[PhotoUpload] StorageException: $e');
      debugPrint('$st');
      throw _mapException(e, 'PhotoUpload');
    } catch (e, st) {
      debugPrint('[PhotoUpload] unexpected error: $e');
      debugPrint('$st');
      throw _mapException(e, 'PhotoUpload');
    }
  }

  @override
  Future<String> setDoctorPhoto(String uid, File file) async {
    final url = await _uploadToStorage(uid, file);
    try {
      await firestore
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

  @override
  Future<String> setUserPhoto(String uid, File file) async {
    final url = await _uploadToStorage(uid, file);
    try {
      await firestore
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

  @override
  Future<void> deleteDoctorPhoto(String uid) async {
    try {
      if (SupabaseConfig.isConfigured) {
        await Supabase.instance.client.storage
            .from(SupabaseConfig.photoBucket)
            .remove(['$uid.jpg']);
      }
      await firestore
          .collection('doctors')
          .doc(uid)
          .set({'imageUrl': ''}, SetOptions(merge: true));
      debugPrint('[DoctorPhoto] doctors/$uid.imageUrl cleared');
    } catch (e, st) {
      debugPrint('[DoctorPhoto] deletion failed: $e');
      debugPrint('$st');
      throw _mapException(e, 'DoctorPhoto');
    }
  }

  @override
  Future<void> deleteUserPhoto(String uid) async {
    try {
      if (SupabaseConfig.isConfigured) {
        await Supabase.instance.client.storage
            .from(SupabaseConfig.photoBucket)
            .remove(['$uid.jpg']);
      }
      await firestore
          .collection('users')
          .doc(uid)
          .set({'imageUrl': ''}, SetOptions(merge: true));
      debugPrint('[PatientPhoto] users/$uid.imageUrl cleared');
    } catch (e, st) {
      debugPrint('[PatientPhoto] deletion failed: $e');
      debugPrint('$st');
      throw _mapException(e, 'PatientPhoto');
    }
  }
}
