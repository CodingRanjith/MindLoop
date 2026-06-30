import 'package:go_router/go_router.dart';
import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';
import 'package:mindloop/modules/reminder/domain/repositories/reminder_repository.dart';

/// Opens the full-screen reminder alert when a notification fires or is tapped.
class ReminderAlertLauncher {
  ReminderAlertLauncher({
    required GoRouter router,
    required ReminderRepository repository,
  })  : _router = router,
        _repository = repository;

  final GoRouter _router;
  final ReminderRepository _repository;

  Future<void> openFromNotification(String reminderId) async {
    final reminder = await _repository.getReminderById(reminderId);
    if (reminder == null || reminder.isCompleted) return;
    _openAlert(reminder);
  }

  void _openAlert(ReminderEntity reminder) {
    final path = _router.state.uri.path;
    if (path == '/alert') {
      _router.replace('/alert', extra: reminder);
    } else {
      _router.push('/alert', extra: reminder);
    }
  }
}
