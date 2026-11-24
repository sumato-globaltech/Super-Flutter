import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/crops/model/crop_advisory_model.dart';
import 'package:super_flutter/data/crops/model/crop_calendar_model.dart';
import 'package:super_flutter/data/crops/model/crop_economics_model.dart';
import 'package:super_flutter/data/crops/model/crop_fertilizers_model.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/model/crop_recommendation_model.dart';
import 'package:super_flutter/data/market/model/market_price_model.dart';

import 'crop_endpoints.dart';

@lazySingleton
class CropRemoteDataSource {
  CropRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET /api/v1/crops
  Future<Paged<CropModel>> getCrops({
    String? search,
    String? type,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.crops,
        queryParameters: <String, dynamic>{
          'search': ?search,
          'type': ?type,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(response.data as Map),
          CropModel.fromJson,
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

  /// GET /api/v1/crops/{crop}
  Future<CropModel?> getCrop(String slug) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.crop(slug),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return CropModel.fromJson(Map<String, dynamic>.from(data));
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

  /// GET /api/v1/crops/{crop}/advisory
  Future<CropAdvisoryModel?> getCropAdvisory(
    String slug, {
    String? districtId,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.advisory(slug),
        queryParameters: <String, dynamic>{'district_id': ?districtId},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return CropAdvisoryModel.fromJson(Map<String, dynamic>.from(data));
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

  /// GET /api/v1/crops/{crop}/calendar
  Future<CropCalendarModel?> getCropCalendar(
    String slug, {
    String? districtId,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.calendar(slug),
        queryParameters: <String, dynamic>{'district_id': ?districtId},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return CropCalendarModel.fromJson(Map<String, dynamic>.from(data));
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

  /// GET /api/v1/crops/{crop}/fertilizers
  Future<CropFertilizersModel?> getCropFertilizers(String slug) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.fertilizers(slug),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return CropFertilizersModel.fromJson(Map<String, dynamic>.from(data));
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

  /// GET /api/v1/crops/{crop}/economics
  Future<CropEconomicsModel?> getCropEconomics(
    String slug, {
    String? districtId,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.economics(slug),
        queryParameters: <String, dynamic>{'district_id': ?districtId},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return CropEconomicsModel.fromJson(Map<String, dynamic>.from(data));
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

  /// GET /api/v1/crops/{crop}/prices
  Future<Paged<MarketPriceModel>> getCropPrices(
    String slug, {
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.prices(slug),
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(response.data as Map),
          (json) => MarketPriceModel.fromJson(json),
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

  /// GET /api/v1/crops/sowing-months
  Future<List<MonthModel>> getSowingMonths({
    String? crop,
    String? districtId,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.sowingMonths,
        queryParameters: <String, dynamic>{
          'crop': ?crop,
          'district_id': ?districtId,
        },
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map && body['data'] is List) {
        return (body['data'] as List)
            .whereType<Map>()
            .map((item) => MonthModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
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

  /// GET /api/v1/crops/recommendations
  Future<CropRecommendationResultModel?> getRecommendations({
    required String districtId,
    required int sowingMonth,
    required double areaHa,
    List<String>? crops,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        CropEndpoints.recommendations,
        queryParameters: <String, dynamic>{
          'district_id': districtId,
          'sowing_month': sowingMonth,
          'area_ha': areaHa,
          'crops[]': ?crops,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return CropRecommendationResultModel.fromJson(
          Map<String, dynamic>.from(data),
        );
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
}
