import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:mindloop/modules/pomodoro/core/theme/pomodoro_themes.dart';
import 'package:mindloop/modules/pomodoro/core/utils/pomodoro_preferences.dart';
import 'package:mindloop/modules/reminder/core/utils/reminder_sound_player.dart';

enum PomodoroPhase { focus, shortBreak, longBreak }

enum PomodoroStatus { idle, running, paused }

class PomodoroController extends ChangeNotifier {
  PomodoroController(this._prefs) {
    _loadPhaseDuration();
  }

  final PomodoroPreferences _prefs;
  final AudioPlayer _player = AudioPlayer();

  PomodoroPhase _phase = PomodoroPhase.focus;
  PomodoroStatus _status = PomodoroStatus.idle;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  int _completedFocusInCycle = 0;
  String _taskLabel = '';
  Timer? _ticker;
  DateTime? _endsAt;

  PomodoroPhase get phase => _phase;
  PomodoroStatus get status => _status;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get completedToday => _prefs.completedToday;
  int get tapCountToday => _prefs.tapCountToday;
  int get completedFocusInCycle => _completedFocusInCycle;
  String get taskLabel => _taskLabel;

  PomodoroThemeId get themeId => PomodoroThemeId.fromKey(_prefs.themeId);
  PomodoroTheme get theme => PomodoroTheme.of(themeId);

  double get progress {
    if (_totalSeconds <= 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  bool get isRunning => _status == PomodoroStatus.running;
  bool get isPaused => _status == PomodoroStatus.paused;
  bool get isIdle => _status == PomodoroStatus.idle;

  String get phaseLabel => switch (_phase) {
        PomodoroPhase.focus => 'Focus',
        PomodoroPhase.shortBreak => 'Short Break',
        PomodoroPhase.longBreak => 'Long Break',
      };

  void setTaskLabel(String value) {
    _taskLabel = value;
    notifyListeners();
  }

  void toggleTimer() {
    unawaited(_prefs.recordTimerTap());
    if (_status == PomodoroStatus.running) {
      pause();
    } else {
      start();
    }
  }

  void start() {
    if (_status == PomodoroStatus.running) return;
    if (_status == PomodoroStatus.idle) {
      _loadPhaseDuration();
    }
    _status = PomodoroStatus.running;
    _endsAt = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_status != PomodoroStatus.running) return;
    _ticker?.cancel();
    _status = PomodoroStatus.paused;
    if (_endsAt != null) {
      _remainingSeconds = _endsAt!.difference(DateTime.now()).inSeconds.clamp(0, _totalSeconds);
    }
    _endsAt = null;
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _status = PomodoroStatus.idle;
    _endsAt = null;
    _phase = PomodoroPhase.focus;
    _loadPhaseDuration();
    notifyListeners();
  }

  void skip() {
    _ticker?.cancel();
    _endsAt = null;
    _onPhaseComplete(skipped: true);
  }

  void selectPhase(PomodoroPhase phase) {
    if (_status == PomodoroStatus.running) return;
    _phase = phase;
    _status = PomodoroStatus.idle;
    _loadPhaseDuration();
    notifyListeners();
  }

  Future<void> updateSettings({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsUntilLongBreak,
    bool? autoStartBreaks,
    bool? autoStartFocus,
    bool? soundEnabled,
    String? themeId,
  }) async {
    if (focusMinutes != null) await _prefs.setFocusMinutes(focusMinutes);
    if (shortBreakMinutes != null) {
      await _prefs.setShortBreakMinutes(shortBreakMinutes);
    }
    if (longBreakMinutes != null) {
      await _prefs.setLongBreakMinutes(longBreakMinutes);
    }
    if (sessionsUntilLongBreak != null) {
      await _prefs.setSessionsUntilLongBreak(sessionsUntilLongBreak);
    }
    if (autoStartBreaks != null) await _prefs.setAutoStartBreaks(autoStartBreaks);
    if (autoStartFocus != null) await _prefs.setAutoStartFocus(autoStartFocus);
    if (soundEnabled != null) await _prefs.setSoundEnabled(soundEnabled);
    if (themeId != null) await _prefs.setThemeId(themeId);

    if (_status != PomodoroStatus.running) {
      _loadPhaseDuration();
    }
    notifyListeners();
  }

  Future<void> setTheme(PomodoroThemeId theme) async {
    await _prefs.setThemeId(theme.storageKey);
    notifyListeners();
  }

  PomodoroPreferences get preferences => _prefs;

  void handleAppLifecycle(bool resumed) {
    if (!resumed || _status != PomodoroStatus.running || _endsAt == null) return;
    _remainingSeconds = _endsAt!.difference(DateTime.now()).inSeconds;
    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      _onPhaseComplete();
      return;
    }
    _startTicker();
    notifyListeners();
  }

  void _loadPhaseDuration() {
    final minutes = switch (_phase) {
      PomodoroPhase.focus => _prefs.focusMinutes,
      PomodoroPhase.shortBreak => _prefs.shortBreakMinutes,
      PomodoroPhase.longBreak => _prefs.longBreakMinutes,
    };
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_endsAt == null) return;
    _remainingSeconds = _endsAt!.difference(DateTime.now()).inSeconds;
    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      _onPhaseComplete();
      return;
    }
    notifyListeners();
  }

  Future<void> _onPhaseComplete({bool skipped = false}) async {
    _ticker?.cancel();
    _endsAt = null;
    _status = PomodoroStatus.idle;

    final wasFocus = _phase == PomodoroPhase.focus;
    if (wasFocus && !skipped) {
      await _prefs.recordCompletedFocusSession(_totalSeconds);
      _completedFocusInCycle++;
      await _playCompletionSound();
    } else if (!wasFocus && !skipped) {
      await _playCompletionSound();
    }

    if (wasFocus) {
      final useLong = _completedFocusInCycle >= _prefs.sessionsUntilLongBreak;
      _phase = useLong ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      if (useLong) _completedFocusInCycle = 0;
      if (_prefs.autoStartBreaks && !skipped) {
        _loadPhaseDuration();
        start();
        return;
      }
    } else {
      _phase = PomodoroPhase.focus;
      if (_prefs.autoStartFocus && !skipped) {
        _loadPhaseDuration();
        start();
        return;
      }
    }

    _loadPhaseDuration();
    notifyListeners();
  }

  Future<void> _playCompletionSound() async {
    if (!_prefs.soundEnabled) return;
    await ReminderSoundPlayer.tryPlay(_player, 'sounds/chime.wav');
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _player.dispose();
    super.dispose();
  }
}
