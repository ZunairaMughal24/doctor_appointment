import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/modern_bottom_sheet.dart';

/// Shows a camera/gallery chooser sheet and returns the picked file.
/// Pure device/UI helper — no persistence. Shared by the doctor sign-up
/// flow and the profile screen.
class ImagePickerService {
  ImagePickerService._();

  static final ImagePicker _picker = ImagePicker();

  /// Guards against a second pick being launched while one is still active.
  static bool _picking = false;

  /// Shows a camera/gallery chooser sheet, then returns the picked file — or
  /// null if the user cancels or a picker error occurs. Never throws.
  static Future<File?> pickWithChooser(BuildContext context) async {
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

    if (source == null) return null;

    if (_picking) return null;
    _picking = true;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (picked == null) return null;

      final file = File(picked.path);
      final exists = await file.exists();
      final length = exists ? await file.length() : 0;
      if (!exists || length == 0) return null;
      return file;
    } on PlatformException catch (e, st) {
      debugPrint('[ImagePicker] PlatformException: code="${e.code}" '
          'message="${e.message}"');
      debugPrint('$st');
      return null;
    } catch (e, st) {
      debugPrint('[ImagePicker] unexpected error: $e');
      debugPrint('$st');
      return null;
    } finally {
      _picking = false;
    }
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
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
