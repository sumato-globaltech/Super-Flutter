import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/iot/model/device_model.dart';
import 'package:super_flutter/data/iot/model/sensor_history_model.dart';

enum DeviceDetailStatus { initial, loading, success, failure }

class DeviceDetailState extends Equatable {
  final DeviceDetailStatus status;
  final String deviceId;
  final DeviceModel? device;
  final String? selectedSensorKey;
  final int selectedDays;
  final SensorHistoryModel? readings;
  final bool isLoadingReadings;
  final String? errorMessage;

  const DeviceDetailState({
    this.status = DeviceDetailStatus.initial,
    this.deviceId = '',
    this.device,
    this.selectedSensorKey,
    this.selectedDays = 7,
    this.readings,
    this.isLoadingReadings = false,
    this.errorMessage,
  });

  DeviceSensorModel? get selectedSensor {
    if (device == null || selectedSensorKey == null) return null;
    return device!.sensors.cast<DeviceSensorModel?>().firstWhere(
          (s) => s?.id == selectedSensorKey || s?.metric == selectedSensorKey,
          orElse: () => null,
        );
  }

  DeviceDetailState copyWith({
    DeviceDetailStatus? status,
    String? deviceId,
    DeviceModel? device,
    String? selectedSensorKey,
    int? selectedDays,
    SensorHistoryModel? readings,
    bool? isLoadingReadings,
    String? errorMessage,
  }) {
    return DeviceDetailState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      device: device ?? this.device,
      selectedSensorKey: selectedSensorKey ?? this.selectedSensorKey,
      selectedDays: selectedDays ?? this.selectedDays,
      readings: readings ?? this.readings,
      isLoadingReadings: isLoadingReadings ?? this.isLoadingReadings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        deviceId,
        device,
        selectedSensorKey,
        selectedDays,
        readings,
        isLoadingReadings,
        errorMessage,
      ];
}
