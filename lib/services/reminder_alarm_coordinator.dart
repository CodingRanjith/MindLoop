import 'package:mindloop/services/reminder_due_watcher.dart';

/// App-level hook so blocs can reset foreground alarm state.
class ReminderAlarmCoordinator {
  ReminderAlarmCoordinator._();

  static ReminderDueWatcher? dueWatcher;

  static void clearFired(String reminderId) {
    dueWatcher?.clearFired(reminderId);
  }
}
