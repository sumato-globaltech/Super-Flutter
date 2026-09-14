import 'package:dio/dio.dart';
import 'package:starter/core/network/network_constants.dart';

import '../../constants/app_constants.dart';
import '../../error/exceptions/unauthorized_exception.dart';
import '../../storage/secure_storage.dart';
import '../api_endpoints.dart';

class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor({
    required SecureStorage secureStorage,
    required Dio tokenClient,
    required Future<void> Function() onSessionExpired,
  }) : _secureStorage = secureStorage,
       _tokenClient = tokenClient,
       _onSessionExpired = onSessionExpired;

  final SecureStorage _secureStorage;
  final Dio _tokenClient;
  final Future<void> Function() _onSessionExpired;

  static const _retriedKey = 'auth_retried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = options.extra[_retriedKey] == true;

    if (!isUnauthorized ||
        alreadyRetried ||
        ApiEndpoints.isPublic(options.path)) {
      handler.next(err);
      return;
    }

    final sentToken = options.headers[NetworkConstants.authorizationHeader];

    final storedToken = _secureStorage.accessToken;

    // Another request may already have refreshed the token.
    if (storedToken != null &&
        sentToken != NetworkConstants.bearerToken(storedToken)) {
      await _resolveReplay(options, storedToken, handler);
      return;
    }

    final refreshedToken = await _refreshTokens();

    if (refreshedToken == null) {
      await _secureStorage.clearTokens();
      await _onSessionExpired();

      handler.next(
        err.copyWith(error: UnauthorizedException('Session expired.', err)),
      );
      return;
    }

    await _resolveReplay(options, refreshedToken, handler);
  }

  Future<String?> _refreshTokens() async {
    final refreshToken = _secureStorage.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _tokenClient.post<dynamic>(
        ApiEndpoints.refresh,
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': NetworkConstants.accessTokenLifetimeMinutes,
        },
      );

      final body = response.data;

      if (body is! Map) {
        return null;
      }

      final accessToken = body['accessToken'];
      final newRefreshToken = body['refreshToken'];

      if (accessToken is! String || newRefreshToken is! String) {
        return null;
      }

      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );

      return accessToken;
    } on DioException {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<void> _resolveReplay(
    RequestOptions options,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final retryOptions = options.copyWith(
        headers: {
          ...options.headers,
          NetworkConstants.authorizationHeader: NetworkConstants.bearerToken(
            accessToken,
          ),
        },
        extra: {...options.extra, _retriedKey: true},
      );

      final response = await _tokenClient.fetch<dynamic>(retryOptions);

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
