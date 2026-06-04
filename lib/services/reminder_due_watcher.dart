import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mindloop/domain/repositories/reminder_repository.dart';
import 'package:mindloop/services/reminder_alert_launcher.dart';

/// Fires in-app alarms while the app is open (notifications can be delayed in foreground).
class ReminderDueWatcher {
  ReminderDueWatcher({
    required ReminderRepository repository,
    required ReminderAlertLauncher alertLauncher,
  })  : _repository = repository,
        _alertLauncher = alertLauncher;

  final ReminderRepository _repository;
  final ReminderAlertLauncher _alertLauncher;

  Timer? _timer;
  final Set<String> _firedIds = {};

  void start() {
    if (kIsWeb) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _tick());
    _tick();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    final reminders = await _repository.getReminders();
    final now = DateTime.now();

    for (final reminder in reminders) {
      if (reminder.isCompleted || _firedIds.contains(reminder.id)) continue;

      final scheduled = _asLocal(reminder.scheduledAt);
      final delta = now.difference(scheduled);

      // Fire when scheduled time has passed (within 2 minutes window).
      if (delta.inSeconds >= 0 && delta.inSeconds <= 120) {
        _firedIds.add(reminder.id);
        await _alertLauncher.openFromNotification(reminder.id);
      }
    }
  }

  void clearFired(String reminderId) => _firedIds.remove(reminderId);

  static DateTime _asLocal(DateTime value) =>
      value.isUtc ? value.toLocal() : value;
}
