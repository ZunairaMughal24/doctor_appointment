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

  /// Loads the list and clears the unread badge — opening the centre counts as
  /// "seen", so everything is marked read.
  void open(BuildContext context) {
    final uid = _uid(context);
    if (uid.isEmpty) return;
    final bloc = context.read<NotificationBloc>();
    bloc.add(LoadNotifications(uid));
    bloc.add(MarkAllNotificationsRead(uid));
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
