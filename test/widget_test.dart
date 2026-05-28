import 'package:flutter_test/flutter_test.dart';
import 'package:mindloop/core/constants/app_constants.dart';

void main() {
  test('App name is MindLoop', () {
    expect(AppConstants.appName, 'MindLoop');
  });
}
