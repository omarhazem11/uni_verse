import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../../features/notifications/domain/entities/notification_entity.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/tasks/domain/entities/task_entity.dart';

@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse details) {
  // Cold-start taps are handled via getNotificationAppLaunchDetails() in initialize().
}

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static NotificationRepository? _repository;
  static Future<void> Function(String taskId)? _onTapNavigate;

  static final navigatorKey = GlobalKey<NavigatorState>();

  static const _channelId = 'task_reminders';
  static const _channelName = 'Task Reminders';

  // MethodChannel wired to MainActivity — exposes AlarmManager.canScheduleExactAlarms().
  static const _alarmChannel = MethodChannel('com.unibuddy.uni_buddy/alarm');

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  static Future<void> initialize({
    required NotificationRepository repository,
    required Future<void> Function(String taskId) onTapNavigate,
  }) async {
    _repository = repository;
    _onTapNavigate = onTapNavigate;

    tz_data.initializeTimeZones();

    // Use the foreground drawable, not ic_launcher — adaptive icons can't be
    // used as notification icons; Android falls back to a blue circle for them.
    const androidInit = AndroidInitializationSettings('@drawable/ic_launcher_foreground');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onForegroundTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );

    // Create the notification channel BEFORE any notification is scheduled.
    // Must happen every launch — createNotificationChannel is idempotent.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Reminders for your upcoming tasks',
          importance: Importance.high,
        ));

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _onTapNavigate?.call(payload);
        });
      }
    }
  }

  static void _onForegroundTap(NotificationResponse response) {
    final taskId = response.payload;
    if (taskId != null) _onTapNavigate?.call(taskId);
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  static Future<void> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    // Only prompt for exact-alarm settings if the permission is actually missing.
    // Opens Settings → Apps → Special access → Alarms & reminders when needed.
    if (!await _canScheduleExactAlarms()) {
      await android?.requestExactAlarmsPermission();
    }

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ---------------------------------------------------------------------------
  // Scheduling
  // ---------------------------------------------------------------------------

  static Future<void> scheduleTaskReminder(
    TaskEntity task, {
    bool writeToInbox = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notifications_enabled') ?? true)) return;

    final reminderTime = _reminderTime(task);
    if (reminderTime == null || reminderTime.isBefore(DateTime.now())) return;

    final canExact = await _canScheduleExactAlarms();
    final tzTime = tz.TZDateTime.from(reminderTime.toUtc(), tz.UTC);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Reminders for your upcoming tasks',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_launcher_foreground',
        color: Color(0xFF7B61FF),
      ),
      iOS: DarwinNotificationDetails(),
    );

    final title = '⏰ ${task.title}';
    final body = task.dueDate != null ? 'Due ${_formatDue(task.dueDate!)}' : 'Task reminder';

    if (canExact) {
      try {
        // alarmClock uses AlarmManager.setAlarmClock() — exempt from Doze mode
        // and manufacturer battery optimizers, but requires canScheduleExactAlarms().
        await _plugin.zonedSchedule(
          _notifId(task.id),
          title,
          body,
          tzTime,
          details,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id,
        );
      } catch (_) {
        await _scheduleInexact(task.id, title, body, tzTime, details);
      }
    } else {
      await _scheduleInexact(task.id, title, body, tzTime, details);
    }

    if (writeToInbox) {
      final record = NotificationEntity(
        id: const Uuid().v4(),
        taskId: task.id,
        title: title,
        body: body,
        scheduledFor: reminderTime,
        wasRead: false,
        createdAt: DateTime.now(),
      );
      await _repository?.addNotificationRecord(record);
    }
  }

  static Future<void> _scheduleInexact(
    String taskId,
    String title,
    String body,
    tz.TZDateTime tzTime,
    NotificationDetails details,
  ) async {
    try {
      await _plugin.zonedSchedule(
        _notifId(taskId),
        title,
        body,
        tzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
      );
    } catch (_) {}
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    await _plugin.cancel(_notifId(taskId));
  }

  // Reschedules OS notifications only — does not write new inbox records so
  // existing Firestore entries from task creation/update are not duplicated.
  // Skips entirely if tasks is empty — an empty list most likely means the
  // stream timed out (offline startup), and cancelling all pending alarms
  // would silently wipe reminders that are still valid.
  static Future<void> rescheduleAllReminders(List<TaskEntity> tasks) async {
    if (tasks.isEmpty) return;
    await _plugin.cancelAll();
    for (final task in tasks) {
      if (!task.isCompleted) {
        await scheduleTaskReminder(task, writeToInbox: false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  // Calls AlarmManager.canScheduleExactAlarms() via MethodChannel (API 31+).
  // Returns true unconditionally on older Android where exact alarms are
  // always permitted.
  static Future<bool> _canScheduleExactAlarms() async {
    try {
      return await _alarmChannel.invokeMethod<bool>('canScheduleExactAlarms') ?? true;
    } on PlatformException {
      return true;
    }
  }

  static DateTime? _reminderTime(TaskEntity task) {
    if (task.customReminderDateTime != null) return task.customReminderDateTime;
    if (task.dueDate != null &&
        task.reminderOffset != null &&
        task.reminderOffset != Duration.zero) {
      return task.dueDate!.subtract(task.reminderOffset!);
    }
    return null;
  }

  static int _notifId(String taskId) => taskId.hashCode.abs() % 2147483647;

  static String _formatDue(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(DateTime(now.year, now.month, now.day));
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'tomorrow';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
