import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllRead(String userId);
  Future<void> createReminder({
    required String appointmentId,
    required String userId,
    required String title,
    required String body,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  const NotificationRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('notifications');

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) =>
      _col.where('user_id', isEqualTo: userId).snapshots().map((snap) {
        final items = snap.docs
            .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
            .toList()
          ..sort((a, b) {
            final at = a.createdAt, bt = b.createdAt;
            if (at == null && bt == null) return 0;
            if (at == null) return 1;
            if (bt == null) return -1;
            return bt.compareTo(at);
          });
        return items;
      });

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _col.doc(notificationId).update({'read': true});
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllRead(String userId) async {
    try {
      final snapshot = await _col.where('user_id', isEqualTo: userId).get();
      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        if (doc.data()['read'] == true) continue;
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createReminder({
    required String appointmentId,
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      // Deterministic id makes the day-of reminder idempotent: if it already
      // exists we leave it (and its read state) untouched.
      final ref = _col.doc('reminder_$appointmentId');
      final existing = await ref.get();
      if (existing.exists) return;
      await ref.set(NotificationModel.payload(
        userId: userId,
        title: title,
        body: body,
        type: AppNotificationType.reminder,
        appointmentId: appointmentId,
      ));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
