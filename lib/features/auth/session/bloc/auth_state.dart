import 'package:equatable/equatable.dart';

import '../../../../domain/auth/entities/access_policy.dart';
import '../../../../domain/auth/entities/auth_status.dart';
import '../../../../domain/auth/entities/user.dart';

export '../../../../domain/auth/entities/auth_status.dart';

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user});

  final AuthStatus status;
  final User? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AccessPolicy get access =>
      isAuthenticated ? AccessPolicy.fromUser(user) : AccessPolicy.guest;

  @override
  List<Object?> get props => [status, user];
}
