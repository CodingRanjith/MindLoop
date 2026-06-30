import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for shake-based step counting.
class StepsPreferences {
  StepsPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const stepsDateKey = 'steps_count_date';
  static const stepsCountKey = 'steps_count_today';
  static const shakesCountKey = 'steps_shakes_today';
  static const dailyGoalKey = 'steps_daily_goal';
  static const sensitivityKey = 'steps_shake_sensitivity';
  static const themeKey = 'steps_theme_id';

  int get dailyGoal => _prefs.getInt(dailyGoalKey) ?? 100;

  /// Sensitivity multiplier (0.8 = more sensitive, 2.5 = less).
  double get sensitivity =>
      (_prefs.getInt(sensitivityKey) ?? 15) / 10.0;

  String get themeId => _prefs.getString(themeKey) ?? 'vitality';

  int get stepsToday {
    _rollDailyIfNeeded();
    return _prefs.getInt(stepsCountKey) ?? 0;
  }

  int get shakesToday {
    _rollDailyIfNeeded();
    return _prefs.getInt(shakesCountKey) ?? 0;
  }

  Future<void> setDailyGoal(int value) =>
      _prefs.setInt(dailyGoalKey, value.clamp(10, 10000));

  Future<void> setSensitivity(double value) => _prefs.setInt(
        sensitivityKey,
        (value.clamp(0.8, 3.0) * 10).round(),
      );

  Future<void> setThemeId(String value) => _prefs.setString(themeKey, value);

  Future<int> recordShakeStep() async {
    _rollDailyIfNeeded();
    final steps = (_prefs.getInt(stepsCountKey) ?? 0) + 1;
    final shakes = (_prefs.getInt(shakesCountKey) ?? 0) + 1;
    await _prefs.setInt(stepsCountKey, steps);
    await _prefs.setInt(shakesCountKey, shakes);
    await _prefs.setString(stepsDateKey, _todayKey);
    return steps;
  }

  Future<void> resetToday() async {
    await _prefs.setInt(stepsCountKey, 0);
    await _prefs.setInt(shakesCountKey, 0);
    await _prefs.setString(stepsDateKey, _todayKey);
  }

  void _rollDailyIfNeeded() {
    final stored = _prefs.getString(stepsDateKey);
    if (stored != _todayKey) {
      _prefs.setString(stepsDateKey, _todayKey);
      _prefs.setInt(stepsCountKey, 0);
      _prefs.setInt(shakesCountKey, 0);
    }
  }

  static String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String footerLabel(SharedPreferences prefs) {
    final p = StepsPreferences(prefs);
    final count = p.stepsToday;
    final goal = p.dailyGoal;
    if (count == 0) return 'Shake to count';
    if (count >= goal) return 'Goal reached!';
    return '$count / $goal steps';
  }
}
