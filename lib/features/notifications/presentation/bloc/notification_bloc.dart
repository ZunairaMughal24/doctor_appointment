import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;
  const LoadNotifications(this.userId);
  @override
  List<Object?> get props => [userId];
}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  final String userId;
  const MarkNotificationRead(this.notificationId, this.userId);
  @override
  List<Object?> get props => [notificationId, userId];
}

class MarkAllNotificationsRead extends NotificationEvent {
  final String userId;
  const MarkAllNotificationsRead(this.userId);
  @override
  List<Object?> get props => [userId];
}

// ── State ─────────────────────────────────────────────────────────────────────

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> items;
  const NotificationLoaded(this.items);

  int get unreadCount => items.where((n) => !n.read).length;

  @override
  List<Object?> get props => [items];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotifications;
  final MarkNotificationReadUseCase markRead;
  final MarkAllNotificationsReadUseCase markAllRead;

  NotificationBloc({
    required this.getNotifications,
    required this.markRead,
    required this.markAllRead,
  }) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoad, transformer: restartable());
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
  }

  Future<void> _onLoad(
      LoadNotifications event, Emitter<NotificationState> emit) async {
    if (state is! NotificationLoaded) emit(const NotificationLoading());
    await emit.forEach(
      getNotifications(event.userId),
      onData: (items) => NotificationLoaded(items),
      onError: (_, __) => state is NotificationLoaded
          ? state
          : const NotificationError('Failed to load notifications'),
    );
  }

  Future<void> _onMarkRead(
      MarkNotificationRead event, Emitter<NotificationState> emit) async {
    // The Firestore write triggers the live stream, so no manual reload needed.
    await markRead(event.notificationId);
  }

  Future<void> _onMarkAllRead(
      MarkAllNotificationsRead event, Emitter<NotificationState> emit) async {
    await markAllRead(event.userId);
  }
}
