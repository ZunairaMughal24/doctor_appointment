import 'package:equatable/equatable.dart';

/// Category of an in-app notification — drives the icon/colour shown in the list.
enum AppNotificationType { booked, confirmed, cancelled, completed, reminder }

extension AppNotificationTypeX on AppNotificationType {
  String get key => name;

  static AppNotificationType fromKey(String? key) => switch (key) {
        'booked' => AppNotificationType.booked,
        'confirmed' => AppNotificationType.confirmed,
        'cancelled' => AppNotificationType.cancelled,
        'completed' => AppNotificationType.completed,
        _ => AppNotificationType.reminder,
      };
}

/// A single in-app notification addressed to one user (the [userId] recipient).
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final AppNotificationType type;
  final String appointmentId;
  final bool read;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.appointmentId = '',
    this.read = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, read];
}
