import 'package:flutter/material.dart';
import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/constants/app_text_styles.dart';
import 'package:medic/core/utils/app_animations.dart';

// ── Slide 3: "Manage your care" — overlapping patient/doctor mode cards ───────

class ManageCareArt extends StatelessWidget {
  const ManageCareArt({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Back card — doctor mode (floats).
          const FloatingWidget(
            distance: 14,
            child: _Offset(
              dx: -26,
              dy: -34,
              angle: -0.09,
              child: _ModeCard(
                icon: Icons.medical_services_rounded,
                label: 'Doctor Mode',
              ),
            ),
          ),
          // Front card — patient mode (floats, opposite phase).
          const FloatingWidget(
            delay: Duration(milliseconds: 700),
            distance: 14,
            child: _Offset(
              dx: 26,
              dy: 38,
              angle: 0.06,
              child: _ModeCard(
                icon: Icons.person_rounded,
                label: 'Patient Mode',
              ),
            ),
          ),
          // Center switch badge (pulses).
          const PulseWidget(
            child: _Badge(icon: Icons.swap_horiz_rounded, size: 56),
          ),
        ],
      ),
    );
  }
}

// ── Shared building blocks ────────────────────────────────────────────────────

/// Translate + rotate a child without leaking Transform clutter into the art.
class _Offset extends StatelessWidget {
  final double dx;
  final double dy;
  final double angle;
  final Widget child;
  const _Offset({
    required this.dx,
    required this.dy,
    required this.angle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(angle: angle, child: child),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );

class _Bar extends StatelessWidget {
  final double width;
  final double height;
  const _Bar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  const _Badge({required this.icon, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary, size: size * 0.5),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ModeCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              const _Bar(width: 70, height: 8),
            ],
          ),
        ],
      ),
    );
  }
}
