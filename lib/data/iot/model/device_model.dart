import 'package:equatable/equatable.dart';

class DeviceModel extends Equatable {
  final String? id;
  final String? code;
  final String? name;
  final String? type;
  final String? typeLabel;
  final String? provider;
  final String? farmId;
  final double? latitude;
  final double? longitude;
  final String? installedAt;
  final bool? isOnline;
  final String? lastReadingAt;
  final List<DeviceSensorModel> sensors;

  const DeviceModel({
    this.id,
    this.code,
    this.name,
    this.type,
    this.typeLabel,
    this.provider,
    this.farmId,
    this.latitude,
    this.longitude,
    this.installedAt,
    this.isOnline,
    this.lastReadingAt,
    this.sensors = const [],
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      typeLabel: json['type_label']?.toString(),
      provider: json['provider']?.toString(),
      farmId: json['farm_id']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      installedAt: json['installed_at']?.toString(),
      isOnline: json['is_online'] as bool?,
      lastReadingAt: json['last_reading_at']?.toString(),
      sensors: json['sensors'] is List
          ? (json['sensors'] as List)
                .whereType<Map<String, dynamic>>()
                .map(DeviceSensorModel.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (code != null) 'code': code,
    if (name != null) 'name': name,
    if (type != null) 'type': type,
    if (typeLabel != null) 'type_label': typeLabel,
    if (provider != null) 'provider': provider,
    if (farmId != null) 'farm_id': farmId,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (installedAt != null) 'installed_at': installedAt,
    if (isOnline != null) 'is_online': isOnline,
    if (lastReadingAt != null) 'last_reading_at': lastReadingAt,
    'sensors': sensors.map((s) => s.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    type,
    typeLabel,
    provider,
    farmId,
    latitude,
    longitude,
    installedAt,
    isOnline,
    lastReadingAt,
    sensors,
  ];
}

class DeviceSensorModel extends Equatable {
  final String? id;
  final String? name;
  final String? metric;
  final String? unit;
  final SensorReadingModel? latestReading;

  const DeviceSensorModel({
    this.id,
    this.name,
    this.metric,
    this.unit,
    this.latestReading,
  });

  factory DeviceSensorModel.fromJson(Map<String, dynamic> json) {
    return DeviceSensorModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      metric: json['metric']?.toString(),
      unit: json['unit']?.toString(),
      latestReading: json['latest_reading'] is Map
          ? SensorReadingModel.fromJson(
              Map<String, dynamic>.from(json['latest_reading'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (metric != null) 'metric': metric,
    if (unit != null) 'unit': unit,
    if (latestReading != null) 'latest_reading': latestReading!.toJson(),
  };

  @override
  List<Object?> get props => [id, name, metric, unit, latestReading];
}

class SensorReadingModel extends Equatable {
  final double? value;
  final String? quality;
  final String? recordedAt;

  const SensorReadingModel({this.value, this.quality, this.recordedAt});

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingModel(
      value: json['value'] != null
          ? double.tryParse(json['value'].toString())
          : null,
      quality: json['quality']?.toString(),
      recordedAt: json['recorded_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (value != null) 'value': value,
    if (quality != null) 'quality': quality,
    if (recordedAt != null) 'recorded_at': recordedAt,
  };

  @override
  List<Object?> get props => [value, quality, recordedAt];
}
