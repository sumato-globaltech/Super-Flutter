import 'package:equatable/equatable.dart';

import 'auth_token.dart';
import 'user.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.tokens,
    this.passwordChangeRequired = false,
  });

  final User user;
  final AuthTokens tokens;
  final bool passwordChangeRequired;

  @override
  List<Object?> get props => [user, tokens, passwordChangeRequired];

  @override
  String toString() => 'AuthSession(user: ${user.email}, tokens: ***)';
}
