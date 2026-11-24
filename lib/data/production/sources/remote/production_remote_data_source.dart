import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/production/model/production_insights_model.dart';

@lazySingleton
class ProductionRemoteDataSource {
  ProductionRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/production/insights
  Future<ProductionInsightsModel?> getProduction({
    int? month,
    String? crop,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.production,
        queryParameters: <String, dynamic>{'month': ?month, 'crop': ?crop},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return ProductionInsightsModel.fromJson(
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
