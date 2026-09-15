import 'package:equatable/equatable.dart';

import 'auth_token.dart';
import 'user.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.user, required this.tokens});

  final User user;
  final AuthTokens tokens;

  @override
  List<Object?> get props => [user, tokens];

  @override
  String toString() => 'AuthSession(user: ${user.username}, tokens: ***)';
}
