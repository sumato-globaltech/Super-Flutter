import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/farm/model/block_model.dart';
import 'package:super_flutter/data/farm/model/crop_status_model.dart';
import 'package:super_flutter/data/farm/model/farm_crop_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/farm_photo_model.dart';
import 'package:super_flutter/data/farm/model/farm_transaction_model.dart';
import 'package:super_flutter/data/farm/model/irrigation_type_model.dart';
import 'package:super_flutter/data/farm/model/ownership_model.dart';
import 'package:super_flutter/data/farm/model/season_model.dart';
import 'package:super_flutter/data/farm/model/soil_type_model.dart';
import 'package:super_flutter/data/farm/model/transaction_category_model.dart';

import 'farm_endpoints.dart';

@lazySingleton
class FarmRemoteDataSource {
  FarmRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET /api/v1/farmer/farms
  Future<Paged<FarmModel>> getFarms({
    String? status,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        FarmEndpoints.farms,
        queryParameters: <String, dynamic>{
          'status': ?status,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(response.data as Map),
          FarmModel.fromJson,
        );
      }
      return const Paged(items: []);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return const Paged(items: []);
    }
  }

  /// GET /api/v1/farmer/farms/{farm}
  Future<FarmModel?> getFarm(String id) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        FarmEndpoints.farm(id),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return FarmModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// DELETE /api/v1/farmer/farms/{farm}
  Future<bool> deleteFarm(String id) async {
    try {
      final response = await _dioClient.dio.delete<dynamic>(
        FarmEndpoints.farm(id),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return false;
    }
  }

  /// POST /api/v1/farmer/farms/{farm}/archive
  Future<FarmModel?> archiveFarm(String id) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        FarmEndpoints.archive(id),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return FarmModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// POST /api/v1/farmer/farms/{farm}/unarchive
  Future<FarmModel?> unarchiveFarm(String id) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        FarmEndpoints.unarchive(id),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return FarmModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// GET /api/v1/farmer/farms/{farm}/crops
  Future<List<FarmCropModel>> getFarmCrops(String farmId) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        FarmEndpoints.crops(farmId),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => FarmCropModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return const [];
    }
  }

  /// POST /api/v1/farmer/farms/{farm}/crops
  Future<FarmCropModel?> createFarmCrop(
    String farmId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        FarmEndpoints.crops(farmId),
        data: data,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        final body = response.data as Map;
        final resData = body['data'] is Map ? body['data'] as Map : body;
        return FarmCropModel.fromJson(Map<String, dynamic>.from(resData));
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// PUT /api/v1/farmer/farms/{farm}/crops/{farmCrop}
  Future<FarmCropModel?> updateFarmCrop(
    String farmId,
    String cropId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        FarmEndpoints.crop(farmId, cropId),
        data: data,
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final resData = body['data'] is Map ? body['data'] as Map : body;
        return FarmCropModel.fromJson(Map<String, dynamic>.from(resData));
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// DELETE /api/v1/farmer/farms/{farm}/crops/{farmCrop}
  Future<bool> deleteFarmCrop(String farmId, String cropId) async {
    try {
      final response = await _dioClient.dio.delete<dynamic>(
        FarmEndpoints.crop(farmId, cropId),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return false;
    }
  }

  /// GET /api/v1/farmer/farms/{farm}/transactions
  Future<Paged<FarmTransactionModel>> getTransactions(
    String farmId, {
    String? farmCropId,
    String? type,
    String? from,
    String? to,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        FarmEndpoints.transactions(farmId),
        queryParameters: <String, dynamic>{
          'farm_crop_id': ?farmCropId,
          'type': ?type,
          'from': ?from,
          'to': ?to,
          'page': ?page,
          'per_page': ?perPage,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Paged.fromEnvelope(
          Map<String, dynamic>.from(response.data as Map),
          FarmTransactionModel.fromJson,
        );
      }
      return const Paged(items: []);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return const Paged(items: []);
    }
  }

  /// POST /api/v1/farmer/farms/{farm}/transactions
  Future<FarmTransactionModel?> createTransaction(
    String farmId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        FarmEndpoints.transactions(farmId),
        data: data,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        final body = response.data as Map;
        final resData = body['data'] is Map ? body['data'] as Map : body;
        return FarmTransactionModel.fromJson(
          Map<String, dynamic>.from(resData),
        );
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// GET /api/v1/farmer/farms/{farm}/transactions/summary
  Future<FarmTransactionSummaryModel?> getTransactionSummary(
    String farmId,
  ) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        FarmEndpoints.transactionSummary(farmId),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'] is Map ? body['data'] as Map : body;
        return FarmTransactionSummaryModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// GET /api/v1/farmer/farms/{farm}/photos
  Future<List<FarmPhotoModel>> getPhotos(String farmId) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        FarmEndpoints.photos(farmId),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => FarmPhotoModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return const [];
    }
  }

  /// POST /api/v1/farmer/farms/{farm}/photos
  Future<FarmPhotoModel?> uploadPhoto(String farmId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath),
      });
      final response = await _dioClient.dio.post<dynamic>(
        FarmEndpoints.photos(farmId),
        data: formData,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        final body = response.data as Map;
        final resData = body['data'] is Map ? body['data'] as Map : body;
        return FarmPhotoModel.fromJson(Map<String, dynamic>.from(resData));
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// DELETE /api/v1/farmer/farms/{farm}/photos/{photo}
  Future<bool> deletePhoto(String farmId, String photoId) async {
    try {
      final response = await _dioClient.dio.delete<dynamic>(
        FarmEndpoints.photo(farmId, photoId),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (_) {
      return false;
    }
  }

  /// POST http://dam.test/api/v1/farmer/farms
  Future<bool> createFarm({
    required String name,
    required double areaHa,
    String? blockId,
    String? village,
    String? address,
    String? soilType,
    String? irrigationType,
    String? ownership,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.farm,
        data: <String, dynamic>{
          'name': name,
          'area_ha': areaHa,
          'block_id': ?blockId,
          'village': ?village,
          'address': ?address,
          'soil_type': ?soilType,
          'irrigation_type': ?irrigationType,
          'ownership': ?ownership,
          'latitude': ?latitude,
          'longitude': ?longitude,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The farm request failed.';
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

  /// GET http://dam.test/api/v1/farmer/blocks
  Future<List<BlockModel>> getBlocks() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(ApiEndpoints.blocks);
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
                (item) => BlockModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// GET http://dam.test/api/v1/farmer/soil-types
  Future<List<SoilTypeModel>> getSoilTypes() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.soilTypes,
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
                    SoilTypeModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// GET http://dam.test/api/v1/farmer/irrigation-methods
  Future<List<IrrigationTypeModel>> getIrrigationMethods() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.irrigationMethods,
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
                (item) => IrrigationTypeModel.fromJson(
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

  /// GET http://dam.test/api/v1/farmer/land-ownerships
  Future<List<OwnershipModel>> getLandOwnerships() async {
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
                (item) =>
                    OwnershipModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// PUT http://dam.test/api/v1/farmer/farms/{farm}
  Future<bool> updateFarmDetail(
    String farm, {
    required String name,
    required double areaHa,
    String? blockId,
    String? village,
    String? address,
    String? soilType,
    String? irrigationType,
    String? ownership,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        ApiEndpoints.farmDetail(farm),
        data: <String, dynamic>{
          'name': name,
          'area_ha': areaHa,
          'block_id': ?blockId,
          'village': ?village,
          'address': ?address,
          'soil_type': ?soilType,
          'irrigation_type': ?irrigationType,
          'ownership': ?ownership,
          'latitude': ?latitude,
          'longitude': ?longitude,
        },
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The farm detail request failed.';
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

  /// GET http://dam.test/api/v1/categories/transaction_category
  Future<List<TransactionCategoryModel>> getTransactionCategories() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.transactionCategories,
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
                (item) => TransactionCategoryModel.fromJson(
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

  /// GET http://dam.test/api/v1/farmer/seasons
  Future<List<SeasonModel>> getSeasons() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(ApiEndpoints.seasons);
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
                (item) => SeasonModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// GET http://dam.test/api/v1/farmer/crop-statuses
  Future<List<CropStatusModel>> getCropStatuses() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.cropStatuses,
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
                    CropStatusModel.fromJson(Map<String, dynamic>.from(item)),
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

  /// GET http://dam.test/api/v1/financial-years/current
  Future<FinancialYearModel?> getCurrentFinancialYear() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.currentFinancialYear,
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return FinancialYearModel.fromJson(Map<String, dynamic>.from(data));
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
