import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notifications_disabled_banner.dart';

class NotificationInboxPage extends ConsumerStatefulWidget {
  const NotificationInboxPage({super.key});

  @override
  ConsumerState<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends ConsumerState<NotificationInboxPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Catches the case where the user backgrounds the app to flip the OS
  // notification toggle in system Settings (via the banner's own "Turn on"
  // button, or manually) and comes straight back — without this the banner
  // would keep showing stale "disabled" state until the next full navigation.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationsEnabledProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifs = ref.watch(notificationsStreamProvider);
    final hasUnread = ref.watch(unreadCountProvider) > 0;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider).value ?? true;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () =>
                  ref.read(notificationRepositoryProvider).markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(color: AppColors.violet, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!notificationsEnabled) const NotificationsDisabledBanner(),
          Expanded(
            child: notifs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Something went wrong')),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            size: 64, color: AppColors.muted),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet — reminders\nfor your tasks will show up here 🔔',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted, height: 1.5),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, i) => NotificationTile(
                    notification: notifications[i],
                    onTap: () => _handleTap(context, ref, notifications[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    if (!notification.wasRead) {
      ref.read(notificationRepositoryProvider).markAsRead(notification.id);
    }
    await _navigateToTask(context, notification.taskId);
  }

  Future<void> _navigateToTask(BuildContext context, String taskId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId)
          .get();

      if (!doc.exists || !context.mounted) return;

      final task = TaskModel.fromFirestore(doc);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task no longer exists')),
        );
      }
    }
  }
}
