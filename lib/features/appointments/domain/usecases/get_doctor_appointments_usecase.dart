import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetDoctorAppointmentsUseCase
    implements UseCase<List<AppointmentEntity>, String> {
  final AppointmentRepository repository;
  GetDoctorAppointmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(String doctorId) =>
      repository.getDoctorAppointments(doctorId);
}
