import 'package:flutter/foundation.dart';
import 'package:mindloop/core/constants/expense_reminder_constants.dart';
import 'package:mindloop/core/utils/expense_reminder_preferences.dart';
import 'package:mindloop/services/notification_service.dart';

/// Schedules high-priority expense habit reminders (daily / weekly / custom time).
class ExpenseReminderService {
  ExpenseReminderService(this._notifications);

  final NotificationService _notifications;

  Future<void> reschedule() async {
    if (kIsWeb) return;
    await _notifications.init();
    await _notifications.cancelExpenseReminders();

    if (!ExpenseReminderPreferences.enabled) return;
    if (ExpenseReminderPreferences.skippedToday) return;

    final next = _nextScheduledTime();
    if (next == null) return;

    final freq = ExpenseReminderPreferences.frequency;
    await _notifications.scheduleExpenseReminder(
      scheduledAt: next,
      daily: freq == ExpenseReminderFrequency.daily,
      weekly: freq == ExpenseReminderFrequency.weekly,
      title: 'Track your expenses',
      body: 'Did you record today\'s spending? Tap to log now.',
      payload: ExpenseReminderConstants.payloadMain,
    );
  }

  Future<void> snoozeMinutes(int minutes) async {
    if (kIsWeb) return;
    final at = DateTime.now().add(Duration(minutes: minutes));
    await _notifications.scheduleExpenseReminder(
      scheduledAt: at,
      daily: false,
      weekly: false,
      title: 'Expense reminder',
      body: 'Quick check — did you log your expenses?',
      payload: ExpenseReminderConstants.payloadSnooze,
      notificationId: ExpenseReminderConstants.snoozeNotificationId,
    );
  }

  Future<void> snoozeTonight() async {
    final at = ExpenseReminderPreferences.tonightAt();
    if (kIsWeb) return;
    await _notifications.scheduleExpenseReminder(
      scheduledAt: at,
      daily: false,
      weekly: false,
      title: 'Evening expense check',
      body: 'Take a moment to record today\'s expenses.',
      payload: ExpenseReminderConstants.payloadSnooze,
      notificationId: ExpenseReminderConstants.snoozeNotificationId,
    );
  }

  Future<void> skipToday() async {
    await ExpenseReminderPreferences.skipToday();
    await _notifications.cancelExpenseReminders();
  }

  DateTime? _nextScheduledTime() {
    final now = DateTime.now();
    final h = ExpenseReminderPreferences.hour;
    final m = ExpenseReminderPreferences.minute;

    switch (ExpenseReminderPreferences.frequency) {
      case ExpenseReminderFrequency.daily:
        var target = DateTime(now.year, now.month, now.day, h, m);
        if (!target.isAfter(now)) {
          target = target.add(const Duration(days: 1));
        }
        return target;
      case ExpenseReminderFrequency.weekly:
        final targetWeekday = ExpenseReminderPreferences.weekday;
        var target = DateTime(now.year, now.month, now.day, h, m);
        while (target.weekday != targetWeekday || !target.isAfter(now)) {
          target = target.add(const Duration(days: 1));
        }
        return target;
      case ExpenseReminderFrequency.custom:
        var target = DateTime(now.year, now.month, now.day, h, m);
        if (!target.isAfter(now)) {
          target = target.add(const Duration(days: 1));
        }
        return target;
    }
  }
}
