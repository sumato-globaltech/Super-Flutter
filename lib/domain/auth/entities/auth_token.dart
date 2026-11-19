import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
  });

  final String accessToken;
  final String tokenType;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && !DateTime.now().isBefore(expiresAt!);

  @override
  List<Object?> get props => [accessToken, tokenType, expiresAt];

  @override
  String toString() =>
      'AuthTokens(tokenType: $tokenType, accessToken: ***, expiresAt: $expiresAt)';
}
