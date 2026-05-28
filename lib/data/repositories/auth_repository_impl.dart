import 'package:mindloop/core/constants/app_constants.dart';
import 'package:mindloop/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> isLoggedIn() async =>
      _prefs.getBool(AppConstants.prefsLoggedIn) ?? false;

  @override
  Future<bool> isOnboardingComplete() async =>
      _prefs.getBool(AppConstants.prefsOnboarding) ?? false;

  @override
  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.prefsOnboarding, true);
  }

  @override
  Future<void> login({required String email, required String password}) async {
    if (email.isEmpty || password.length < 6) {
      throw Exception('Invalid email or password (min 6 characters)');
    }
    await _prefs.setBool(AppConstants.prefsLoggedIn, true);
    await _prefs.setString(AppConstants.prefsUserEmail, email);
    await _prefs.setString(
      AppConstants.prefsUserName,
      email.split('@').first,
    );
  }

  @override
  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.isEmpty || email.isEmpty || password.length < 6) {
      throw Exception('Please fill all fields (password min 6 characters)');
    }
    await _prefs.setBool(AppConstants.prefsLoggedIn, true);
    await _prefs.setString(AppConstants.prefsUserEmail, email);
    await _prefs.setString(AppConstants.prefsUserName, name);
  }

  @override
  Future<void> logout() async {
    await _prefs.setBool(AppConstants.prefsLoggedIn, false);
  }

  @override
  Future<String?> getUserName() async =>
      _prefs.getString(AppConstants.prefsUserName);

  @override
  Future<String?> getUserEmail() async =>
      _prefs.getString(AppConstants.prefsUserEmail);
}
