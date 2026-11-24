import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/facilities/model/facility_model.dart';
import 'package:super_flutter/data/facilities/model/facility_stats_model.dart';
import 'package:super_flutter/data/support/model/category_model.dart';

@lazySingleton
class FacilitiesRemoteDataSource {
  FacilitiesRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/facilities
  Future<Paged<FacilityModel>> getFacilities({
    String? categoryId,
    String? districtId,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.facilities,
        queryParameters: <String, dynamic>{
          'category_id': ?categoryId,
          'district_id': ?districtId,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          FacilityModel.fromJson,
        );
      }
      return const Paged(items: []);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      return const Paged(items: []);
    }
  }

  /// GET http://dam.test/api/v1/facilities/stats
  Future<FacilityStatsModel?> getFacilityStats({
    String? categoryId,
    String? districtId,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.facilityStats,
        queryParameters: <String, dynamic>{
          'category_id': ?categoryId,
          'district_id': ?districtId,
        },
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return FacilityStatsModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      return null;
    }
  }

  /// GET http://dam.test/api/v1/categories/facility_type
  Future<List<CategoryModel>> getFacilityTypes() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.facilityTypes,
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'];
        final items = data is List
            ? data
            : (data is Map && data['data'] is List
                  ? data['data'] as List
                  : null);
        if (items != null) {
          return items
              .whereType<Map>()
              .map(
                (item) =>
                    CategoryModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      return const [];
    }
  }
}
