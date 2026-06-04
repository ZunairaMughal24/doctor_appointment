import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';

/// Centralises picking (camera or gallery) and uploading doctor profile photos
/// to Firebase Storage, and persisting the download URL on the doctor record.
/// Shared by the doctor sign-up flow and the profile screen.
class ImageUploadService {
  ImageUploadService._();

  static final ImagePicker _picker = ImagePicker();

  /// Shows a camera/gallery chooser sheet, then returns the picked file — or
  /// null if the user cancels either the chooser or the picker.
  static Future<File?> pickWithChooser(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppColors.primary),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 600,
    );
    return picked == null ? null : File(picked.path);
  }

  /// Uploads [file] to `doctor_photos/{uid}.jpg` and returns its download URL.
  static Future<String> uploadDoctorPhoto(String uid, File file) async {
    final ref =
        FirebaseStorage.instance.ref().child('doctor_photos').child('$uid.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Uploads [file] and merges the resulting URL onto the doctor's Firestore
  /// record (`doctors/{uid}.imageUrl`). Returns the stored URL.
  static Future<String> setDoctorPhoto(String uid, File file) async {
    final url = await uploadDoctorPhoto(uid, file);
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(uid)
        .set({'imageUrl': url}, SetOptions(merge: true));
    return url;
  }
}
