import 'dart:convert';

import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';
import '../network_constants.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    required this._logger,
    this.maxBodyLength = NetworkConstants.maxLoggedBodyLength,
  });

  final AppLogger _logger;
  final int maxBodyLength;

  static const _redactedHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      '--> ${options.method} ${options.uri}\n'
          'headers: ${_redact(options.headers)}\n'
          'body: ${_body(options.data)}',
      name: 'http',
    );
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response,
      ResponseInterceptorHandler handler,
      ) {
    final options = response.requestOptions;
    _logger.debug(
      '<-- ${response.statusCode} ${options.method} ${options.uri}\n'
          'body: ${_body(response.data)}',
      name: 'http',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    _logger.warning(
      '<-- ERROR ${err.response?.statusCode ?? err.type.name} '
          '${options.method} ${options.uri}\n'
          'message: ${err.message}\n'
          'body: ${_body(err.response?.data)}',
      name: 'http',
    );
    handler.next(err);
  }

  Map<String, dynamic> _redact(Map<String, dynamic> headers) => {
    for (final entry in headers.entries)
      entry.key: _redactedHeaders.contains(entry.key.toLowerCase())
          ? '***'
          : entry.value,
  };

  String _body(Object? data) {
    if (data == null) return '(empty)';
    if (data is FormData) {
      return 'FormData(fields: ${data.fields.map((f) => f.key).toList()}, '
          'files: ${data.files.map((f) => f.value.filename).toList()})';
    }
    var text = data is String ? data : _tryEncode(data);
    if (text.length > maxBodyLength) {
      text = '${text.substring(0, maxBodyLength)}… (${text.length} chars)';
    }
    return text;
  }

  String _tryEncode(Object data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } on Object {
      return data.toString();
    }
  }
}
