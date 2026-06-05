import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../viewmodels/notifications_viewmodel.dart';

/// In-app notification centre. Reads from the shared [NotificationBloc] and
/// lets the user tap a notification to mark it read (or mark all at once).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsViewModel _vm = NotificationsViewModel();

  @override
  void initState() {
    super.initState();
    _vm.open(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          'Notifications',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const AppLoader();
          }
          if (state is NotificationError) {
            return _Centered(
              icon: Icons.error_outline,
              message: state.message,
            );
          }
          if (state is NotificationLoaded) {
            if (state.items.isEmpty) {
              return const _Centered(
                icon: Icons.notifications_none_rounded,
                message: 'No notifications yet',
              );
            }
            return Column(
              children: [
                // Persistent header — always visible, never auto-hides.
                _MarkAllBar(
                  unread: state.unreadCount,
                  onMarkAll: () => _vm.markAllRead(context),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = state.items[i];
                      // Swipe an unread item to mark it read (snaps back, stays
                      // in the list). Tapping also marks read.
                      return Dismissible(
                        key: ValueKey(n.id),
                        direction: n.read
                            ? DismissDirection.none
                            : DismissDirection.startToEnd,
                        background: const _SwipeReadBackground(),
                        confirmDismiss: (_) async {
                          _vm.markRead(context, n);
                          return false; // mark read but keep the tile
                        },
                        child: _NotificationTile(
                          notification: n,
                          onTap: () => _vm.markRead(context, n),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (notification.type) {
      AppNotificationType.booked => (AppColors.primary, Icons.event_note_rounded),
      AppNotificationType.confirmed => (
          AppColors.success,
          Icons.check_circle_rounded
        ),
      AppNotificationType.cancelled => (AppColors.error, Icons.cancel_rounded),
      AppNotificationType.reminder => (
          AppColors.warning,
          Icons.notifications_active_rounded
        ),
    };
    final unread = !notification.read;

    return Material(
      color: unread ? AppColors.primaryLighter : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight:
                                  unread ? FontWeight.bold : FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _timeAgo(notification.createdAt!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}

/// Fixed header with the unread count and a persistent "Mark all as read"
/// button. The button is always present; it's just disabled when nothing's unread.
class _MarkAllBar extends StatelessWidget {
  final int unread;
  final VoidCallback onMarkAll;
  const _MarkAllBar({required this.unread, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    final hasUnread = unread > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasUnread ? '$unread unread' : 'All caught up',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: hasUnread ? onMarkAll : null,
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Mark all as read'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: AppColors.textHint,
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green "mark read" affordance revealed when swiping a notification right.
class _SwipeReadBackground extends StatelessWidget {
  const _SwipeReadBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all_rounded, color: AppColors.success, size: 20),
          SizedBox(width: 8),
          Text(
            'Mark read',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  final IconData icon;
  final String message;
  const _Centered({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.primaryLight),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
