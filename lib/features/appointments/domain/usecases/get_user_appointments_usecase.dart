import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetUserAppointmentsUseCase {
  final AppointmentRepository repository;
  GetUserAppointmentsUseCase(this.repository);

  Stream<List<AppointmentEntity>> call(String patientId) =>
      repository.getUserAppointments(patientId);
}
