import 'package:equatable/equatable.dart';

import '../../../../domain/auth/entities/auth_status.dart';

export '../../../../domain/auth/entities/auth_status.dart';

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown});

  final AuthStatus status;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status];
}
