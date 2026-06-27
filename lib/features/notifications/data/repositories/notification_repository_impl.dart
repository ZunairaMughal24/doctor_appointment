import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  const NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<NotificationEntity>> getNotifications(String userId) =>
      remoteDataSource.getNotifications(userId).map(List<NotificationEntity>.from);

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markAllRead(String userId) async {
    try {
      await remoteDataSource.markAllRead(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createReminder({
    required String appointmentId,
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await remoteDataSource.createReminder(
        appointmentId: appointmentId,
        userId: userId,
        title: title,
        body: body,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
