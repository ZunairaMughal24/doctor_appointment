import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/widgets/confirmation_bottom_sheet.dart';

/// Central utility for all user-facing feedback: toasts and confirmations.
/// Never use raw SnackBar or AlertDialog directly in pages — use this instead.
class AppFeedback {
  AppFeedback._();

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.success,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      color: AppColors.primary,
    );
  }

  /// Shows a confirmation bottom sheet. Returns `true` when the user taps
  /// the confirm button, `false` for cancel or dismiss.
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ConfirmationBottomSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDanger: isDanger,
      ),
    );
    return result ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 4),
        ),
      );
  }
}
