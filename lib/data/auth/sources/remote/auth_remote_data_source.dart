import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/parse_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';

import '../../model/login_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final body = response.data;
      if (body is! Map) {
        throw const ParseException('Unexpected login response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'Login failed.',
          statusCode: response.statusCode,
        );
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
