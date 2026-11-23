import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/communication/model/alert_model.dart';
import 'package:super_flutter/data/communication/model/banner_model.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';

@lazySingleton
class CommunicationRemoteDataSource {
  CommunicationRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/notices/{notice}
  Future<NoticeModel> getNotice(String notice) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.notice(notice),
      );
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected notice response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The notice request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! Map) {
        throw const NetworkException('The notice response is missing data.');
      }
      return NoticeModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the notice response.',
        cause: e,
      );
    }
  }

  /// GET http://dam.test/api/v1/notices
  Future<Paged<NoticeModel>> getNotices({int? page, int? perPage}) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.notices,
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected notices response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The notices request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! List) {
        throw const NetworkException('The notices response is missing data.');
      }
      return Paged.fromEnvelope(
        Map<String, dynamic>.from(body),
        NoticeModel.fromJson,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the notices response.',
        cause: e,
      );
    }
  }

  /// GET http://dam.test/api/v1/alerts
  Future<Paged<AlertModel>> getAlerts({
    String? districtId,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.alerts,
        queryParameters: <String, dynamic>{
          'district_id': ?districtId,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected alerts response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The alerts request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! List) {
        throw const NetworkException('The alerts response is missing data.');
      }
      return Paged.fromEnvelope(
        Map<String, dynamic>.from(body),
        AlertModel.fromJson,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the alerts response.',
        cause: e,
      );
    }
  }

  /// GET http://dam.test/api/v1/banners
  Future<List<BannerModel>> getBanners({String? placement}) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.banners,
        queryParameters: <String, dynamic>{'placement': ?placement},
      );
      final body = response.data;
      if (body is! Map) {
        throw const NetworkException('Unexpected banners response.');
      }
      if (body['success'] == false) {
        throw BadRequestException(
          (body['message'] as String?) ?? 'The banners request failed.',
          statusCode: response.statusCode,
        );
      }
      final data = body['data'];
      if (data is! List) {
        throw const NetworkException('The banners response is missing data.');
      }
      return data
          .whereType<Map>()
          .map((item) => BannerModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Could not process the banners response.',
        cause: e,
      );
    }
  }
}
