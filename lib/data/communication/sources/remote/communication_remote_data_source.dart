import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
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
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return NoticeModel.fromJson(Map<String, dynamic>.from(data));
      }
      return NoticeModel();
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
      if (response.statusCode == 200 && response.data is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(response.data),
          NoticeModel.fromJson,
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
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(data),
          AlertModel.fromJson,
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

  /// GET http://dam.test/api/v1/banners
  Future<List<BannerModel>> getBanners({String? placement}) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.banners,
        queryParameters: <String, dynamic>{'placement': ?placement},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map(
                (item) => BannerModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// POST http://dam.test/api/v1/devices
  Future<bool> createDevice({
    required String token,
    required String platform,
    String? deviceName,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.device,
        data: <String, dynamic>{
          'token': token,
          'platform': platform,
          'device_name': ?deviceName,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The device request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      return false;
    }
  }

  /// DELETE http://dam.test/api/v1/devices
  Future<bool> deleteDevice({required String token}) async {
    try {
      final response = await _dioClient.dio.delete<dynamic>(
        ApiEndpoints.device,
        data: <String, dynamic>{'token': token},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The device request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      return true;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      return false;
    }
  }
}
