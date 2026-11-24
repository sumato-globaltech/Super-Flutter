import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/support/model/call_center_model.dart';
import 'package:super_flutter/data/support/model/category_model.dart';
import 'package:super_flutter/data/support/model/ticket_model.dart';

@lazySingleton
class SupportRemoteDataSource {
  SupportRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/farmer/call-center
  Future<CallCenterModel?> getCallCenter() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.callCenter,
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return CallCenterModel.fromJson(Map<String, dynamic>.from(data));
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

  /// POST http://dam.test/api/v1/farmer/call-back
  Future<bool> createCallBack({String? question}) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.callBack,
        data: <String, dynamic>{'question': ?question},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The call back request failed.';
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

  /// GET http://dam.test/api/v1/farmer/tickets
  Future<Paged<TicketModel>> getTickets({int? page, int? perPage}) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.tickets,
        queryParameters: <String, dynamic>{'page': ?page, 'per_page': ?perPage},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          TicketModel.fromJson,
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

  /// GET http://dam.test/api/v1/farmer/tickets/{ticket}
  Future<TicketModel?> getTicket(String ticket) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.ticket(ticket),
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return TicketModel.fromJson(Map<String, dynamic>.from(data));
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

  /// POST http://dam.test/api/v1/farmer/tickets
  Future<bool> createTicket({
    required String categoryId,
    required String subject,
    required String question,
    String? cropId,
    String? photo,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.tickets,
        data: FormData.fromMap(<String, dynamic>{
          'category_id': categoryId,
          'subject': subject,
          'question': question,
          'crop_id': ?cropId,
          'photo': ?(photo == null
              ? null
              : await MultipartFile.fromFile(photo)),
        }),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The create ticket request failed.';
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

  /// GET http://dam.test/api/v1/categories/ticket_category
  Future<List<CategoryModel>> getTicketCategory() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.ticketCategory,
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

  /// GET http://dam.test/api/v1/crops?per_page=100
  Future<List<CropModel>> getCrops() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(ApiEndpoints.crops);
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
                (item) => CropModel.fromJson(Map<String, dynamic>.from(item)),
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
}
