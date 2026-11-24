import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/publications/model/publication_model.dart';

@lazySingleton
class PublicationsRemoteDataSource {
  PublicationsRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/publications
  Future<Paged<PublicationModel>> getPublications({
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.publications,
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          PublicationModel.fromJson,
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
}
