import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/interceptors/api_key_interceptor.dart';
import 'package:super_flutter/core/network/network_constants.dart';

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

void main() {
  late MockRequestInterceptorHandler handler;

  setUp(() => handler = MockRequestInterceptorHandler());

  test('sends the API key header', () {
    final options = RequestOptions(path: '/api/v1/crops');

    const ApiKeyInterceptor(apiKey: 'secret').onRequest(options, handler);

    expect(options.headers[NetworkConstants.apiKeyHeader], 'secret');
    verify(() => handler.next(options)).called(1);
  });

  test('sends no header when the key is empty', () {
    final options = RequestOptions(path: '/api/v1/crops');

    const ApiKeyInterceptor(apiKey: '').onRequest(options, handler);

    expect(options.headers.containsKey(NetworkConstants.apiKeyHeader), isFalse);
    verify(() => handler.next(options)).called(1);
  });
}
