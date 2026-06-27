import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetDoctorAppointmentsUseCase {
  final AppointmentRepository repository;
  GetDoctorAppointmentsUseCase(this.repository);

  Stream<List<AppointmentEntity>> call(String doctorId) =>
      repository.getDoctorAppointments(doctorId);
}
