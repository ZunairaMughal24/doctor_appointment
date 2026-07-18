import 'package:flutter/material.dart';

/// A single rotating wellness tip shown on the home screen.
class HealthTip {
  final IconData icon;
  final String title;
  final String body;
  const HealthTip({required this.icon, required this.title, required this.body});
}

/// Non-UI logic for the home screen so the page stays pure widgets: the
/// time-of-day greeting and the deterministic "tip of the day". Navigation
/// stays in the page — this ViewModel never touches the router.
class HomeViewModel {
  const HomeViewModel();

  /// Time-aware greeting, e.g. "Good morning". Falls back gracefully.
  String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

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
      title: 'Maintain Optimal Hydration',
      body: 'Clinical guidelines recommend 6–8 glasses of water daily to support kidney function and metabolic balance.',
    ),
    HealthTip(
      icon: Icons.directions_walk_rounded,
      title: 'Incorporate Daily Movement',
      body: 'A minimum of 20 minutes of moderate-intensity activity per day significantly reduces cardiovascular risk.',
    ),
    HealthTip(
      icon: Icons.bedtime_rounded,
      title: 'Prioritise Sleep Hygiene',
      body: 'Adults require 7–9 hours of uninterrupted sleep. Discontinue screen use at least 30 minutes before bedtime.',
    ),
    HealthTip(
      icon: Icons.restaurant_rounded,
      title: 'Adopt a Balanced Diet',
      body: 'Increase your intake of whole foods and varied vegetables to meet micronutrient requirements.',
    ),
    HealthTip(
      icon: Icons.self_improvement_rounded,
      title: 'Manage Stress Proactively',
      body: 'Practising 2–5 minutes of diaphragmatic breathing can measurably reduce cortisol and stress response.',
    ),
    HealthTip(
      icon: Icons.medication_rounded,
      title: 'Adhere to Your Medication Plan',
      body: 'Consistent medication adherence improves treatment outcomes. Set daily reminders to stay on schedule.',
    ),
    HealthTip(
      icon: Icons.sunny,
      title: 'Regulate Your Circadian Rhythm',
      body: 'Brief morning sunlight exposure helps synchronise your body\'s internal clock for improved sleep and energy.',
    ),
    HealthTip(
      icon: Icons.monitor_heart_rounded,
      title: 'Schedule Preventive Check-Ups',
      body: 'Annual health screenings allow early detection of conditions before symptoms arise — prevention is key.',
    ),
  ];
}
