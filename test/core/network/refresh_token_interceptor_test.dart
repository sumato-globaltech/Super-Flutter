import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/unauthorized_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:super_flutter/core/network/network_constants.dart';
import 'package:super_flutter/core/storage/secure_storage.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

class MockDio extends Mock implements Dio {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

void main() {
  final now = DateTime.utc(2026, 11, 21, 12);

  late MockSecureStorage secureStorage;
  late MockDio tokenClient;
  late MockErrorInterceptorHandler errorHandler;
  late MockRequestInterceptorHandler requestHandler;
  late bool sessionExpired;
  late RefreshTokenInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '')),
    );
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  setUp(() {
    secureStorage = MockSecureStorage();
    tokenClient = MockDio();
    errorHandler = MockErrorInterceptorHandler();
    requestHandler = MockRequestInterceptorHandler();
    sessionExpired = false;

    when(() => secureStorage.clearTokens()).thenAnswer((_) async {});
    when(
      () => secureStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer((_) async {});

    interceptor = RefreshTokenInterceptor(
      secureStorage: secureStorage,
      tokenClient: tokenClient,
      onSessionExpired: () async => sessionExpired = true,
      clock: () => now,
    );
  });

  DioException unauthorized(RequestOptions options) => DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 401),
  );

  group('onRequest', () {
    void storeToken(DateTime? expiresAt) {
      when(() => secureStorage.accessToken).thenReturn('old-token');
      when(() => secureStorage.expiresAt).thenReturn(expiresAt);
    }

    test('does not refresh a token far from expiry', () async {
      storeToken(now.add(const Duration(days: 10)));
      final options = RequestOptions(path: '/api/v1/me');

      await interceptor.onRequest(options, requestHandler);

      verifyNever(
        () => tokenClient.post<dynamic>(any(), options: any(named: 'options')),
      );
      verify(() => requestHandler.next(options)).called(1);
    });

    test('refreshes a token inside the refresh window', () async {
      storeToken(now.add(const Duration(hours: 2)));
      when(
        () => tokenClient.post<dynamic>(
          ApiEndpoints.tokenRefresh,
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.tokenRefresh),
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Token refreshed.',
            'data': {
              'token_type': 'Bearer',
              'access_token': 'new-token',
              'expires_at': '2026-12-21T12:00:00+00:00',
            },
          },
        ),
      );
      final options = RequestOptions(path: '/api/v1/me');

      await interceptor.onRequest(options, requestHandler);

      final sent =
          verify(
                () => tokenClient.post<dynamic>(
                  ApiEndpoints.tokenRefresh,
                  options: captureAny(named: 'options'),
                ),
              ).captured.single
              as Options;
      expect(
        sent.headers?[NetworkConstants.authorizationHeader],
        'Bearer old-token',
      );
      verify(
        () => secureStorage.saveTokens(
          accessToken: 'new-token',
          expiresAt: DateTime.utc(2026, 12, 21, 12),
        ),
      ).called(1);
      expect(
        options.headers[NetworkConstants.authorizationHeader],
        'Bearer new-token',
      );
      verify(() => requestHandler.next(options)).called(1);
    });

    test('does not refresh an already expired token', () async {
      storeToken(now.subtract(const Duration(minutes: 1)));
      final options = RequestOptions(path: '/api/v1/me');

      await interceptor.onRequest(options, requestHandler);

      verifyNever(
        () => tokenClient.post<dynamic>(any(), options: any(named: 'options')),
      );
      verify(() => requestHandler.next(options)).called(1);
    });

    test('does not refresh on public routes', () async {
      storeToken(now.add(const Duration(hours: 2)));
      final options = RequestOptions(path: ApiEndpoints.login);

      await interceptor.onRequest(options, requestHandler);

      verifyNever(
        () => tokenClient.post<dynamic>(any(), options: any(named: 'options')),
      );
      verify(() => requestHandler.next(options)).called(1);
    });

    test('keeps the request going when refresh fails', () async {
      storeToken(now.add(const Duration(hours: 2)));
      when(
        () => tokenClient.post<dynamic>(any(), options: any(named: 'options')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
      final options = RequestOptions(path: '/api/v1/me');

      await interceptor.onRequest(options, requestHandler);

      verifyNever(
        () => secureStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          expiresAt: any(named: 'expiresAt'),
        ),
      );
      verify(() => requestHandler.next(options)).called(1);
    });
  });

  group('onError', () {
    test('passes non-401 errors through', () async {
      final options = RequestOptions(path: '/api/v1/me');
      final error = DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 500),
      );

      await interceptor.onError(error, errorHandler);

      verify(() => errorHandler.next(error)).called(1);
      expect(sessionExpired, isFalse);
    });

    test('passes an already retried 401 through', () async {
      final error = unauthorized(
        RequestOptions(path: '/api/v1/me', extra: {'auth_retried': true}),
      );

      await interceptor.onError(error, errorHandler);

      verify(() => errorHandler.next(error)).called(1);
      expect(sessionExpired, isFalse);
    });

    test('passes a 401 from a public route through', () async {
      final error = unauthorized(RequestOptions(path: ApiEndpoints.login));

      await interceptor.onError(error, errorHandler);

      verify(() => errorHandler.next(error)).called(1);
      expect(sessionExpired, isFalse);
    });

    test('replays with the stored token when it changed meanwhile', () async {
      final options = RequestOptions(
        path: '/api/v1/me',
        headers: {NetworkConstants.authorizationHeader: 'Bearer old-token'},
      );
      when(() => secureStorage.accessToken).thenReturn('new-token');
      final replayed = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
      );
      when(() => tokenClient.fetch<dynamic>(any()))
          .thenAnswer((_) async => replayed);

      await interceptor.onError(unauthorized(options), errorHandler);

      final retry =
          verify(() => tokenClient.fetch<dynamic>(captureAny())).captured.single
              as RequestOptions;
      expect(
        retry.headers[NetworkConstants.authorizationHeader],
        'Bearer new-token',
      );
      verify(() => errorHandler.resolve(replayed)).called(1);
      expect(sessionExpired, isFalse);
    });

    test('ends the session on a 401 with the current token', () async {
      final options = RequestOptions(
        path: '/api/v1/me',
        headers: {NetworkConstants.authorizationHeader: 'Bearer old-token'},
      );
      when(() => secureStorage.accessToken).thenReturn('old-token');

      await interceptor.onError(unauthorized(options), errorHandler);

      verify(() => secureStorage.clearTokens()).called(1);
      expect(sessionExpired, isTrue);
      final forwarded =
          verify(() => errorHandler.next(captureAny())).captured.single
              as DioException;
      expect(forwarded.error, isA<UnauthorizedException>());
    });
  });
}
