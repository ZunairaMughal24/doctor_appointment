import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_entity.dart';

/// A single rotating wellness tip shown on the home screen.
class HealthTip {
  final IconData icon;
  final String title;
  final String body;
  const HealthTip({required this.icon, required this.title, required this.body});
}

/// Non-UI logic for the home screen so the page stays pure widgets:
/// the time-of-day greeting, the deterministic "tip of the day", and the
/// navigation into a doctor's detail page.
class HomeViewModel {
  const HomeViewModel();

  /// Time-aware greeting, e.g. "Good morning". Falls back gracefully.
  String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void openDoctor(BuildContext context, DoctorEntity doctor) =>
      context.push(AppRoutes.doctorDetailPath(doctor.id), extra: doctor);

  /// Stable for the whole calendar day (changes once per day, same for every
  /// rebuild) so it genuinely reads as a "daily" tip rather than random churn.
  HealthTip get tipOfTheDay {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return _tips[dayOfYear % _tips.length];
  }

  static const List<HealthTip> _tips = [
    HealthTip(
      icon: Icons.local_drink_rounded,
      title: 'Stay hydrated',
      body: 'Aim for 6–8 glasses of water today to keep your energy steady.',
    ),
    HealthTip(
      icon: Icons.directions_walk_rounded,
      title: 'Move a little',
      body: 'A brisk 20-minute walk can lift your mood and heart health.',
    ),
    HealthTip(
      icon: Icons.bedtime_rounded,
      title: 'Protect your sleep',
      body: 'Try to wind down screen-free 30 minutes before bed tonight.',
    ),
    HealthTip(
      icon: Icons.restaurant_rounded,
      title: 'Eat the rainbow',
      body: 'Add one extra serving of fruit or vegetables to a meal today.',
    ),
    HealthTip(
      icon: Icons.self_improvement_rounded,
      title: 'Breathe & reset',
      body: 'Two minutes of slow breathing can ease stress between tasks.',
    ),
    HealthTip(
      icon: Icons.medication_rounded,
      title: 'Stay on schedule',
      body: 'Keep up with any prescribed medication — set a daily reminder.',
    ),
    HealthTip(
      icon: Icons.sunny,
      title: 'Get some light',
      body: 'A few minutes of morning sunlight helps regulate your body clock.',
    ),
  ];
}
