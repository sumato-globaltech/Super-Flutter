import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/parse_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/service/device_info_service.dart';
import 'package:super_flutter/data/auth/model/user_model.dart';

import '../../model/login_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dioClient, this._deviceInfo);

  final DioClient _dioClient;
  final DeviceInfoService _deviceInfo;

  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
          'device_name': await _deviceInfo.deviceName(),
        },
      );

      final body = response.data;
      if (body is! Map) {
        throw const ParseException('Unexpected login response.');
      }
      if (body['success'] == false) {
        final message = (body['message'] as String?) ?? 'Login failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }

      final data = body['data'];
      if (data is! Map) {
        throw const ParseException('Login response is missing data.');
      }

      final result = LoginModel.fromJson(Map<String, dynamic>.from(data));
      final token = result.accessToken;
      if (token == null || token.isEmpty || result.user == null) {
        throw const ParseException('Login response is missing the token.');
      }
      return result;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParseException('Could not process login response.', e);
    }
  }

  /// GET http://dam.test/api/v1/me
  Future<UserModel> getMe() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(ApiEndpoints.me);
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected me response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The me request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! Map) {
        throw const NetworkException('The me response is missing data.');
      }
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Could not process the me response.', cause: e);
    }
  }

  /// POST http://dam.test/api/v1/logout
  Future<bool> logout() async {
    try {
      final response = await _dioClient.dio.post<dynamic>(ApiEndpoints.logout);
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The logout request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      return true;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the logout response.',
        cause: e,
      );
    }
  }

  /// POST http://dam.test/api/v1/logout-all
  Future<bool> logoutAll() async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.logoutAll,
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The logout all request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      return true;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the logout all response.',
        cause: e,
      );
    }
  }

  /// POST http://dam.test/api/v1/otp/request
  /// Seconds the sent code stays valid, from `meta.expires_in`.
  Future<int> requestOtp({required String phone}) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.requestOtp,
        data: <String, dynamic>{'phone': phone},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The request otp request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      final meta = body is Map ? body['meta'] : null;
      final expiresIn = meta is Map ? meta['expires_in'] : null;
      return expiresIn is int ? expiresIn : int.tryParse('$expiresIn') ?? 300;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the request otp response.',
        cause: e,
      );
    }
  }

  /// POST http://dam.test/api/v1/otp/verify
  Future<LoginModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.verifyOtp,
        data: <String, dynamic>{
          'phone': phone,
          'otp': otp,
          'device_name': await _deviceInfo.deviceName(),
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The verify otp request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      if (body is! Map) {
        throw const NetworkException('Unexpected verify otp response.');
      }
      final data = body['data'];
      if (data is! Map) {
        throw const NetworkException(
          'The verify otp response is missing data.',
        );
      }
      final result = LoginModel.fromJson(Map<String, dynamic>.from(data));
      final token = result.accessToken;
      if (token == null || token.isEmpty || result.user == null) {
        throw const ParseException('Login response is missing the token.');
      }
      return result;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the verify otp response.',
        cause: e,
      );
    }
  }

  /// PUT http://dam.test/api/v1/profile/password
  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        ApiEndpoints.changePassword,
        data: <String, dynamic>{
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The change password request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      return true;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the change password response.',
        cause: e,
      );
    }
  }
}
