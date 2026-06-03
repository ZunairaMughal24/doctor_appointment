import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/utils/app_animations.dart';

// ── Slide 2: "Book appointments" — a clean calendar-date composition ──────────
//
// Deliberately NOT an appointment card: a single bold calendar tile with a
// selected day, orbited by a floating clock and a pulsing confirmation badge.

class BookingArt extends StatelessWidget {
  const BookingArt({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: const [
          // Calendar tile gently hovers in the centre.
          FloatingWidget(distance: 10, child: _CalendarTile()),
          // Clock badge floats at the top-left.
          Positioned(
            top: 8,
            left: 34,
            child: FloatingWidget(
              delay: Duration(milliseconds: 500),
              distance: 12,
              child: _Badge(icon: Icons.access_time_rounded, size: 60),
            ),
          ),
          // Confirmation badge pulses at the bottom-right.
          Positioned(
            bottom: 18,
            right: 30,
            child: PulseWidget(child: _ConfirmBadge()),
          ),
        ],
      ),
    );
  }
}

class _CalendarTile extends StatelessWidget {
  const _CalendarTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      height: 168,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          // Coloured header strip with binder tabs.
          Container(
            height: 46,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (_) => Container(
                  width: 8,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Selected day.
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'MON',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textRed,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '12',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmBadge extends StatelessWidget {
  const _ConfirmBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
    );
  }
}

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
                icon: Icons.medical_services_outlined,
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
                icon: Icons.person_outline,
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
                style: const TextStyle(
                  fontSize: 14,
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
