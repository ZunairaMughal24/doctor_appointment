import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';

/// Coordinates the notifications screen with the [NotificationBloc], keeping the
/// page pure UI.
class NotificationsViewModel {
  String _uid(BuildContext context) {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.uid : '';
  }

  /// Loads the list. Notifications are NOT auto-marked read on open — the user
  /// decides, via swipe, tapping a tile, or the persistent "Mark all as read"
  /// button — so the action never vanishes on its own.
  void open(BuildContext context) {
    final uid = _uid(context);
    if (uid.isEmpty) return;
    context.read<NotificationBloc>().add(LoadNotifications(uid));
  }

  void markAllRead(BuildContext context) {
    final uid = _uid(context);
    if (uid.isEmpty) return;
    context.read<NotificationBloc>().add(MarkAllNotificationsRead(uid));
  }

  void markRead(BuildContext context, NotificationEntity n) {
    if (n.read) return;
    context.read<NotificationBloc>().add(MarkNotificationRead(n.id, _uid(context)));
  }
}
