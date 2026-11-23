import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/core/network/interceptors/password_policy_interceptor.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.body);

  final int status;
  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

Future<int> _calls(int status, Map<String, dynamic> body) async {
  var calls = 0;
  final dio = Dio()
    ..httpClientAdapter = _Adapter(status, body)
    ..interceptors.add(
      PasswordPolicyInterceptor(onPasswordChangeRequired: () => calls++),
    );
  try {
    await dio.get<dynamic>('http://dam.test/api/v1/markets');
  } on DioException {
    // Expected: the request was refused.
  }
  return calls;
}

void main() {
  test('a 403 with password_change_required is reported', () async {
    expect(
      await _calls(403, {
        'success': false,
        'message': 'You must change your password before continuing.',
        'meta': {'code': 'password_change_required', 'reason': 'expired'},
      }),
      1,
    );
  });

  test('any other 403 or error is not', () async {
    expect(await _calls(403, {'success': false, 'message': 'No access.'}), 0);
    expect(
      await _calls(401, {
        'meta': {'code': 'password_change_required'},
      }),
      0,
    );
  });
}
