import 'package:equatable/equatable.dart';

/// Open/close hours for a single weekday. Closed when [open] or [close] is null.
/// Times are stored as 24-hour 'HH:mm' strings (e.g. '09:00').
class DayHours extends Equatable {
  final String day; // 'Monday'..'Sunday'
  final String? open;
  final String? close;

  const DayHours({required this.day, this.open, this.close});

  bool get isOpen => open != null && close != null;

  @override
  List<Object?> get props => [day, open, close];
}

/// A doctor's weekly schedule. Generates bookable time slots per day.
class WeeklyAvailability extends Equatable {
  /// Ordered Monday..Sunday.
  final List<DayHours> days;

  const WeeklyAvailability(this.days);

  /// Slot length in minutes.
  static const int slotMinutes = 30;

  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Full name of today's weekday, matching [weekdayNames].
  static String get todayName => weekdayNames[DateTime.now().weekday - 1];

  /// Sensible default used when a doctor has no stored schedule.
  static const WeeklyAvailability standard = WeeklyAvailability([
    DayHours(day: 'Monday', open: '09:00', close: '17:00'),
    DayHours(day: 'Tuesday', open: '09:00', close: '17:00'),
    DayHours(day: 'Wednesday', open: '09:00', close: '17:00'),
    DayHours(day: 'Thursday', open: '09:00', close: '17:00'),
    DayHours(day: 'Friday', open: '09:00', close: '17:00'),
    DayHours(day: 'Saturday', open: '10:00', close: '14:00'),
    DayHours(day: 'Sunday'),
  ]);

  DayHours forDay(String weekday) => days.firstWhere(
        (d) => d.day == weekday,
        orElse: () => DayHours(day: weekday),
      );

  bool isOpenOn(String weekday) => forDay(weekday).isOpen;

  /// 30-minute slot labels ('HH:mm') between open and close for [weekday].
  List<String> slotsFor(String weekday) {
    final d = forDay(weekday);
    if (!d.isOpen) return const [];
    final start = _toMinutes(d.open!);
    final end = _toMinutes(d.close!);
    final slots = <String>[];
    for (var m = start; m + slotMinutes <= end; m += slotMinutes) {
      slots.add(_toLabel(m));
    }
    return slots;
  }

  /// Whether the doctor has any open day at all.
  bool get hasAnyOpenDay => days.any((d) => d.isOpen);

  /// Converts a 24-hour 'HH:mm' slot to a 12-hour label, e.g. '09:00' → '9:00 AM'.
  static String to12h(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? parts[1] : '00';
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String _toLabel(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  List<Object?> get props => [days];
}
