import 'package:medic/core/di/injection_container.dart';
import 'package:medic/features/appointments/domain/entities/appointment_entity.dart';
import 'package:medic/features/notifications/domain/usecases/create_reminder_usecase.dart';

/// Fires idempotent day-of reminder notifications for today's appointments,
/// keeping this business logic out of the appointments UI.
class AppointmentReminders {
  AppointmentReminders._();

  /// Tracks which appointments already triggered a reminder this app session,
  /// so we don't re-hit Firestore on every list rebuild (the write itself is
  /// also idempotent via a deterministic doc id).
  static final Set<String> _fired = {};

  static void fireDayOf(
    List<AppointmentEntity> appointments,
    String uid,
    String Function(AppointmentEntity) nameOf,
  ) {
    if (uid.isEmpty) return;
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final today = '${two(now.day)}/${two(now.month)}/${now.year}';

    for (final a in appointments) {
      if (a.appointmentDate != today || a.isCancelled) continue;
      if (!_fired.add(a.id)) continue;
      final time = a.appointmentTime.isEmpty ? '' : ' at ${a.appointmentTime}';
      // Fire-and-forget; the use case dedupes server-side too.
      sl<CreateReminderUseCase>()(ReminderParams(
        appointmentId: a.id,
        userId: uid,
        title: 'Appointment reminder',
        body: 'Reminder: you have an appointment today$time with ${nameOf(a)}.',
      ));
    }
  }
}
