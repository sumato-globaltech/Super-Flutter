import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [accessToken, refreshToken];

  @override
  String toString() => 'AuthTokens(accessToken: ***, refreshToken: ***)';
}
