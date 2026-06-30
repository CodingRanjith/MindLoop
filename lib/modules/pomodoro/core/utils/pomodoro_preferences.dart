import 'package:shared_preferences/shared_preferences.dart';

/// Pomodoro settings and daily session stats persisted locally.
class PomodoroPreferences {
  PomodoroPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const focusMinutesKey = 'pomodoro_focus_minutes';
  static const shortBreakMinutesKey = 'pomodoro_short_break_minutes';
  static const longBreakMinutesKey = 'pomodoro_long_break_minutes';
  static const sessionsUntilLongKey = 'pomodoro_sessions_until_long';
  static const autoStartBreaksKey = 'pomodoro_auto_start_breaks';
  static const autoStartFocusKey = 'pomodoro_auto_start_focus';
  static const soundEnabledKey = 'pomodoro_sound_enabled';
  static const completedDateKey = 'pomodoro_completed_date';
  static const completedCountKey = 'pomodoro_completed_count';
  static const totalFocusSecondsKey = 'pomodoro_total_focus_seconds';
  static const themeKey = 'pomodoro_theme_id';
  static const tapCountKey = 'pomodoro_tap_count_today';
  static const tapCountDateKey = 'pomodoro_tap_count_date';

  int get focusMinutes => _prefs.getInt(focusMinutesKey) ?? 25;
  int get shortBreakMinutes => _prefs.getInt(shortBreakMinutesKey) ?? 5;
  int get longBreakMinutes => _prefs.getInt(longBreakMinutesKey) ?? 15;
  int get sessionsUntilLongBreak => _prefs.getInt(sessionsUntilLongKey) ?? 4;
  bool get autoStartBreaks => _prefs.getBool(autoStartBreaksKey) ?? true;
  bool get autoStartFocus => _prefs.getBool(autoStartFocusKey) ?? false;
  bool get soundEnabled => _prefs.getBool(soundEnabledKey) ?? true;

  String get themeId => _prefs.getString(themeKey) ?? 'coral';

  /// Timer taps today (start/pause interactions on the main ring).
  int get tapCountToday {
    _rollTapCountIfNeeded();
    return _prefs.getInt(tapCountKey) ?? 0;
  }

  int get completedToday {
    _rollDailyStatsIfNeeded();
    return _prefs.getInt(completedCountKey) ?? 0;
  }

  int get totalFocusSecondsToday {
    _rollDailyStatsIfNeeded();
    return _prefs.getInt(totalFocusSecondsKey) ?? 0;
  }

  Future<void> setFocusMinutes(int value) =>
      _prefs.setInt(focusMinutesKey, value.clamp(1, 120));

  Future<void> setShortBreakMinutes(int value) =>
      _prefs.setInt(shortBreakMinutesKey, value.clamp(1, 60));

  Future<void> setLongBreakMinutes(int value) =>
      _prefs.setInt(longBreakMinutesKey, value.clamp(1, 60));

  Future<void> setSessionsUntilLongBreak(int value) =>
      _prefs.setInt(sessionsUntilLongKey, value.clamp(2, 10));

  Future<void> setAutoStartBreaks(bool value) =>
      _prefs.setBool(autoStartBreaksKey, value);

  Future<void> setAutoStartFocus(bool value) =>
      _prefs.setBool(autoStartFocusKey, value);

  Future<void> setSoundEnabled(bool value) =>
      _prefs.setBool(soundEnabledKey, value);

  Future<void> setThemeId(String value) => _prefs.setString(themeKey, value);

  Future<void> recordTimerTap() async {
    _rollTapCountIfNeeded();
    final count = (_prefs.getInt(tapCountKey) ?? 0) + 1;
    await _prefs.setInt(tapCountKey, count);
    await _prefs.setString(tapCountDateKey, _todayKey);
  }

  void _rollTapCountIfNeeded() {
    final stored = _prefs.getString(tapCountDateKey);
    if (stored != _todayKey) {
      _prefs.setString(tapCountDateKey, _todayKey);
      _prefs.setInt(tapCountKey, 0);
    }
  }

  Future<void> recordCompletedFocusSession(int focusSeconds) async {
    _rollDailyStatsIfNeeded();
    final count = (_prefs.getInt(completedCountKey) ?? 0) + 1;
    final total = (_prefs.getInt(totalFocusSecondsKey) ?? 0) + focusSeconds;
    await _prefs.setInt(completedCountKey, count);
    await _prefs.setInt(totalFocusSecondsKey, total);
    await _prefs.setString(completedDateKey, _todayKey);
  }

  void _rollDailyStatsIfNeeded() {
    final stored = _prefs.getString(completedDateKey);
    if (stored != _todayKey) {
      _prefs.setString(completedDateKey, _todayKey);
      _prefs.setInt(completedCountKey, 0);
      _prefs.setInt(totalFocusSecondsKey, 0);
    }
  }

  static String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String footerLabel(SharedPreferences prefs) {
    final p = PomodoroPreferences(prefs);
    final count = p.completedToday;
    if (count == 0) return 'Start focus';
    if (count == 1) return '1 session today';
    return '$count sessions today';
  }

  static String focusTimeLabel(SharedPreferences prefs) {
    final seconds = PomodoroPreferences(prefs).totalFocusSecondsToday;
    if (seconds < 60) return '<1 min focused';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min focused';
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    if (rem == 0) return '$hours hr focused';
    return '${hours}h ${rem}m focused';
  }
}
