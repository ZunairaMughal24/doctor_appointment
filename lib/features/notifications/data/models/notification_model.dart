import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

/// Firestore mapping for the `notifications` collection.
///
/// Document schema (single source of truth — written here and by the
/// appointment data source when a booking/confirm/cancel fires a notification):
///   user_id        : recipient uid
///   title, body    : display strings
///   type           : booked | confirmed | cancelled | reminder
///   appointment_id : related appointment (may be empty)
///   read           : bool
///   created_at     : server timestamp
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.type,
    super.appointmentId,
    super.read,
    super.createdAt,
  });

  factory NotificationModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    final ts = data['created_at'];
    return NotificationModel(
      id: id,
      userId: data['user_id'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: AppNotificationTypeX.fromKey(data['type'] as String?),
      appointmentId: data['appointment_id'] ?? '',
      read: data['read'] ?? false,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  /// Builds the payload for a *new* notification doc (server-stamped time).
  /// Shared so every producer writes the same shape.
  static Map<String, dynamic> payload({
    required String userId,
    required String title,
    required String body,
    required AppNotificationType type,
    String appointmentId = '',
  }) =>
      {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type.key,
        'appointment_id': appointmentId,
        'read': false,
        'created_at': FieldValue.serverTimestamp(),
      };
}
