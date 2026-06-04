import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Runtime permissions needed for alarms and custom ringtones on Android.
class ReminderAudioPermissions {
  ReminderAudioPermissions._();

  static Future<bool> ensureForCustomSound() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    final audio = await Permission.audio.status;
    if (audio.isGranted) return true;

    final requested = await Permission.audio.request();
    if (requested.isGranted) return true;

    if (await Permission.storage.isGranted) return true;
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  static Future<bool> ensureNotifications() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final requested = await Permission.notification.request();
    return requested.isGranted;
  }

  /// Notifications + exact alarm + battery optimization (background alarms).
  static Future<bool> ensureBackgroundAlarmsReady({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    await ensureNotifications();

    final plugin = notificationsPlugin ??
        FlutterLocalNotificationsPlugin();
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    var exactOk = await android?.canScheduleExactNotifications() ?? true;
    if (!exactOk) {
      await android?.requestExactAlarmsPermission();
      exactOk = await android?.canScheduleExactNotifications() ?? false;
    }

    if (!exactOk) {
      final schedule = await Permission.scheduleExactAlarm.request();
      exactOk = schedule.isGranted;
    }

    final battery = await Permission.ignoreBatteryOptimizations.status;
    if (!battery.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    return exactOk;
  }

  static Future<void> openSystemSettings() => openAppSettings();
}
