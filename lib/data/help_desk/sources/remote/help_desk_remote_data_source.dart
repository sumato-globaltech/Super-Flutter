import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/help_desk/model/queue_summary_model.dart';

@lazySingleton
class HelpDeskRemoteDataSource {
  HelpDeskRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/agent/queue-summary
  Future<QueueSummaryModel?> getQueueSummary() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.queueSummary,
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return QueueSummaryModel.fromJson(Map<String, dynamic>.from(data));
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
