import 'package:shared_preferences/shared_preferences.dart';

/// Tracks how often the in-app calculator is used (for honest hub stats).
class CalculatorUsageTracker {
  CalculatorUsageTracker._();

  static const String prefsKey = 'calculator_equals_count';

  static Future<void> recordCalculation(SharedPreferences prefs) async {
    final count = (prefs.getInt(prefsKey) ?? 0) + 1;
    await prefs.setInt(prefsKey, count);
  }

  static String footerLabel(SharedPreferences prefs) {
    final count = prefs.getInt(prefsKey) ?? 0;
    if (count == 0) return 'Quick math';
    if (count == 1) return '1 calculation';
    return '$count calculations';
  }
}
