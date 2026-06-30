import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/app/di/injection.dart';
import 'package:mindloop/modules/reminder/domain/repositories/reminder_repository.dart';
import 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:mindloop/modules/finance/presentation/bloc/budget_bloc.dart';
import 'package:mindloop/modules/finance/presentation/bloc/pfm_bloc.dart';
import 'package:mindloop/modules/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:mindloop/app/router/app_router.dart';
import 'package:mindloop/modules/finance/services/expense_reminder_alert_launcher.dart';
import 'package:mindloop/modules/finance/services/expense_reminder_service.dart';
import 'package:mindloop/core/services/notification_service.dart';
import 'package:mindloop/modules/reminder/services/reminder_alert_launcher.dart';
import 'package:mindloop/modules/reminder/services/reminder_alarm_coordinator.dart';
import 'package:mindloop/modules/reminder/services/reminder_due_watcher.dart';
import 'package:mindloop/core/utils/app_responsive.dart';
import 'package:mindloop/core/utils/theme_preferences.dart';
import 'package:mindloop/shared/theme/app_theme.dart';
import 'package:mindloop/shared/widgets/app_feedback.dart';
import 'package:mindloop/shared/widgets/keyboard_dismiss_scope.dart';

class MindLoopApp extends StatefulWidget {
  const MindLoopApp({super.key});

  @override
  State<MindLoopApp> createState() => _MindLoopAppState();
}

class _MindLoopAppState extends State<MindLoopApp> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final ReminderBloc _reminderBloc;
  late final BudgetBloc _budgetBloc;
  late final PfmBloc _pfmBloc;
  late final GoRouter _router;
  late final ReminderAlertLauncher _alertLauncher;
  late final ExpenseReminderAlertLauncher _expenseAlertLauncher;
  late final ReminderDueWatcher _dueWatcher;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ThemePreferences.onChanged = _loadThemeMode;
    unawaited(_loadThemeMode());
    _authBloc = sl<AuthBloc>()..add(AuthCheckRequested());
    _reminderBloc = sl<ReminderBloc>()..add(const RemindersLoadRequested());
    _pfmBloc = sl<PfmBloc>()
      ..add(const PfmLoadRequested())
      ..add(const PfmProcessRecurringRequested());
    _budgetBloc = sl<BudgetBloc>()..add(const BudgetLoadRequested());
    _router = AppRouter.create(_authBloc);
    _alertLauncher = ReminderAlertLauncher(
      router: _router,
      repository: sl<ReminderRepository>(),
    );
    _expenseAlertLauncher = ExpenseReminderAlertLauncher(router: _router);
    _dueWatcher = ReminderDueWatcher(
      repository: sl<ReminderRepository>(),
      alertLauncher: _alertLauncher,
    );
    ReminderAlarmCoordinator.dueWatcher = _dueWatcher;
    unawaited(_wireNotifications());
  }

  Future<void> _loadThemeMode() async {
    final mode = await ThemePreferences.getThemeMode();
    if (mounted) setState(() => _themeMode = mode);
  }

  Future<void> _wireNotifications() async {
    final notifications = sl<NotificationService>();
    notifications.onReminderAlert = _alertLauncher.openFromNotification;
    notifications.onExpenseReminderAlert = _expenseAlertLauncher.openFromNotification;
    await notifications.init(
      onReminderAlert: _alertLauncher.openFromNotification,
    );
    if (!kIsWeb) {
      _dueWatcher.start();
      await sl<ExpenseReminderService>().reschedule();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reminderBloc.add(const RemindersLoadRequested());
      _pfmBloc
        ..add(const PfmProcessRecurringRequested())
        ..add(const PfmLoadRequested());
      _budgetBloc.add(const BudgetLoadRequested());
      if (!kIsWeb) {
        _dueWatcher.start();
        unawaited(sl<ExpenseReminderService>().reschedule());
      }
    } else if (state == AppLifecycleState.paused) {
      _dueWatcher.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ThemePreferences.onChanged = null;
    _dueWatcher.stop();
    _authBloc.close();
    _reminderBloc.close();
    _budgetBloc.close();
    _pfmBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _reminderBloc),
        BlocProvider.value(value: _budgetBloc),
        BlocProvider.value(value: _pfmBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          AppFeedback.showError(context, state.errorMessage!);
        },
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          routerConfig: _router,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: AppResponsive.clampTextScaler(media.textScaler),
              ),
              child: KeyboardDismissScope(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}
