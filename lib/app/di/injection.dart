import 'package:get_it/get_it.dart';
import 'package:mindloop/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:mindloop/modules/finance/data/repositories/budget_repository_impl.dart';
import 'package:mindloop/modules/finance/data/repositories/pfm_repository_impl.dart';
import 'package:mindloop/modules/reminder/data/repositories/reminder_repository_impl.dart';
import 'package:mindloop/modules/auth/domain/repositories/auth_repository.dart';
import 'package:mindloop/modules/finance/domain/repositories/budget_repository.dart';
import 'package:mindloop/modules/finance/domain/repositories/pfm_repository.dart';
import 'package:mindloop/modules/reminder/domain/repositories/reminder_repository.dart';
import 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:mindloop/modules/finance/presentation/bloc/budget_bloc.dart';
import 'package:mindloop/modules/finance/presentation/bloc/pfm_bloc.dart';
import 'package:mindloop/modules/reminder/presentation/bloc/reminder_bloc.dart';
import 'package:mindloop/modules/reminder/services/custom_ringtone_service.dart';
import 'package:mindloop/modules/finance/services/finance_export_service.dart';
import 'package:mindloop/modules/finance/services/expense_reminder_service.dart';
import 'package:mindloop/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<NotificationService>(NotificationService.new);
  sl.registerLazySingleton(
    () => ExpenseReminderService(sl<NotificationService>()),
  );
  sl.registerLazySingleton<CustomRingtoneService>(
    () => CustomRingtoneService(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReminderRepository>(ReminderRepositoryImpl.new);
  sl.registerLazySingleton<PfmRepository>(PfmRepositoryImpl.new);
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(sl<PfmRepository>()),
  );
  sl.registerLazySingleton(FinanceExportService.new);

  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerLazySingleton(() => ReminderBloc(sl(), sl()));
  sl.registerLazySingleton(() => PfmBloc(sl()));
  sl.registerLazySingleton(() => BudgetBloc(sl<PfmRepository>()));
}
