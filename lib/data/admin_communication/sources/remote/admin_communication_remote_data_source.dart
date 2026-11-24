import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/admin_communication/model/admin_alert_model.dart';
import 'package:super_flutter/data/admin_communication/model/admin_notice_model.dart';
import 'package:super_flutter/data/admin_communication/model/district_model.dart';
import 'package:super_flutter/data/admin_communication/model/priority_model.dart';
import 'package:super_flutter/data/admin_communication/model/severity_model.dart';
import 'package:super_flutter/data/support/model/category_model.dart';

@lazySingleton
class AdminCommunicationRemoteDataSource {
  AdminCommunicationRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// POST http://dam.test/api/v1/admin/notices/{notice}/publish
  Future<bool> publishNotice(String notice) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.publishNotice(notice),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The publish notice request failed.';
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

  /// POST http://dam.test/api/v1/admin/notices/{notice}/archive
  Future<bool> archiveNotice(String notice) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.archiveNotice(notice),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The archive notice request failed.';
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

  /// POST http://dam.test/api/v1/admin/notices/{notice}/restore
  Future<bool> restoreNotice(String notice) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.restoreNotice(notice),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The restore notice request failed.';
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

  /// DELETE http://dam.test/api/v1/admin/notices/{notice}
  Future<bool> deleteAdminNoticeRemoval(String notice) async {
    try {
      final response = await _dioClient.dio.delete<dynamic>(
        ApiEndpoints.adminNoticeRemoval(notice),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The admin notice removal request failed.';
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

  /// POST http://dam.test/api/v1/admin/alerts/{alert}/activate
  Future<bool> activateAlert(String alert) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.activateAlert(alert),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The activate alert request failed.';
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

  /// POST http://dam.test/api/v1/admin/alerts/{alert}/cancel
  Future<bool> cancelAlert(String alert) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.cancelAlert(alert),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The cancel alert request failed.';
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

  /// DELETE http://dam.test/api/v1/admin/alerts/{alert}
  Future<bool> deleteAdminAlertRemoval(String alert) async {
    try {
      final response = await _dioClient.dio.delete<dynamic>(
        ApiEndpoints.adminAlertRemoval(alert),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The admin alert removal request failed.';
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

  /// GET http://dam.test/api/v1/admin/notices
  Future<Paged<AdminNoticeModel>> getAdminNotices({
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.adminNotices,
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          AdminNoticeModel.fromJson,
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

  /// GET http://dam.test/api/v1/admin/alerts
  Future<Paged<AdminAlertModel>> getAdminAlerts({
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.adminAlerts,
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          AdminAlertModel.fromJson,
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

  /// POST http://dam.test/api/v1/admin/notices
  Future<bool> addNotice({
    required String categoryId,
    required String title,
    String? bodyHtml,
    required String priority,
    DateTime? expiresOn,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.adminNotices,
        data: <String, dynamic>{
          'category_id': categoryId,
          'title': title,
          'body': ?bodyHtml,
          'priority': priority,
          'expires_on': ?expiresOn?.toIso8601String().split('T').first,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The add notice request failed.';
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

  /// GET http://dam.test/api/v1/categories/notice_type
  Future<List<CategoryModel>> getNoticeType() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.noticeType,
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

  /// GET http://dam.test/api/v1/admin/notices/priorities
  Future<List<PriorityModel>> getPriorities() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.priorities,
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
                    PriorityModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// PUT http://dam.test/api/v1/admin/notices/{notice}
  Future<bool> updateEditNotice(
    String notice, {
    required String categoryId,
    required String title,
    String? bodyHtml,
    required String priority,
    DateTime? expiresOn,
  }) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        ApiEndpoints.adminNoticeRemoval(notice),
        data: <String, dynamic>{
          'category_id': categoryId,
          'title': title,
          'body': ?bodyHtml,
          'priority': priority,
          'expires_on': ?expiresOn?.toIso8601String().split('T').first,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The edit notice request failed.';
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

  /// POST http://dam.test/api/v1/admin/alerts
  Future<bool> addAlert({
    required String categoryId,
    String? districtId,
    required String title,
    required String description,
    required String severity,
    required DateTime startsOn,
    DateTime? endsOn,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.adminAlerts,
        data: <String, dynamic>{
          'category_id': categoryId,
          'district_id': ?districtId,
          'title': title,
          'description': description,
          'severity': severity,
          'starts_on': startsOn.toIso8601String().split('T').first,
          'ends_on': ?endsOn?.toIso8601String().split('T').first,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The add alert request failed.';
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

  /// GET http://dam.test/api/v1/categories/alert_type
  Future<List<CategoryModel>> getAlertType() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.alertType,
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

  /// GET http://dam.test/api/v1/admin/alerts/districts
  Future<List<DistrictModel>> getDistricts() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.districts,
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
                    DistrictModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// GET http://dam.test/api/v1/admin/alerts/severities
  Future<List<SeverityModel>> getSeverities() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.severities,
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
                    SeverityModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// PUT http://dam.test/api/v1/admin/alerts/{alert}
  Future<bool> updateEditAlert(
    String alert, {
    required String categoryId,
    String? districtId,
    required String title,
    required String description,
    required String severity,
    required DateTime startsOn,
    DateTime? endsOn,
  }) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        ApiEndpoints.adminAlertRemoval(alert),
        data: <String, dynamic>{
          'category_id': categoryId,
          'district_id': ?districtId,
          'title': title,
          'description': description,
          'severity': severity,
          'starts_on': startsOn.toIso8601String().split('T').first,
          'ends_on': ?endsOn?.toIso8601String().split('T').first,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The edit alert request failed.';
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
