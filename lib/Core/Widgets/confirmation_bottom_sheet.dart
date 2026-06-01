import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';

/// Reusable modal bottom sheet for any confirm / cancel action.
///
/// Usage — always call through [AppFeedback.showConfirmation], never directly.
class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// When true the confirm button uses the danger (red) colour palette.
  final bool isDanger;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDanger ? AppColors.error : AppColors.primary;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon
          CircleAvatar(
            radius: 28,
            backgroundColor:
                isDanger ? AppColors.dangerLight : AppColors.primaryLighter,
            child: Icon(
              isDanger ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
              size: 30,
              color: confirmColor,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Buttons
          Row(
            children: [
              // Cancel
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    cancelLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Confirm
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    confirmLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
