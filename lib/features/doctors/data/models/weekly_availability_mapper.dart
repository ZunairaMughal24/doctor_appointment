import '../../domain/entities/weekly_availability.dart';

/// Firestore (de)serialization for [WeeklyAvailability] — kept in the data
/// layer since the domain entity must stay persistence-agnostic.
extension WeeklyAvailabilityMapper on WeeklyAvailability {
  Map<String, dynamic> toFirestoreMap() => {
        for (final d in days)
          d.day: d.isOpen ? {'open': d.open, 'close': d.close} : null,
      };
}

WeeklyAvailability weeklyAvailabilityFromFirestoreMap(
    Map<String, dynamic>? map) {
  if (map == null || map.isEmpty) return WeeklyAvailability.standard;
  return WeeklyAvailability([
    for (final day in WeeklyAvailability.weekdayNames)
      if (map[day] is Map)
        DayHours(
          day: day,
          open: (map[day] as Map)['open'] as String?,
          close: (map[day] as Map)['close'] as String?,
        )
      else
        DayHours(day: day),
  ]);
}
