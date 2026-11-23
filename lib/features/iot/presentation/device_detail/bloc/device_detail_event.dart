import 'package:equatable/equatable.dart';

sealed class DeviceDetailEvent extends Equatable {
  const DeviceDetailEvent();

  @override
  List<Object?> get props => [];
}

class DeviceDetailStarted extends DeviceDetailEvent {
  final String deviceId;

  const DeviceDetailStarted(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class DeviceDetailRefreshed extends DeviceDetailEvent {
  const DeviceDetailRefreshed();
}

class DeviceDetailSensorSelected extends DeviceDetailEvent {
  final String sensorKey;

  const DeviceDetailSensorSelected(this.sensorKey);

  @override
  List<Object?> get props => [sensorKey];
}

class DeviceDetailRangeChanged extends DeviceDetailEvent {
  final int days;

  const DeviceDetailRangeChanged(this.days);

  @override
  List<Object?> get props => [days];
}
