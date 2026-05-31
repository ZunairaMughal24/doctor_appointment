import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetUserAppointmentsUseCase
    implements UseCase<List<AppointmentEntity>, String> {
  final AppointmentRepository repository;
  GetUserAppointmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(String patientId) =>
      repository.getUserAppointments(patientId);
}
