/// Payloads and notification ids for smart expense reminders.
class ExpenseReminderConstants {
  ExpenseReminderConstants._();

  static const String payloadMain = 'expense_reminder';
  static const String payloadSnooze = 'expense_reminder_snooze';

  static const int mainNotificationId = 891001;
  static const int snoozeNotificationId = 891002;

  static const String channelId = 'mindloop_expense_v1';
  static const String channelName = 'Expense Tracking Reminders';

  static bool isExpensePayload(String? payload) {
    if (payload == null || payload.isEmpty) return false;
    return payload == payloadMain || payload == payloadSnooze;
  }
}
