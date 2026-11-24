import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/schemes/model/scheme_application_model.dart';
import 'package:super_flutter/data/schemes/model/scheme_model.dart';

@lazySingleton
class SchemesRemoteDataSource {
  SchemesRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/schemes
  Future<Paged<SchemeModel>> getSchemes({int? page, int? perPage}) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.schemes,
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          SchemeModel.fromJson,
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

  /// GET http://dam.test/api/v1/schemes/{scheme}
  Future<SchemeModel?> getScheme(String scheme) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.scheme(scheme),
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return SchemeModel.fromJson(Map<String, dynamic>.from(data));
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

  /// POST http://dam.test/api/v1/farmer/schemes/{scheme}/apply
  Future<bool> applyScheme(String scheme) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.applyScheme(scheme),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The apply scheme request failed.';
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

  /// POST http://dam.test/api/v1/farmer/applications/{application}/withdraw
  Future<bool> withdrawApplication(String application) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.withdrawApplication(application),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The withdraw application request failed.';
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

  /// POST http://dam.test/api/v1/farmer/applications/{application}/documents
  Future<bool> createApplicationDocument(
    String application, {
    required String name,
    required String file,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.applicationDocument(application),
        data: FormData.fromMap(<String, dynamic>{
          'name': name,
          'file': await MultipartFile.fromFile(file),
        }),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The application document request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      return response.statusCode == 201;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      return false;
    }
  }

  /// GET http://dam.test/api/v1/officer/schemes
  Future<Paged<SchemeModel>> getOfficerSchemes({
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.officerSchemes,
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          SchemeModel.fromJson,
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

  /// GET http://dam.test/api/v1/farmer/applications
  Future<Paged<SchemeApplicationModel>> getSchemeApplications({
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.schemeApplications,
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          SchemeApplicationModel.fromJson,
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
