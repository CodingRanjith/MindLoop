import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart';
import 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:mindloop/modules/finance/presentation/pages/analytics_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_analytics_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_budget_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_categories_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_dashboard_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_export_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_insights_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_notifications_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_goals_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_loans_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_net_worth_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/expense_reminder_alert_screen.dart';
import 'package:mindloop/modules/finance/presentation/pages/pfm_transactions_screen.dart';
import 'package:mindloop/modules/auth/presentation/pages/forgot_password_screen.dart';
import 'package:mindloop/modules/auth/presentation/pages/login_screen.dart';
import 'package:mindloop/modules/auth/presentation/pages/signup_screen.dart';
import 'package:mindloop/modules/reminder/presentation/pages/calendar_screen.dart';
import 'package:mindloop/modules/calculator/presentation/pages/calculator_screen.dart';
import 'package:mindloop/modules/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:mindloop/modules/future/presentation/pages/future_features_screen.dart';
import 'package:mindloop/modules/legal/presentation/pages/privacy_policy_screen.dart';
import 'package:mindloop/modules/legal/presentation/pages/terms_of_service_screen.dart';
import 'package:mindloop/modules/home/presentation/pages/home_shell.dart';
import 'package:mindloop/modules/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:mindloop/modules/pomodoro/presentation/pages/pomodoro_screen.dart';
import 'package:mindloop/modules/steps/presentation/pages/steps_screen.dart';
import 'package:mindloop/modules/profile/presentation/pages/profile_screen.dart';
import 'package:mindloop/modules/profile/presentation/pages/personal_info_screen.dart';
import 'package:mindloop/modules/reminder/presentation/pages/reminder_alert_screen.dart';
import 'package:mindloop/modules/reminder/presentation/pages/reminder_create_screen.dart';
import 'package:mindloop/modules/reminder/presentation/pages/reminder_detail_screen.dart';
import 'package:mindloop/modules/settings/presentation/pages/settings_screen.dart';
import 'package:mindloop/modules/onboarding/presentation/pages/splash_screen.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();

  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/splash',
      refreshListenable: _AuthRefresh(authBloc),
      redirect: (context, state) {
        final status = authBloc.state.status;
        final loc = state.matchedLocation;
        final isSplash = loc == '/splash';
        final isAuth = loc == '/login' || loc == '/signup' || loc == '/forgot';
        final isOnboarding = loc == '/onboarding';

        if (status == AuthStatus.unknown && !isSplash) return '/splash';
        if (status == AuthStatus.onboarding && !isOnboarding) return '/onboarding';
        if (status == AuthStatus.unauthenticated) {
          if (isOnboarding || isSplash || !isAuth) return '/login';
        }
        final isAlert = loc == '/alert' || loc == '/expense-alert';
        if (status == AuthStatus.authenticated &&
            (isAuth || isOnboarding || isSplash) &&
            !isAlert) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
        GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
            GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
            GoRoute(
              path: '/budget',
              redirect: (_, __) => '/finance/dashboard',
            ),
            GoRoute(
              path: '/finance',
              redirect: (_, __) => '/finance/dashboard',
            ),
            GoRoute(
              path: '/finance/dashboard',
              builder: (_, __) => const PfmDashboardScreen(),
            ),
            GoRoute(
              path: '/finance/transactions',
              builder: (_, __) => const PfmTransactionsScreen(),
            ),
            GoRoute(
              path: '/finance/analytics',
              builder: (_, __) => const PfmAnalyticsScreen(),
            ),
            GoRoute(
              path: '/finance/goals',
              builder: (_, __) => const PfmGoalsScreen(),
            ),
            GoRoute(path: '/finance/budget', builder: (_, __) => const PfmBudgetScreen()),
            GoRoute(path: '/finance/categories', builder: (_, __) => const PfmCategoriesScreen()),
            GoRoute(path: '/finance/loans', builder: (_, __) => const PfmLoansScreen()),
            GoRoute(path: '/finance/net-worth', builder: (_, __) => const PfmNetWorthScreen()),
            GoRoute(path: '/finance/export', builder: (_, __) => const PfmExportScreen()),
            GoRoute(path: '/finance/insights', builder: (_, __) => const PfmInsightsScreen()),
            GoRoute(path: '/finance/notifications', builder: (_, __) => const PfmNotificationsScreen()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
        GoRoute(path: '/profile/info', builder: (_, __) => const PersonalInfoScreen()),
        GoRoute(
          path: '/reminder/create',
          builder: (_, state) {
            final extra = state.extra;
            return ReminderCreateScreen(
              initialReminder: extra is ReminderEntity ? extra : null,
            );
          },
        ),
        GoRoute(
          path: '/reminder/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ReminderDetailScreen(reminderId: id);
          },
        ),
        GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),
        GoRoute(path: '/terms', builder: (_, __) => const TermsOfServiceScreen()),
        GoRoute(path: '/future', builder: (_, __) => const FutureFeaturesScreen()),
        GoRoute(path: '/calculator', builder: (_, __) => const CalculatorScreen()),
        GoRoute(path: '/pomodoro', builder: (_, __) => const PomodoroScreen()),
        GoRoute(path: '/steps', builder: (_, __) => const StepsScreen()),
        GoRoute(
          path: '/alert',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is ReminderEntity) {
              return ReminderAlertScreen(reminder: extra);
            }
            return ReminderAlertScreen.demo();
          },
        ),
        GoRoute(
          path: '/expense-alert',
          builder: (context, state) {
            final payload = state.extra is String ? state.extra as String : null;
            return ExpenseReminderAlertScreen(payload: payload);
          },
        ),
      ],
    );
  }
}

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._bloc) {
    _bloc.stream.listen((_) => notifyListeners());
  }
  final AuthBloc _bloc;
}
