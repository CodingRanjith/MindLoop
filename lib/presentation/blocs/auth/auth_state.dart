part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  onboarding,
  unauthenticated,
  authenticated,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.userName,
    this.userEmail,
    this.errorMessage,
    this.isLoading = false,
  });

  final AuthStatus status;
  final String? userName;
  final String? userEmail;
  final String? errorMessage;
  final bool isLoading;

  AuthState copyWith({
    AuthStatus? status,
    String? userName,
    String? userEmail,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [status, userName, userEmail, errorMessage, isLoading];
}
