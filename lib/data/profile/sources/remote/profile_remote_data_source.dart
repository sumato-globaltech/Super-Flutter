import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/profile/model/farmer_profile_model.dart'
    hide GenderModel, LandOwnershipModel;
import 'package:super_flutter/data/profile/model/gender_model.dart';
import 'package:super_flutter/data/profile/model/land_ownership_model.dart';

@lazySingleton
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/farmer/profile
  Future<FarmerProfileModel?> getFarmerProfile() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.farmerProfile,
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return FarmerProfileModel.fromJson(Map<String, dynamic>.from(data));
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

  /// PUT http://dam.test/api/v1/farmer/profile
  Future<bool> updateEditProfile({
    required String name,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? village,
    String? address,
    double? landAreaHa,
    String? landOwnership,
    required List<String> blockIds,
  }) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        ApiEndpoints.farmerProfile,
        data: <String, dynamic>{
          'name': name,
          // The API keeps what is left out: an emptied field is sent as null.
          'email': email,
          'gender': gender,
          'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
          'village': village,
          'address': address,
          'land_area_ha': landAreaHa,
          'land_ownership': landOwnership,
          'block_ids': blockIds,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The edit profile request failed.';
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

  /// GET http://dam.test/api/v1/farmer/genders
  Future<List<GenderModel>> getGenders() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(ApiEndpoints.genders);
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
                (item) => GenderModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// GET http://dam.test/api/v1/farmer/land-ownerships
  Future<List<LandOwnershipModel>> getLandOwnerships() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.landOwnerships,
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
                (item) => LandOwnershipModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
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
