import 'package:medic/core/di/injection_container.dart';
import 'package:medic/features/appointments/domain/entities/appointment_entity.dart';
import 'package:medic/features/appointments/domain/usecases/update_appointment_status_usecase.dart';

/// Persists `completed` for confirmed appointments whose session window has
/// ended. The UI already reflects this immediately via
/// [AppointmentEntity.effectiveStatus]; this just makes it durable on both the
/// doctor's and patient's records. Idempotent + session-cached so a list
/// rebuild doesn't re-write.
class AppointmentAutoComplete {
  AppointmentAutoComplete._();

  static final Set<String> _done = {};

  static void run(List<AppointmentEntity> appointments) {
    for (final a in appointments) {
      if (!a.shouldAutoComplete) continue;
      if (!_done.add(a.id)) continue;
      // Fire-and-forget. Completion fires no notification, so actorIsDoctor is
      // irrelevant here.
      sl<UpdateAppointmentStatusUseCase>()(UpdateStatusParams(
        appointmentId: a.id,
        status: AppointmentStatus.completed,
        actorIsDoctor: true,
      ));
    }
  }
}
