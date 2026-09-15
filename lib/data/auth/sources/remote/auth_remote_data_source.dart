import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:starter/core/network/api_endpoints.dart';
import 'package:starter/core/network/dio_client.dart';
import 'package:starter/core/network/network_constants.dart';
import 'package:starter/core/network/network_exception_mapper.dart';
import 'package:starter/domain/auth/entities/auth_token.dart';

import '../../model/user_model.dart';

class LoginResult {
  const LoginResult({required this.user, required this.tokens});

  final UserModel user;
  final AuthTokens tokens;
}

@lazySingleton
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// dummyjson: POST /auth/login {username, password, expiresInMins}
  /// -> {accessToken, refreshToken, id, username, email, firstName, lastName, image, ...}
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
          'expiresInMins': NetworkConstants.accessTokenLifetimeMinutes,
        },
      );
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected login response.');
      }
      final json = Map<String, dynamic>.from(body);
      final accessToken = json['accessToken'];
      final refreshToken = json['refreshToken'];
      if (accessToken is! String ||
          accessToken.isEmpty ||
          refreshToken is! String ||
          refreshToken.isEmpty) {
        throw const NetworkException('Login response is missing tokens.');
      }
      return LoginResult(
        user: UserModel.fromJson(json),
        tokens: AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Could not process login response.', cause: e);
    }
  }
}
