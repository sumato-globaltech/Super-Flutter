import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/core/error/exceptions/forbidden_exception.dart';
import 'package:super_flutter/core/error/exceptions/unauthorized_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';

DioException badResponse(int status, Map<String, dynamic> body) {
  final options = RequestOptions(path: '/api/v1/farmer/farms');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  test('401 is an expired session', () {
    final error = NetworkException.fromDioException(
      badResponse(401, {
        'success': false,
        'message': 'Unauthenticated.',
        'data': null,
      }),
    );

    expect(error, isA<UnauthorizedException>());
    expect(error.message, 'Unauthenticated.');
  });

  test('403 is a denied action, not an expired session', () {
    final error = NetworkException.fromDioException(
      badResponse(403, {
        'success': false,
        'message': 'This account has no active farmer profile.',
        'data': null,
      }),
    );

    expect(error, isA<ForbiddenException>());
    expect(error.statusCode, 403);
    expect(error.message, 'This account has no active farmer profile.');
  });

  test('422 with errors is a validation failure per field', () {
    final error = NetworkException.fromDioException(
      badResponse(422, {
        'success': false,
        'message': 'The OTP is invalid or has expired.',
        'data': null,
        'errors': {
          'otp': ['The OTP is invalid or has expired.'],
        },
      }),
    );

    expect(error, isA<ValidationException>());
    expect((error as ValidationException).fieldErrors, {
      'otp': 'The OTP is invalid or has expired.',
    });
  });
}
