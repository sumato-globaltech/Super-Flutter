import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/new_post_feature_dep/model/district_model.dart';

@lazySingleton
class NewPostFeatureDepRemoteDataSource {
  NewPostFeatureDepRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// POST http://dam.test/api/v1/deepPost
  Future<bool> createDeepPost({String? name, String? districtId}) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.deepPost,
        data: <String, dynamic>{'name': ?name, 'district_id': ?districtId},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The deep_post request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      return response.statusCode == 201;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the deep_post response.',
        cause: e,
      );
    }
  }

  /// GET http://dam.test/api/v1/districts
  Future<List<DistrictModel>> getDistricts() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.districts,
      );
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected districts response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The districts request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! List) {
        throw const NetworkException('The districts response is missing data.');
      }
      return data
          .whereType<Map>()
          .map(
            (item) => DistrictModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the districts response.',
        cause: e,
      );
    }
  }
}
