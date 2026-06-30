import 'package:flutter_test/flutter_test.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/modules/calculator/core/utils/calculator_usage_tracker.dart';
import 'package:mindloop/core/utils/user_friendly_errors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('App name is MindLoop', () {
    expect(AppConstants.appName, 'MindLoop');
  });

  test('UserFriendlyErrors strips Exception prefix', () {
    expect(
      UserFriendlyErrors.format(Exception('Invalid email')),
      'Invalid email',
    );
  });

  test('CalculatorUsageTracker footer reflects usage count', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    expect(CalculatorUsageTracker.footerLabel(prefs), 'Quick math');
    await CalculatorUsageTracker.recordCalculation(prefs);
    expect(CalculatorUsageTracker.footerLabel(prefs), '1 calculation');
    await CalculatorUsageTracker.recordCalculation(prefs);
    expect(CalculatorUsageTracker.footerLabel(prefs), '2 calculations');
  });
}
