import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/parse_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/service/device_info_service.dart';

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
}
