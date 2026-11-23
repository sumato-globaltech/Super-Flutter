import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/market/model/market_model.dart';
import 'package:super_flutter/data/market/model/market_price_model.dart';
import 'package:super_flutter/data/market/model/market_summary_model.dart';

import 'market_endpoints.dart';

@lazySingleton
class MarketRemoteDataSource {
  MarketRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET /api/v1/markets
  Future<Paged<MarketModel>> getMarkets({
    String? districtId,
    double? latitude,
    double? longitude,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        MarketEndpoints.markets,
        queryParameters: <String, dynamic>{
          'district_id': ?districtId,
          'latitude': ?latitude,
          'longitude': ?longitude,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(response.data),
          (json) => MarketModel.fromJson(json),
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

  /// GET /api/v1/markets/summary
  Future<MarketSummaryModel?> getSummary({String? districtId}) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        MarketEndpoints.summary,
        queryParameters: <String, dynamic>{
          'district_id': ?districtId,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return MarketSummaryModel.fromJson(Map<String, dynamic>.from(data));
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

  /// GET /api/v1/markets/{market}/prices
  Future<Paged<MarketPriceModel>> getPriceHistory({
    required String marketId,
    String? crop,
    String? from,
    String? to,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        MarketEndpoints.prices(marketId),
        queryParameters: <String, dynamic>{
          'crop': ?crop,
          'from': ?from,
          'to': ?to,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(data),
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

  /// GET /api/v1/markets/favourites
  Future<Paged<MarketModel>> getFavourites({
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        MarketEndpoints.favourites,
        queryParameters: <String, dynamic>{
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(data),
          (json) => MarketModel.fromJson(json).copyWith(isFavourite: true),
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

  /// POST /api/v1/markets/{market}/favourite
  Future<MarketModel?> addFavourite(String marketId) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        MarketEndpoints.favourite(marketId),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return MarketModel.fromJson(Map<String, dynamic>.from(data))
            .copyWith(isFavourite: true);
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

  /// DELETE /api/v1/markets/{market}/favourite
  Future<void> removeFavourite(String marketId) async {
    try {
      await _dioClient.dio.delete<dynamic>(
        MarketEndpoints.favourite(marketId),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }
}
