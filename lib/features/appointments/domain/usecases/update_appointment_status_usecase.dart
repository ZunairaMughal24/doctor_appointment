import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

/// Confirms or cancels an appointment (doctor confirms; either party cancels).
class UpdateAppointmentStatusUseCase
    implements UseCase<void, UpdateStatusParams> {
  final AppointmentRepository repository;
  UpdateAppointmentStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateStatusParams params) =>
      repository.updateAppointmentStatus(
        appointmentId: params.appointmentId,
        status: params.status,
        actorIsDoctor: params.actorIsDoctor,
      );
}

class UpdateStatusParams {
  final String appointmentId;
  final AppointmentStatus status;
  final bool actorIsDoctor;
  const UpdateStatusParams({
    required this.appointmentId,
    required this.status,
    required this.actorIsDoctor,
  });
}
