import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class BookAppointmentUseCase implements UseCase<void, AppointmentEntity> {
  final AppointmentRepository repository;
  BookAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AppointmentEntity appointment) =>
      repository.bookAppointment(appointment);
}
