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

  // Shared neumorphic shadow — same tone as AppTextField for a consistent look.
  static const _darkShadow = Color(0xFFC2D2E1);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    final content = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        // 3D depth only — a single soft shadow cast to the bottom-right.
        // No top-left highlight (keeps a clean raised look, not a halo).
        boxShadow: const [
          BoxShadow(
            color: _darkShadow,
            offset: Offset(4, 5),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}
