import 'package:dio/dio.dart';

import '../network_exception_mapper.dart';

class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: NetworkException.fromDioException(err)));
  }
}
