import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindloop/domain/entities/reminder_entity.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/presentation/screens/analytics/analytics_screen.dart';
import 'package:mindloop/presentation/screens/auth/forgot_password_screen.dart';
import 'package:mindloop/presentation/screens/auth/login_screen.dart';
import 'package:mindloop/presentation/screens/auth/signup_screen.dart';
import 'package:mindloop/presentation/screens/budget/budget_screen.dart';
import 'package:mindloop/presentation/screens/calendar/calendar_screen.dart';
import 'package:mindloop/presentation/screens/calculator/calculator_screen.dart';
import 'package:mindloop/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:mindloop/presentation/screens/future/future_features_screen.dart';
import 'package:mindloop/presentation/screens/home/home_shell.dart';
import 'package:mindloop/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:mindloop/presentation/screens/profile/profile_screen.dart';
import 'package:mindloop/presentation/screens/reminder/reminder_alert_screen.dart';
import 'package:mindloop/presentation/screens/reminder/reminder_create_screen.dart';
import 'package:mindloop/presentation/screens/reminder/reminder_detail_screen.dart';
import 'package:mindloop/presentation/screens/settings/settings_screen.dart';
import 'package:mindloop/presentation/screens/splash/splash_screen.dart';

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
        final isAlert = loc == '/alert';
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
            GoRoute(path: '/budget', builder: (_, __) => const BudgetScreen()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
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
        GoRoute(path: '/future', builder: (_, __) => const FutureFeaturesScreen()),
        GoRoute(path: '/calculator', builder: (_, __) => const CalculatorScreen()),
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
