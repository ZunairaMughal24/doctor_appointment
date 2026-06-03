import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// Creates an idempotent day-of reminder notification for one appointment.
class CreateReminderUseCase implements UseCase<void, ReminderParams> {
  final NotificationRepository repository;
  CreateReminderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ReminderParams params) =>
      repository.createReminder(
        appointmentId: params.appointmentId,
        userId: params.userId,
        title: params.title,
        body: params.body,
      );
}

class ReminderParams {
  final String appointmentId;
  final String userId;
  final String title;
  final String body;
  const ReminderParams({
    required this.appointmentId,
    required this.userId,
    required this.title,
    required this.body,
  });
}
