import 'package:get_it/get_it.dart';
import 'package:mindloop/data/repositories/auth_repository_impl.dart';
import 'package:mindloop/data/repositories/budget_repository_impl.dart';
import 'package:mindloop/data/repositories/reminder_repository_impl.dart';
import 'package:mindloop/domain/repositories/auth_repository.dart';
import 'package:mindloop/domain/repositories/budget_repository.dart';
import 'package:mindloop/domain/repositories/reminder_repository.dart';
import 'package:mindloop/presentation/blocs/auth/auth_bloc.dart';
import 'package:mindloop/presentation/blocs/budget/budget_bloc.dart';
import 'package:mindloop/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:mindloop/services/custom_ringtone_service.dart';
import 'package:mindloop/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<NotificationService>(NotificationService.new);
  sl.registerLazySingleton<CustomRingtoneService>(
    () => CustomRingtoneService(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReminderRepository>(ReminderRepositoryImpl.new);
  sl.registerLazySingleton<BudgetRepository>(BudgetRepositoryImpl.new);

  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerLazySingleton(() => ReminderBloc(sl(), sl()));
  sl.registerLazySingleton(() => BudgetBloc(sl()));
}
