import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/parse_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/service/device_info_service.dart';
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart';

class _Client extends Mock implements DioClient {}

class _Device extends Mock implements DeviceInfoService {}

/// Answers every request with [status] and [body], and keeps what was sent.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.body);

  final int status;
  final Map<String, dynamic> body;
  RequestOptions? sent;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthRemoteDataSource _source(_Adapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://dam.test'))
    ..httpClientAdapter = adapter;
  final client = _Client();
  when(() => client.dio).thenReturn(dio);
  final device = _Device();
  when(() => device.deviceName()).thenAnswer((_) async => 'Pixel 9');
  return AuthRemoteDataSource(client, device);
}

const _user = {
  'id': 'u1',
  'name': 'Ramesh',
  'email': 'r@test.in',
  'phone': '9876543210',
};

void main() {
  test('requestOtp sends the phone and reads meta.expires_in', () async {
    final adapter = _Adapter(200, {
      'success': true,
      'message': 'If this number is registered, an OTP has been sent.',
      'data': null,
      'meta': {'expires_in': 300},
    });

    expect(await _source(adapter).requestOtp(phone: '9876543210'), 300);
    expect(adapter.sent!.path, '/api/v1/otp/request');
    expect(adapter.sent!.data, {'phone': '9876543210'});
  });

  test('requestOtp without meta assumes five minutes', () async {
    final adapter = _Adapter(200, {'success': true, 'data': null});
    expect(await _source(adapter).requestOtp(phone: '9876543210'), 300);
  });

  test('verifyOtp sends the device name and returns the session', () async {
    final adapter = _Adapter(201, {
      'success': true,
      'message': 'Logged in.',
      'data': {
        'token_type': 'Bearer',
        'access_token': '7|xyz',
        'expires_at': '2026-12-14T13:03:59+05:30',
        'password_change_required': true,
        'user': _user,
      },
    });

    final result = await _source(adapter)
        .verifyOtp(phone: '9876543210', otp: '123456');

    expect(result.accessToken, '7|xyz');
    expect(result.passwordChangeRequired, isTrue);
    expect(result.user?.phone, '9876543210');
    expect(adapter.sent!.data, {
      'phone': '9876543210',
      'otp': '123456',
      'device_name': 'Pixel 9',
    });
  });

  test('a wrong code is a field error on otp', () async {
    final adapter = _Adapter(422, {
      'success': false,
      'message': 'The OTP is invalid or has expired.',
      'errors': {
        'otp': ['The OTP is invalid or has expired.'],
      },
    });

    await expectLater(
      _source(adapter).verifyOtp(phone: '9876543210', otp: '000000'),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.fieldErrors['otp'],
          'otp error',
          'The OTP is invalid or has expired.',
        ),
      ),
    );
  });

  test('a session without a token is refused', () async {
    final adapter = _Adapter(201, {
      'success': true,
      'data': {'user': _user},
    });
    await expectLater(
      _source(adapter).verifyOtp(phone: '9876543210', otp: '123456'),
      throwsA(isA<ParseException>()),
    );
  });

  test(
    'getMe reads the user; logout and logoutAll post to their endpoints',
    () async {
      final me = _Adapter(200, {'success': true, 'data': _user});
      expect((await _source(me).getMe()).name, 'Ramesh');
      expect(me.sent!.path, '/api/v1/me');

      final out = _Adapter(200, {
        'success': true,
        'message': 'Logged out.',
        'data': null,
      });
      expect(await _source(out).logout(), isTrue);
      expect(out.sent!.path, '/api/v1/logout');

      final all = _Adapter(200, {
        'success': true,
        'message': 'Logged out from all devices.',
        'data': null,
      });
      expect(await _source(all).logoutAll(), isTrue);
      expect(all.sent!.path, '/api/v1/logout-all');
    },
  );
}
