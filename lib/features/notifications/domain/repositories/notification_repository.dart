import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  /// All notifications addressed to [userId], newest first.
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
      String userId);

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllRead(String userId);

  /// Creates a day-of reminder for [appointmentId] addressed to [userId],
  /// but only once — re-calling for the same appointment is a no-op.
  Future<Either<Failure, void>> createReminder({
    required String appointmentId,
    required String userId,
    required String title,
    required String body,
  });
}
