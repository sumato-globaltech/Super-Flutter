import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:starter/core/network/network_constants.dart';
import 'package:starter/core/storage/secure_storage.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

class MockDio extends Mock implements Dio {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockSecureStorage secureStorage;
  late MockDio tokenClient;
  late MockErrorInterceptorHandler handler;

  late bool sessionExpired;
  late RefreshTokenInterceptor interceptor;

  setUp(() {
    secureStorage = MockSecureStorage();
    tokenClient = MockDio();
    handler = MockErrorInterceptorHandler();

    sessionExpired = false;

    when(() => secureStorage.clearTokens()).thenAnswer((_) async {});

    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '')),
    );

    interceptor = RefreshTokenInterceptor(
      secureStorage: secureStorage,
      tokenClient: tokenClient,
      onSessionExpired: () async {
        sessionExpired = true;
      },
    );
  });

  test('passes non-401 errors without refreshing token', () async {
    final options = RequestOptions(path: '/users', method: 'GET');

    final error = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 500),
    );

    await interceptor.onError(error, handler);

    verify(() => handler.next(error)).called(1);

    verifyNever(
      () => tokenClient.post<dynamic>(any(), data: any(named: 'data')),
    );

    expect(sessionExpired, false);
  });

  test('passes already retried 401 without refreshing again', () async {
    final options = RequestOptions(
      path: '/users',
      method: 'GET',
      extra: {'auth_retried': true},
    );

    final error = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 401),
    );

    await interceptor.onError(error, handler);

    verify(() => handler.next(error)).called(1);

    verifyNever(
      () => tokenClient.post<dynamic>(any(), data: any(named: 'data')),
    );
  });

  test('calls session expired when refresh token is missing', () async {
    final options = RequestOptions(
      path: '/users',
      method: 'GET',
      headers: {NetworkConstants.authorizationHeader: 'Bearer old-token'},
    );

    final error = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 401),
    );

    when(() => secureStorage.accessToken).thenReturn('old-token');
    when(() => secureStorage.refreshToken).thenReturn(null);

    await interceptor.onError(error, handler);

    expect(sessionExpired, true);

    verify(() => handler.next(any())).called(1);
  });
}
