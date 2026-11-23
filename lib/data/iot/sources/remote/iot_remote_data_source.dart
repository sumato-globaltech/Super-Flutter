import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/iot/model/device_model.dart';
import 'package:super_flutter/data/iot/model/integration_run_model.dart';
import 'package:super_flutter/data/iot/model/sensor_history_model.dart';
import 'package:super_flutter/data/iot/model/soil_sensor_account_model.dart';

import 'iot_endpoints.dart';

@lazySingleton
class IotRemoteDataSource {
  final DioClient _dioClient;

  IotRemoteDataSource(this._dioClient);

  Dio get _dio => _dioClient.dio;

  Future<List<DeviceModel>> getFarmDevices(String farmId) async {
    try {
      final response = await _dio.get(IotEndpoints.farmDevices(farmId));
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(DeviceModel.fromJson)
              .toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  Future<IntegrationRunModel?> syncFarmDevices(String farmId) async {
    try {
      final response = await _dio.post(IotEndpoints.syncFarmDevices(farmId));
      if ((response.statusCode == 200 || response.statusCode == 202) &&
          response.data is Map) {
        final data = response.data['data'];
        if (data is Map) {
          return IntegrationRunModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  Future<SoilSensorAccountModel?> getSoilSensorAccount(String farmId) async {
    try {
      final response = await _dio.get(IotEndpoints.soilSensorAccount(farmId));
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is Map) {
          return SoilSensorAccountModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  Future<SoilSensorAccountModel?> linkSoilSensorAccount(
    String farmId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        IotEndpoints.soilSensorAccount(farmId),
        data: data,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        final resData = response.data['data'];
        if (resData is Map) {
          return SoilSensorAccountModel.fromJson(
            Map<String, dynamic>.from(resData),
          );
        }
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  Future<bool> unlinkSoilSensorAccount(String farmId) async {
    try {
      final response = await _dio.delete(
        IotEndpoints.soilSensorAccount(farmId),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final response = await _dio.get(IotEndpoints.device(deviceId));
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is Map) {
          return DeviceModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  Future<SensorHistoryModel?> getDeviceReadings(
    String deviceId, {
    required String sensorId,
    String? from,
    String? to,
  }) async {
    try {
      final response = await _dio.get(
        IotEndpoints.deviceReadings(deviceId),
        queryParameters: {'sensor': sensorId, 'from': ?from, 'to': ?to},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is Map) {
          return SensorHistoryModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }
}
