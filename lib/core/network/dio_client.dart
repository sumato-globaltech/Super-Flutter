import 'package:dio/dio.dart';
import 'package:super_flutter/core/network/network_constants.dart';

import '../../app/config/environment.dart';
import '../logging/app_logger.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';

class DioClient {
  DioClient({
    required this._environment,
    required SecureStorage secureStorage,
    required this._logger,
    required Future<void> Function() onSessionExpired,
  }) {
    _refreshClient = _createDio()..interceptors.addAll(_supportInterceptors());

    _dio = _createDio()
      ..interceptors.addAll([
        AuthInterceptor(secureStorage: secureStorage),
        RefreshTokenInterceptor(
          secureStorage: secureStorage,
          tokenClient: _refreshClient,
          onSessionExpired: onSessionExpired,
        ),
        ..._supportInterceptors(),
      ]);
  }

  final Environment _environment;
  final AppLogger _logger;

  late final Dio _dio;

  late final Dio _refreshClient;

  Dio _createDio() => Dio(
    BaseOptions(
      baseUrl: _environment.apiBaseUrl,
      connectTimeout: _environment.connectTimeout,
      receiveTimeout: _environment.receiveTimeout,
      sendTimeout: _environment.sendTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const {
        NetworkConstants.acceptHeader: NetworkConstants.applicationJson,
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );

  Dio get dio => _dio;

  /// Points both the main and refresh clients at [baseUrl], e.g. a Remote
  /// Config override applied at startup before any request is sent.
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    _refreshClient.options.baseUrl = baseUrl;
  }

  List<Interceptor> _supportInterceptors() => [
    if (_environment.enableHttpLogging) LoggingInterceptor(logger: _logger),
    const ErrorInterceptor(),
  ];

  void close() {
    _dio.close(force: true);
    _refreshClient.close(force: true);
  }
}
