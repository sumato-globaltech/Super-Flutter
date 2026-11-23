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
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected markets response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The markets request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! List) {
        throw const NetworkException('The markets response is missing data.');
      }
      return Paged.fromEnvelope(
        Map<String, dynamic>.from(body),
        (json) => MarketModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the markets response.',
        cause: e,
      );
    }
  }

  /// GET /api/v1/markets/summary
  Future<MarketSummaryModel> getSummary({String? districtId}) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        MarketEndpoints.summary,
        queryParameters: <String, dynamic>{
          'district_id': ?districtId,
        },
      );
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected market summary response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The market summary request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! Map) {
        throw const NetworkException('The market summary response is missing data.');
      }
      return MarketSummaryModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the market summary response.',
        cause: e,
      );
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
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected price history response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The price history request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! List) {
        throw const NetworkException('The price history response is missing data.');
      }
      return Paged.fromEnvelope(
        Map<String, dynamic>.from(body),
        (json) => MarketPriceModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the price history response.',
        cause: e,
      );
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
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected favourite markets response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The favourite markets request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! List) {
        throw const NetworkException('The favourite markets response is missing data.');
      }
      return Paged.fromEnvelope(
        Map<String, dynamic>.from(body),
        (json) => MarketModel.fromJson(json).copyWith(isFavourite: true),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the favourite markets response.',
        cause: e,
      );
    }
  }

  /// POST /api/v1/markets/{market}/favourite
  Future<MarketModel> addFavourite(String marketId) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        MarketEndpoints.favourite(marketId),
      );
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected add favourite response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'Could not add to favourites.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! Map) {
        throw const NetworkException('The add favourite response is missing data.');
      }
      return MarketModel.fromJson(Map<String, dynamic>.from(data))
          .copyWith(isFavourite: true);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the add favourite response.',
        cause: e,
      );
    }
  }

  /// DELETE /api/v1/markets/{market}/favourite
  Future<void> removeFavourite(String marketId) async {
    try {
      final response = await _dioClient.dio.delete<dynamic>(
        MarketEndpoints.favourite(marketId),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw BadRequestException(
          'Could not remove from favourites.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the remove favourite response.',
        cause: e,
      );
    }
  }
}
