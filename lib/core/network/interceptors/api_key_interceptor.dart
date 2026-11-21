import 'package:dio/dio.dart';

import '../network_constants.dart';

class ApiKeyInterceptor extends Interceptor {
  const ApiKeyInterceptor({required this.apiKey});

  final String apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (apiKey.isNotEmpty) {
      options.headers[NetworkConstants.apiKeyHeader] = apiKey;
    }
    handler.next(options);
  }
}
