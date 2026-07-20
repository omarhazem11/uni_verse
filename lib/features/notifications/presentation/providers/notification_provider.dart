import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  ref.watch(currentUidProvider);
  return NotificationRemoteDataSourceImpl();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    dataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

final notificationsStreamProvider = StreamProvider<List<NotificationEntity>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsStreamProvider).when(
        data: (list) => list.where((n) => !n.wasRead).length,
        loading: () => 0,
        error: (_, __) => 0,
      );
});

// autoDispose so leaving and re-entering the inbox re-checks the OS
// permission fresh — the widget itself also invalidates this on app resume
// (see NotificationInboxPage) to catch the case where the user backgrounds
// the app to toggle the setting in system Settings and comes straight back.
final notificationsEnabledProvider = FutureProvider.autoDispose<bool>((ref) {
  return NotificationService.areNotificationsEnabled();
});
