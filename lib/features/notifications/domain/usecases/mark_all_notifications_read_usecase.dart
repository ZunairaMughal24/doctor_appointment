import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase implements UseCase<void, String> {
  final NotificationRepository repository;
  MarkAllNotificationsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) =>
      repository.markAllRead(userId);
}
