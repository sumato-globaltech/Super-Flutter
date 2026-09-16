import 'package:equatable/equatable.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
  });

  final AuthStatus status;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status];
}