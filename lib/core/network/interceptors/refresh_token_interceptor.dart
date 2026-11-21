import 'package:dio/dio.dart';
import 'package:super_flutter/core/network/network_constants.dart';

import '../../error/exceptions/unauthorized_exception.dart';
import '../../storage/secure_storage.dart';
import '../api_endpoints.dart';

class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor({
    required this._secureStorage,
    required this._tokenClient,
    required this._onSessionExpired,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SecureStorage _secureStorage;
  final Dio _tokenClient;
  final Future<void> Function() _onSessionExpired;
  final DateTime Function() _clock;

  static const _retriedKey = 'auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!ApiEndpoints.isPublic(options.path) && _isNearExpiry()) {
      final token = await _refreshToken();
      if (token != null) {
        options.headers[NetworkConstants.authorizationHeader] =
            NetworkConstants.bearerToken(token);
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    if (err.response?.statusCode != 401 ||
        options.extra[_retriedKey] == true ||
        ApiEndpoints.isPublic(options.path)) {
      handler.next(err);
      return;
    }

    final sentToken = options.headers[NetworkConstants.authorizationHeader];
    final storedToken = _secureStorage.accessToken;

    if (storedToken != null &&
        storedToken.isNotEmpty &&
        sentToken != NetworkConstants.bearerToken(storedToken)) {
      await _replay(options, storedToken, handler);
      return;
    }

    await _secureStorage.clearTokens();
    await _onSessionExpired();
    handler.next(
      err.copyWith(error: UnauthorizedException('Session expired.', err)),
    );
  }

  bool _isNearExpiry() {
    final token = _secureStorage.accessToken;
    final expiresAt = _secureStorage.expiresAt;
    if (token == null || token.isEmpty || expiresAt == null) {
      return false;
    }
    final now = _clock();
    return now.isBefore(expiresAt) &&
        !now.isBefore(expiresAt.subtract(NetworkConstants.tokenRefreshWindow));
  }

  Future<String?> _refreshToken() async {
    final current = _secureStorage.accessToken;
    if (current == null || current.isEmpty) {
      return null;
    }

    try {
      final response = await _tokenClient.post<dynamic>(
        ApiEndpoints.tokenRefresh,
        options: Options(
          headers: {
            NetworkConstants.authorizationHeader: NetworkConstants.bearerToken(
              current,
            ),
          },
        ),
      );

      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map) {
        return null;
      }

      final accessToken = data['access_token'];
      if (accessToken is! String || accessToken.isEmpty) {
        return null;
      }

      await _secureStorage.saveTokens(
        accessToken: accessToken,
        expiresAt: DateTime.tryParse('${data['expires_at']}'),
      );
      return accessToken;
    } on DioException {
      return null;
    }
  }

  Future<void> _replay(
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
