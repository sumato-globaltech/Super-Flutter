import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/farm/model/farm_crop_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/farm_photo_model.dart';
import 'package:super_flutter/data/farm/model/farm_transaction_model.dart';

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

  /// POST /api/v1/farmer/farms
  Future<FarmModel?> createFarm(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        FarmEndpoints.farms,
        data: data,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        final body = response.data as Map;
        final resData = body['data'] is Map ? body['data'] as Map : body;
        return FarmModel.fromJson(Map<String, dynamic>.from(resData));
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

  /// PUT /api/v1/farmer/farms/{farm}
  Future<FarmModel?> updateFarm(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.put<dynamic>(
        FarmEndpoints.farm(id),
        data: data,
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        final resData = body['data'] is Map ? body['data'] as Map : body;
        return FarmModel.fromJson(Map<String, dynamic>.from(resData));
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
}
