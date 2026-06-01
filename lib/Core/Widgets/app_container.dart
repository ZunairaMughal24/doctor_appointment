import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;

  /// If provided, the whole container becomes tappable with a ripple.
  final VoidCallback? onTap;

  const AppContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.color = Colors.white,
    this.onTap,
  });

  // Shared neumorphic shadow — same tones as AppTextField for a consistent look.
  static const _darkShadow = Color(0xFFC2D2E1);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    final content = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        boxShadow: const [
          // Soft shadow bottom-right.
          BoxShadow(
            color: _darkShadow,
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
          // Light highlight top-left.
          BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}
