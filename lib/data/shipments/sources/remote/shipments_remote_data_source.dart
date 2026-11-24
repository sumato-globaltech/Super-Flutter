import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/shipments/model/assignment_options_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_options_model.dart';

@lazySingleton
class ShipmentsRemoteDataSource {
  ShipmentsRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/farmer/shipments
  Future<Paged<ShipmentModel>> getShipments({
    int? open,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.shipments,
        queryParameters: <String, dynamic>{
          'open': ?open,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          ShipmentModel.fromJson,
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

  /// GET http://dam.test/api/v1/farmer/shipments/{shipment}
  Future<ShipmentModel?> getShipment(String shipment) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.shipment(shipment),
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return ShipmentModel.fromJson(Map<String, dynamic>.from(data));
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

  /// POST http://dam.test/api/v1/farmer/shipments/{shipment}/cancel
  Future<bool> cancelShipment(String shipment, {required String reason}) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.cancelShipment(shipment),
        data: <String, dynamic>{'reason': reason},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The cancel shipment request failed.';
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

  /// GET http://dam.test/api/v1/farmer/shipments/options
  Future<ShipmentOptionsModel?> getShipmentOptions() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.shipmentOptions,
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return ShipmentOptionsModel.fromJson(Map<String, dynamic>.from(data));
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

  /// POST http://dam.test/api/v1/farmer/shipments
  Future<bool> requestShipment({
    required String vendorId,
    required String pickupDistrictId,
    required String pickupAddress,
    required DateTime preferredPickupOn,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.shipments,
        data: <String, dynamic>{
          'vendor_id': vendorId,
          'pickup_district_id': pickupDistrictId,
          'pickup_address': pickupAddress,
          'preferred_pickup_on': preferredPickupOn
              .toIso8601String()
              .split('T')
              .first,
          'notes': ?notes,
          'items': items,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The request shipment request failed.';
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

  /// GET http://dam.test/api/v1/vendor/shipments
  Future<Paged<ShipmentModel>> getVendorShipments({
    int? open,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.vendorShipments,
        queryParameters: <String, dynamic>{
          'open': ?open,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          ShipmentModel.fromJson,
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

  /// GET http://dam.test/api/v1/vendor/shipments/{shipment}
  Future<ShipmentModel?> getVendorShipment(String shipment) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.vendorShipment(shipment),
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return ShipmentModel.fromJson(Map<String, dynamic>.from(data));
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

  /// POST http://dam.test/api/v1/vendor/shipments/{shipment}/accept
  Future<bool> acceptShipment(
    String shipment, {
    required String vehicleId,
    required String driverId,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.acceptShipment(shipment),
        data: <String, dynamic>{'vehicle_id': vehicleId, 'driver_id': driverId},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The accept shipment request failed.';
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

  /// POST http://dam.test/api/v1/vendor/shipments/{shipment}/reject
  Future<bool> rejectShipment(String shipment, {required String reason}) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.rejectShipment(shipment),
        data: <String, dynamic>{'reason': reason},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The reject shipment request failed.';
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

  /// PUT http://dam.test/api/v1/vendor/shipments/{shipment}/assignment
  Future<bool> updateReassignShipment(
    String shipment, {
    required String vehicleId,
    required String driverId,
  }) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        ApiEndpoints.reassignShipment(shipment),
        data: <String, dynamic>{'vehicle_id': vehicleId, 'driver_id': driverId},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The reassign shipment request failed.';
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

  /// POST http://dam.test/api/v1/vendor/shipments/{shipment}/receive
  Future<bool> receiveShipment(
    String shipment, {
    required Map<String, double> quantities,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.receiveShipment(shipment),
        data: <String, dynamic>{'quantities': quantities},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The receive shipment request failed.';
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

  /// POST http://dam.test/api/v1/vendor/shipments/{shipment}/items/{item}/reweigh
  Future<bool> reweighShipmentItem(
    String shipment,
    String item, {
    required double quantity,
    String? reason,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.reweighShipmentItem(shipment, item),
        data: <String, dynamic>{'quantity': quantity, 'reason': ?reason},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The reweigh shipment item request failed.';
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

  /// GET http://dam.test/api/v1/vendor/shipments/{shipment}/assignment-options
  Future<AssignmentOptionsModel?> getAssignmentOptions(String shipment) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.assignmentOptions(shipment),
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return AssignmentOptionsModel.fromJson(Map<String, dynamic>.from(data));
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

  /// GET http://dam.test/api/v1/driver/shipments
  Future<Paged<ShipmentModel>> getDriverShipments({
    int? open,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.driverShipments,
        queryParameters: <String, dynamic>{
          'open': ?open,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(body),
          ShipmentModel.fromJson,
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

  /// GET http://dam.test/api/v1/driver/shipments/{shipment}
  Future<ShipmentModel?> getDriverShipment(String shipment) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.driverShipment(shipment),
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return ShipmentModel.fromJson(Map<String, dynamic>.from(data));
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

  /// PUT http://dam.test/api/v1/driver/shipments/{shipment}/picked
  Future<bool> updateRecordPicked(
    String shipment, {
    required Map<String, double> quantities,
  }) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        ApiEndpoints.recordPicked(shipment),
        data: <String, dynamic>{'quantities': quantities},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The record picked request failed.';
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

  /// POST http://dam.test/api/v1/driver/shipments/{shipment}/pickup
  Future<bool> createConfirmPickup(
    String shipment, {
    Map<String, double>? quantities,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.confirmPickup(shipment),
        data: <String, dynamic>{'quantities': ?quantities},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ??
            'The confirm pickup request failed.';
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

  /// POST http://dam.test/api/v1/driver/shipments/{shipment}/reach
  Future<bool> markReached(String shipment) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.markReached(shipment),
        data: const <String, dynamic>{},
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The mark reached request failed.';
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
