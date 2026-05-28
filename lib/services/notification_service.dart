import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

typedef ReminderAlertHandler = Future<void> Function(String reminderId);

@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  NotificationService.handleBackgroundTap(response.payload);
}

class NotificationService {
  NotificationService();

  static ReminderAlertHandler? _backgroundHandler;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  ReminderAlertHandler? onReminderAlert;

  static void handleBackgroundTap(String? payload) {
    final id = payload;
    if (id == null || id.isEmpty) return;
    _backgroundHandler?.call(id);
  }

  Future<void> init({ReminderAlertHandler? onReminderAlert}) async {
    if (_initialized) return;
    this.onReminderAlert = onReminderAlert;
    _backgroundHandler = onReminderAlert;

    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    await requestPermissions();
    _initialized = true;

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      await _onNotificationResponse(launch!.notificationResponse!);
    }
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    final id = response.payload;
    if (id == null || id.isEmpty) return;
    await onReminderAlert?.call(id);
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
      return true;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return true;
    }

    return false;
  }

  Future<void> scheduleReminder(ReminderEntity reminder) async {
    if (!_initialized) await init();
    if (reminder.isCompleted) return;

    final scheduled = reminder.scheduledAt;
    if (scheduled.isBefore(DateTime.now())) return;

    final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);
    final matchComponents = reminder.repeatRule == 'daily'
        ? DateTimeComponents.time
        : null;

    await _plugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.note ?? 'MindLoop reminder',
      tzScheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'mindloop_reminders',
          'MindLoop Reminders',
          channelDescription: 'Smart reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponents,
      payload: reminder.id,
    );
  }

  Future<void> cancelReminder(String id) async {
    await _plugin.cancel(id.hashCode);
  }
}
