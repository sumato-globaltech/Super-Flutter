import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/geo_map/model/crop_suitability_model.dart';
import 'package:super_flutter/data/geo_map/model/office_location_model.dart';
import 'package:super_flutter/data/geo_map/model/village_model.dart';
import 'package:super_flutter/data/geo_map/model/weather_models.dart';

import 'geo_map_endpoints.dart';

@lazySingleton
class GeoMapRemoteDataSource {
  GeoMapRemoteDataSource()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 20),
        ),
      );

  final Dio _dio;

  Future<List<OfficeLocationModel>> getOffices() async {
    try {
      final response = await _dio.get<dynamic>(
        GeoMapEndpoints.officeLocations,
        options: Options(
          headers: {
            'x-api-key': GeoMapEndpoints.officeApiKey,
            'Accept': Headers.jsonContentType,
          },
        ),
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map>()
            .map(
              (json) =>
                  OfficeLocationModel.fromJson(json.cast<String, dynamic>()),
            )
            .where((office) => office.latitude != 0 && office.longitude != 0)
            .toList(growable: false);
      }
      return const [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  Future<WeatherForecastModel> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        GeoMapEndpoints.weatherForecast,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': GeoMapEndpoints.weatherApiKey,
          'units': 'metric',
        },
      );
      final data = response.data;
      if (data is Map) {
        return WeatherForecastModel.fromJson(data.cast<String, dynamic>());
      }
      throw const FormatException('The weather service returned no forecast');
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  Future<List<CropSuitabilityModel>> getSuitability({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        GeoMapEndpoints.suitabilityPoint,
        queryParameters: {'lat': latitude, 'lng': longitude},
      );
      final data = response.data;
      if (data is Map && data['results'] is List) {
        return (data['results'] as List)
            .whereType<Map>()
            .map(
              (json) =>
                  CropSuitabilityModel.fromJson(json.cast<String, dynamic>()),
            )
            .toList(growable: false);
      }
      return const [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  /// Parses the bundled villages once for the search bar. The map itself
  /// loads the same dataset through its GeoJSON source.
  Future<List<VillageModel>> getVillages() async {
    try {
      final document = await rootBundle.loadString(
        GeoMapEndpoints.villagesAsset,
      );
      final decoded = jsonDecode(document);
      if (decoded is! Map || decoded['features'] is! List) return const [];
      return (decoded['features'] as List)
          .whereType<Map>()
          .map(
            (feature) =>
                VillageModel.fromFeature(feature.cast<String, dynamic>()),
          )
          .where((village) => village.name.isNotEmpty)
          .toList(growable: false);
    } catch (e) {
      throw NetworkException('Could not read the village dataset: $e');
    }
  }
}
