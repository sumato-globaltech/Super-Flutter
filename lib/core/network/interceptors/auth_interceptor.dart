import 'package:dio/dio.dart';
import 'package:starter/core/storage/secure_storage.dart';

import '../../storage/storage_service.dart';
import '../network_constants.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorage secureStorage})
    : _secureStorage = secureStorage;

  final SecureStorage _secureStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _secureStorage.accessToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[NetworkConstants.authorizationHeader] =
          NetworkConstants.bearerToken(accessToken);
    }

    handler.next(options);
  }
}
