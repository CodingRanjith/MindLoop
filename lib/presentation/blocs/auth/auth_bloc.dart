import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindloop/core/utils/user_friendly_errors.dart';
import 'package:mindloop/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthOnboardingCompleted>(_onOnboarding);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final onboarding = await _authRepository.isOnboardingComplete();
    if (!onboarding) {
      emit(state.copyWith(status: AuthStatus.onboarding));
      return;
    }
    final loggedIn = await _authRepository.isLoggedIn();
    if (loggedIn) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userName: await _authRepository.getUserName(),
        userEmail: await _authRepository.getUserEmail(),
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _authRepository.login(email: event.email, password: event.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userName: await _authRepository.getUserName(),
        userEmail: await _authRepository.getUserEmail(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: UserFriendlyErrors.format(e),
      ));
    }
  }

  Future<void> _onSignup(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _authRepository.signup(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userName: await _authRepository.getUserName(),
        userEmail: await _authRepository.getUserEmail(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: UserFriendlyErrors.format(e),
      ));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> _onOnboarding(
    AuthOnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.completeOnboarding();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}
