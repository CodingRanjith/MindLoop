import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:mindloop/modules/steps/core/utils/steps_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Detects phone shakes via accelerometer and counts them as steps.
class ShakeStepDetector extends ChangeNotifier {
  ShakeStepDetector(this._prefs);

  final StepsPreferences _prefs;

  StreamSubscription<AccelerometerEvent>? _subscription;
  bool _listening = false;
  int _sessionSteps = 0;
  double _intensity = 0;
  double _dynamicThreshold = 1.8;
  double _lastMagnitude = 9.8;
  DateTime? _lastShakeAt;

  final List<double> _magnitudeWindow = [];

  static const _gravity = 9.80665;
  static const _cooldownMs = 320;
  static const _windowSize = 24;

  bool get isListening => _listening;
  int get sessionSteps => _sessionSteps;
  int get stepsToday => _prefs.stepsToday;
  int get shakesToday => _prefs.shakesToday;
  int get dailyGoal => _prefs.dailyGoal;
  double get intensity => _intensity;
  double get dynamicThreshold => _dynamicThreshold;
  double get progress =>
      dailyGoal <= 0 ? 0 : (stepsToday / dailyGoal).clamp(0.0, 1.0);

  StepsPreferences get preferences => _prefs;

  Future<void> startListening() async {
    if (_listening) return;
    if (kIsWeb) {
      _listening = true;
      notifyListeners();
      return;
    }
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      _onAccelerometer,
      onError: (_) => stopListening(),
    );
    _listening = true;
    notifyListeners();
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _listening = false;
    _intensity = 0;
    notifyListeners();
  }

  void resetSession() {
    _sessionSteps = 0;
    notifyListeners();
  }

  Future<void> resetToday() async {
    await _prefs.resetToday();
    _sessionSteps = 0;
    notifyListeners();
  }

  Future<void> updateSettings({
    int? dailyGoal,
    double? sensitivity,
    String? themeId,
  }) async {
    if (dailyGoal != null) await _prefs.setDailyGoal(dailyGoal);
    if (sensitivity != null) await _prefs.setSensitivity(sensitivity);
    if (themeId != null) await _prefs.setThemeId(themeId);
    _recalculateThreshold();
    notifyListeners();
  }

  Future<void> setTheme(String themeId) async {
    await _prefs.setThemeId(themeId);
    notifyListeners();
  }

  /// Manual step for simulators / web demo.
  Future<void> simulateShake() async {
    await _registerShake(intensity: 2.4);
  }

  void _onAccelerometer(AccelerometerEvent event) {
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    _magnitudeWindow.add(magnitude);
    if (_magnitudeWindow.length > _windowSize) {
      _magnitudeWindow.removeAt(0);
    }

    final baseline = _magnitudeWindow.isEmpty
        ? _gravity
        : _magnitudeWindow.reduce((a, b) => a + b) / _magnitudeWindow.length;

    final deviation = (magnitude - baseline).abs();
    final jerk = (magnitude - _lastMagnitude).abs();
    _lastMagnitude = magnitude;

    _intensity = math.max(deviation, jerk * 0.65);
    _recalculateThreshold(baseline: baseline);

    final spike = math.max(deviation, jerk);
    if (spike >= _dynamicThreshold) {
      final now = DateTime.now();
      if (_lastShakeAt == null ||
          now.difference(_lastShakeAt!).inMilliseconds >= _cooldownMs) {
        _lastShakeAt = now;
        unawaited(_registerShake(intensity: spike));
      }
    }

    notifyListeners();
  }

  void _recalculateThreshold({double? baseline}) {
    final base = baseline ?? _gravity;
    final sensitivity = _prefs.sensitivity;
    double noise = 0.4;
    if (_magnitudeWindow.length >= 8) {
      final mean = _magnitudeWindow.reduce((a, b) => a + b) /
          _magnitudeWindow.length;
      final variance = _magnitudeWindow
              .map((v) => (v - mean) * (v - mean))
              .reduce((a, b) => a + b) /
          _magnitudeWindow.length;
      noise = math.sqrt(variance).clamp(0.25, 1.2);
    }
    _dynamicThreshold = (noise * 2.2 + sensitivity * 0.55).clamp(1.0, 4.5);
    if (base < 8 || base > 12) {
      _dynamicThreshold += 0.35;
    }
  }

  Future<void> _registerShake({required double intensity}) async {
    await _prefs.recordShakeStep();
    _sessionSteps++;
    _intensity = intensity;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
