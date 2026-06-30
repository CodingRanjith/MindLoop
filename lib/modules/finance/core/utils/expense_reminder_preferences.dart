import 'package:mindloop/app/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ExpenseReminderFrequency { daily, weekly, custom }

class ExpenseReminderPreferences {
  ExpenseReminderPreferences._();

  static const _enabled = 'expense_reminder.enabled';
  static const _frequency = 'expense_reminder.frequency';
  static const _hour = 'expense_reminder.hour';
  static const _minute = 'expense_reminder.minute';
  static const _weekday = 'expense_reminder.weekday';
  static const _skipDate = 'expense_reminder.skip_date';

  static SharedPreferences get _prefs => sl<SharedPreferences>();

  static bool get enabled => _prefs.getBool(_enabled) ?? true;

  static Future<void> setEnabled(bool value) => _prefs.setBool(_enabled, value);

  static ExpenseReminderFrequency get frequency {
    final name = _prefs.getString(_frequency) ?? ExpenseReminderFrequency.daily.name;
    return ExpenseReminderFrequency.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ExpenseReminderFrequency.daily,
    );
  }

  static Future<void> setFrequency(ExpenseReminderFrequency value) =>
      _prefs.setString(_frequency, value.name);

  static int get hour => _prefs.getInt(_hour) ?? 20;

  static int get minute => _prefs.getInt(_minute) ?? 0;

  static Future<void> setTime({required int hour, required int minute}) async {
    await _prefs.setInt(_hour, hour);
    await _prefs.setInt(_minute, minute);
  }

  /// 1 = Monday … 7 = Sunday (DateTime.weekday).
  static int get weekday => _prefs.getInt(_weekday) ?? DateTime.monday;

  static Future<void> setWeekday(int value) => _prefs.setInt(_weekday, value);

  static String? get skipDateIso => _prefs.getString(_skipDate);

  static bool get skippedToday {
    final skip = skipDateIso;
    if (skip == null) return false;
    final today = _todayKey();
    return skip == today;
  }

  static Future<void> skipToday() => _prefs.setString(_skipDate, _todayKey());

  static Future<void> clearSkipToday() => _prefs.remove(_skipDate);

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static DateTime tonightAt({int hour = 20, int minute = 30}) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }
    return target;
  }
}
