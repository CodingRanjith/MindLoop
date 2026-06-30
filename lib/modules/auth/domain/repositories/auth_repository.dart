abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<bool> isOnboardingComplete();
  Future<void> completeOnboarding();
  Future<void> login({required String email, required String password});
  Future<void> signup({required String name, required String email, required String password});
  Future<void> logout();
  Future<String?> getUserName();
  Future<String?> getUserEmail();
}
