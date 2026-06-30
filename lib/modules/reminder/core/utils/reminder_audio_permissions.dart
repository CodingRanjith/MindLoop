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

  static Future<bool> ensureNotifications({bool interactive = false}) async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (!interactive) return false;

    final requested = await Permission.notification.request();
    return requested.isGranted;
  }

  /// Checks notification + exact-alarm readiness. Only shows system dialogs when
  /// [interactive] is true (e.g. user tapped Settings → Alarm permissions).
  static Future<bool> ensureBackgroundAlarmsReady({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
    bool interactive = false,
  }) async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    final plugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    var notifOk = await Permission.notification.isGranted;
    if (!notifOk && interactive) {
      await android?.requestNotificationsPermission();
      notifOk = await Permission.notification.isGranted;
      if (!notifOk) {
        final requested = await Permission.notification.request();
        notifOk = requested.isGranted;
      }
    }

    var exactOk = await android?.canScheduleExactNotifications() ?? true;
    if (!exactOk && interactive) {
      await android?.requestExactAlarmsPermission();
      exactOk = await android?.canScheduleExactNotifications() ?? false;
      if (!exactOk) {
        final schedule = await Permission.scheduleExactAlarm.request();
        exactOk = schedule.isGranted;
      }
    }

    // Battery optimization opens a heavy system screen — only when user asks.
    if (interactive) {
      final battery = await Permission.ignoreBatteryOptimizations.status;
      if (!battery.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }

    if (!interactive) {
      return notifOk && exactOk;
    }

    final batteryGranted = await Permission.ignoreBatteryOptimizations.isGranted;
    return notifOk && exactOk && batteryGranted;
  }

  static Future<void> openSystemSettings() => openAppSettings();
}
