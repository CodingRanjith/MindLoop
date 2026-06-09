import 'package:go_router/go_router.dart';

/// Opens the full-screen expense tracking reminder when a notification is tapped.
class ExpenseReminderAlertLauncher {
  ExpenseReminderAlertLauncher({required GoRouter router}) : _router = router;

  final GoRouter _router;

  Future<void> openFromNotification([String? payload]) async {
    final path = _router.state.uri.path;
    if (path == '/expense-alert') {
      _router.replace('/expense-alert', extra: payload);
    } else {
      _router.push('/expense-alert', extra: payload);
    }
  }
}
