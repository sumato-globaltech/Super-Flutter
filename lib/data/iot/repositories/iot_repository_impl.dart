import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/iot/model/device_model.dart';
import 'package:super_flutter/data/iot/model/integration_run_model.dart';
import 'package:super_flutter/data/iot/model/sensor_history_model.dart';
import 'package:super_flutter/data/iot/model/soil_sensor_account_model.dart';
import 'package:super_flutter/data/iot/sources/remote/iot_remote_data_source.dart';

@lazySingleton
class IotRepositoryImpl {
  final IotRemoteDataSource _remoteDataSource;

  IotRepositoryImpl(this._remoteDataSource);

  Future<List<DeviceModel>> getFarmDevices(String farmId) =>
      _remoteDataSource.getFarmDevices(farmId);

  Future<IntegrationRunModel?> syncFarmDevices(String farmId) =>
      _remoteDataSource.syncFarmDevices(farmId);

  Future<SoilSensorAccountModel?> getSoilSensorAccount(String farmId) =>
      _remoteDataSource.getSoilSensorAccount(farmId);

  Future<SoilSensorAccountModel?> linkSoilSensorAccount(
    String farmId,
    Map<String, dynamic> data,
  ) =>
      _remoteDataSource.linkSoilSensorAccount(farmId, data);

  Future<bool> unlinkSoilSensorAccount(String farmId) =>
      _remoteDataSource.unlinkSoilSensorAccount(farmId);

  Future<DeviceModel?> getDevice(String deviceId) =>
      _remoteDataSource.getDevice(deviceId);

  Future<SensorHistoryModel?> getDeviceReadings(
    String deviceId, {
    required String sensorId,
    String? from,
    String? to,
  }) =>
      _remoteDataSource.getDeviceReadings(
        deviceId,
        sensorId: sensorId,
        from: from,
        to: to,
      );
}
