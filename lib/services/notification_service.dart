import 'dart:async';

import 'dart:io';



import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:mindloop/core/utils/reminder_audio_permissions.dart';

import 'package:mindloop/core/utils/reminder_sound_player.dart';

import 'package:mindloop/core/constants/expense_reminder_constants.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';

import 'package:mindloop/services/reminder_notification_sound.dart';

import 'package:timezone/data/latest_all.dart' as tz;

import 'package:timezone/timezone.dart' as tz;



typedef ReminderAlertHandler = Future<void> Function(String reminderId);

typedef ExpenseReminderAlertHandler = Future<void> Function(String? payload);



@pragma('vm:entry-point')

void onBackgroundNotificationTap(NotificationResponse response) {

  NotificationService.handleBackgroundTap(response.payload);

}



class NotificationService {

  NotificationService();



  static const _channelId = 'mindloop_reminders_v3';



  static ReminderAlertHandler? _backgroundHandler;

  static ExpenseReminderAlertHandler? _backgroundExpenseHandler;



  final FlutterLocalNotificationsPlugin _plugin =

      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void>? _initFuture;

  final Map<String, Timer> _webReminderTimers = {};



  ReminderAlertHandler? onReminderAlert;

  ExpenseReminderAlertHandler? onExpenseReminderAlert;



  static void handleBackgroundTap(String? payload) {

    if (payload == null || payload.isEmpty) return;

    if (ExpenseReminderConstants.isExpensePayload(payload)) {

      _backgroundExpenseHandler?.call(payload);

      return;

    }

    _backgroundHandler?.call(payload);

  }



  static int notificationIdFor(String reminderId) =>

      reminderId.hashCode & 0x7fffffff;



  static DateTime asLocal(DateTime value) =>

      value.isUtc ? value.toLocal() : value;



  static tz.TZDateTime toTzLocal(DateTime scheduled) {

    final local = asLocal(scheduled);

    return tz.TZDateTime(

      tz.local,

      local.year,

      local.month,

      local.day,

      local.hour,

      local.minute,

      local.second,

      local.millisecond,

      local.microsecond,

    );

  }



  Future<void> init({ReminderAlertHandler? onReminderAlert}) async {

    if (_initialized) return;

    _initFuture ??= _doInit(onReminderAlert);

    await _initFuture;

  }



  Future<void> _doInit(ReminderAlertHandler? onReminderAlert) async {

    this.onReminderAlert = onReminderAlert;

    _backgroundHandler = onReminderAlert;

    _backgroundExpenseHandler = onExpenseReminderAlert;



    if (kIsWeb) {

      _initialized = true;

      return;

    }



    tz.initializeTimeZones();

    try {

      final timeZoneName = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(tz.getLocation(timeZoneName));

    } catch (_) {

      tz.setLocalLocation(tz.local);

    }



    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(

      requestAlertPermission: true,

      requestSoundPermission: true,

    );

    const settings = InitializationSettings(android: android, iOS: ios);



    await _plugin.initialize(

      settings,

      onDidReceiveNotificationResponse: _onNotificationResponse,

      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,

    );



    await _ensureAndroidChannel();

    await _ensureExpenseChannel();

    await requestPermissions();

    _initialized = true;



    final launch = await _plugin.getNotificationAppLaunchDetails();

    if (launch?.didNotificationLaunchApp ?? false) {

      await _onNotificationResponse(launch!.notificationResponse!);

    }

  }



  Future<void> _ensureAndroidChannel() async {

    if (!Platform.isAndroid) return;

    final android = _plugin.resolvePlatformSpecificImplementation<

        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(

      const AndroidNotificationChannel(

        _channelId,

        'MindLoop Reminders',

        description: 'Alarm-style reminder notifications',

        importance: Importance.max,

        playSound: true,

        enableVibration: true,

      ),

    );

  }



  Future<void> _onNotificationResponse(NotificationResponse response) async {

    final payload = response.payload;

    if (payload == null || payload.isEmpty) return;

    if (ExpenseReminderConstants.isExpensePayload(payload)) {

      await onExpenseReminderAlert?.call(payload);

      return;

    }

    await onReminderAlert?.call(payload);

  }



  Future<bool> requestPermissions() async {

    if (kIsWeb) return true;

    return ReminderAudioPermissions.ensureBackgroundAlarmsReady(

      notificationsPlugin: _plugin,

    );

  }



  bool _shouldSchedule(ReminderEntity reminder) {

    if (reminder.isCompleted) return false;

    final scheduled = asLocal(reminder.scheduledAt);

    final now = DateTime.now();

    return !scheduled.isBefore(now.subtract(const Duration(minutes: 1)));

  }



  Future<void> rescheduleAll(Iterable<ReminderEntity> reminders) async {

    if (!_initialized) await init();

    if (kIsWeb) {

      for (final reminder in reminders) {

        if (_shouldSchedule(reminder)) {

          _scheduleWebReminder(reminder);

        }

      }

      return;

    }



    for (final reminder in reminders) {

      await cancelReminder(reminder.id);

      if (_shouldSchedule(reminder)) {

        await scheduleReminder(reminder);

      }

    }

  }



  Future<AndroidNotificationDetails> _androidDetailsFor(

    ReminderEntity reminder,

  ) async {

    AndroidNotificationSound? sound;

    if (Platform.isAndroid) {

      sound = await ReminderNotificationSound.forReminder(

        reminder.id,

        reminder.musicAsset,

      );

    }



    return AndroidNotificationDetails(

      _channelId,

      'MindLoop Reminders',

      channelDescription: 'Alarm-style reminder notifications',

      importance: Importance.max,

      priority: Priority.high,

      playSound: true,

      sound: sound,

      enableVibration: true,

      fullScreenIntent: true,

      category: AndroidNotificationCategory.alarm,

      visibility: NotificationVisibility.public,

      ticker: 'MindLoop reminder',

      autoCancel: false,

      onlyAlertOnce: true,

    );

  }



  Future<void> scheduleReminder(ReminderEntity reminder) async {

    if (!_initialized) await init();

    if (reminder.isCompleted) return;

    if (!_shouldSchedule(reminder)) return;



    if (kIsWeb) {

      _scheduleWebReminder(reminder);

      return;

    }



    if (Platform.isAndroid &&

        ReminderSoundPlayer.isCustomFile(

          ReminderSoundPlayer.resolveAssetOrFile(reminder.musicAsset),

        )) {

      await ReminderAudioPermissions.ensureForCustomSound();

    }



    final tzScheduled = toTzLocal(reminder.scheduledAt);

    final matchComponents = reminder.repeatRule == 'daily'

        ? DateTimeComponents.time

        : null;



    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<

        AndroidFlutterLocalNotificationsPlugin>();

    var scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;

    if (Platform.isAndroid) {

      final canExact = await androidPlugin?.canScheduleExactNotifications();

      if (canExact == false) {

        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

      }

    }



    final androidDetails = await _androidDetailsFor(reminder);



    await _plugin.zonedSchedule(

      notificationIdFor(reminder.id),

      reminder.title,

      reminder.note ?? 'MindLoop reminder',

      tzScheduled,

      NotificationDetails(

        android: androidDetails,

        iOS: const DarwinNotificationDetails(

          presentAlert: true,

          presentSound: true,

          presentBadge: true,

          interruptionLevel: InterruptionLevel.timeSensitive,

        ),

      ),

      androidScheduleMode: scheduleMode,

      matchDateTimeComponents: matchComponents,

      payload: reminder.id,

    );

  }



  Future<void> cancelReminder(String id) async {

    if (kIsWeb) {

      _webReminderTimers.remove(id)?.cancel();

      return;

    }

    await _plugin.cancel(notificationIdFor(id));

    await ReminderNotificationSound.deleteForReminder(id);

  }



  void _scheduleWebReminder(ReminderEntity reminder) {

    _webReminderTimers.remove(reminder.id)?.cancel();

    final delay = asLocal(reminder.scheduledAt).difference(DateTime.now());

    if (delay.isNegative || delay == Duration.zero) return;



    _webReminderTimers[reminder.id] = Timer(delay, () async {

      await onReminderAlert?.call(reminder.id);

      if (reminder.repeatRule == 'daily') {

        final next = reminder.copyWith(

          scheduledAt: reminder.scheduledAt.add(const Duration(days: 1)),

        );

        _scheduleWebReminder(next);

      } else {

        _webReminderTimers.remove(reminder.id);

      }

    });

  }



  Future<void> _ensureExpenseChannel() async {

    if (!Platform.isAndroid) return;

    final android = _plugin.resolvePlatformSpecificImplementation<

        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(

      const AndroidNotificationChannel(

        ExpenseReminderConstants.channelId,

        ExpenseReminderConstants.channelName,

        description: 'Daily expense tracking habit reminders',

        importance: Importance.max,

        playSound: true,

        enableVibration: true,

      ),

    );

  }



  Future<void> scheduleExpenseReminder({

    required DateTime scheduledAt,

    required bool daily,

    required bool weekly,

    required String title,

    required String body,

    required String payload,

    int notificationId = ExpenseReminderConstants.mainNotificationId,

  }) async {

    if (!_initialized) await init();

    if (kIsWeb) return;



    await _ensureExpenseChannel();



    final tzScheduled = toTzLocal(scheduledAt);

    DateTimeComponents? match;

    if (daily) {

      match = DateTimeComponents.time;

    } else if (weekly) {

      match = DateTimeComponents.dayOfWeekAndTime;

    }



    var scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;

    if (Platform.isAndroid) {

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<

          AndroidFlutterLocalNotificationsPlugin>();

      final canExact = await androidPlugin?.canScheduleExactNotifications();

      if (canExact == false) {

        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

      }

    }



    const androidDetails = AndroidNotificationDetails(

      ExpenseReminderConstants.channelId,

      ExpenseReminderConstants.channelName,

      channelDescription: 'Daily expense tracking habit reminders',

      importance: Importance.max,

      priority: Priority.max,

      playSound: true,

      enableVibration: true,

      fullScreenIntent: true,

      category: AndroidNotificationCategory.reminder,

      visibility: NotificationVisibility.public,

      ticker: 'Expense reminder',

      autoCancel: true,

    );



    await _plugin.zonedSchedule(

      notificationId,

      title,

      body,

      tzScheduled,

      const NotificationDetails(

        android: androidDetails,

        iOS: DarwinNotificationDetails(

          presentAlert: true,

          presentSound: true,

          presentBadge: true,

          interruptionLevel: InterruptionLevel.timeSensitive,

        ),

      ),

      androidScheduleMode: scheduleMode,

      matchDateTimeComponents: match,

      payload: payload,

    );

  }



  Future<void> cancelExpenseReminders() async {

    if (kIsWeb) return;

    await _plugin.cancel(ExpenseReminderConstants.mainNotificationId);

    await _plugin.cancel(ExpenseReminderConstants.snoozeNotificationId);

  }

}

