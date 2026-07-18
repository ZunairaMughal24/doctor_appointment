import 'package:flutter/material.dart';
import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/constants/app_text_styles.dart';

/// Shared app button used across every screen for visual consistency.
///
/// Two variants:
///  * filled (default) — solid [color] background with white label.
///  * outlined — transparent background with a [color] border + label.
///
/// Supports an optional leading [icon], a [loading] spinner state, and a
/// custom [color] (defaults to the app primary dark-blue).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool loading;
  final IconData? icon;
  final Color color;
  final Color foreground;
  final double height;
  final double borderRadius;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.loading = false,
    this.icon,
    this.color = AppColors.primary,
    this.foreground = Colors.white,
    this.height = 45,
    this.borderRadius = 12,
    this.expand = true,
  });

  /// Convenience constructor for the secondary / outlined style.
  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color = AppColors.primary,
    this.height = 45,
    this.borderRadius = 12,
    this.expand = true,
  })  : filled = false,
      foreground = color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final fg = filled ? foreground : color;
    final disabled = onPressed == null || loading;

    final button = Material(
      color: filled ? color : Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: radius,
        child: Opacity(
          opacity: onPressed == null && !loading ? 0.6 : 1,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: filled ? null : Border.all(color: color, width: 1.4),
            ),
            child: Center(
              child: loading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: fg, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: AppTextStyles.button.copyWith(color: fg),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
