import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/core/di/injection.dart';
import 'package:mindloop/domain/repositories/reminder_repository.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/presentation/blocs/budget/budget_bloc.dart';
import 'package:mindloop/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:mindloop/routes/app_router.dart';
import 'package:mindloop/services/notification_service.dart';
import 'package:mindloop/services/reminder_alert_launcher.dart';
import 'package:mindloop/services/reminder_alarm_coordinator.dart';
import 'package:mindloop/services/reminder_due_watcher.dart';
import 'package:mindloop/themes/app_theme.dart';

class MindLoopApp extends StatefulWidget {
  const MindLoopApp({super.key});

  @override
  State<MindLoopApp> createState() => _MindLoopAppState();
}

class _MindLoopAppState extends State<MindLoopApp> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final ReminderBloc _reminderBloc;
  late final BudgetBloc _budgetBloc;
  late final GoRouter _router;
  late final ReminderAlertLauncher _alertLauncher;
  late final ReminderDueWatcher _dueWatcher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authBloc = sl<AuthBloc>()..add(AuthCheckRequested());
    _reminderBloc = sl<ReminderBloc>()..add(const RemindersLoadRequested());
    _budgetBloc = sl<BudgetBloc>()..add(const BudgetLoadRequested());
    _router = AppRouter.create(_authBloc);
    _alertLauncher = ReminderAlertLauncher(
      router: _router,
      repository: sl<ReminderRepository>(),
    );
    _dueWatcher = ReminderDueWatcher(
      repository: sl<ReminderRepository>(),
      alertLauncher: _alertLauncher,
    );
    ReminderAlarmCoordinator.dueWatcher = _dueWatcher;
    unawaited(_wireNotifications());
  }

  Future<void> _wireNotifications() async {
    final notifications = sl<NotificationService>();
    notifications.onReminderAlert = _alertLauncher.openFromNotification;
    await notifications.init(
      onReminderAlert: _alertLauncher.openFromNotification,
    );
    if (!kIsWeb) {
      _dueWatcher.start();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reminderBloc.add(const RemindersLoadRequested());
      if (!kIsWeb) {
        _dueWatcher.start();
      }
    } else if (state == AppLifecycleState.paused) {
      _dueWatcher.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dueWatcher.stop();
    _authBloc.close();
    _reminderBloc.close();
    _budgetBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _reminderBloc),
        BlocProvider.value(value: _budgetBloc),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
