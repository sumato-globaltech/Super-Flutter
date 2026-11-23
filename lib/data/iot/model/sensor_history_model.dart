import 'package:equatable/equatable.dart';

import 'device_model.dart';

class SensorHistoryModel extends Equatable {
  final DeviceSensorModel? sensor;
  final String? from;
  final String? to;
  final String? resolution;
  final List<ReadingPointModel> points;

  const SensorHistoryModel({
    this.sensor,
    this.from,
    this.to,
    this.resolution,
    this.points = const [],
  });

  factory SensorHistoryModel.fromJson(Map<String, dynamic> json) {
    return SensorHistoryModel(
      sensor: json['sensor'] is Map
          ? DeviceSensorModel.fromJson(
              Map<String, dynamic>.from(json['sensor'] as Map),
            )
          : null,
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      resolution: json['resolution']?.toString(),
      points: json['points'] is List
          ? (json['points'] as List)
                .whereType<Map<String, dynamic>>()
                .map(ReadingPointModel.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    if (sensor != null) 'sensor': sensor!.toJson(),
    if (from != null) 'from': from,
    if (to != null) 'to': to,
    if (resolution != null) 'resolution': resolution,
    'points': points.map((p) => p.toJson()).toList(),
  };

  @override
  List<Object?> get props => [sensor, from, to, resolution, points];
}

class ReadingPointModel extends Equatable {
  final String? at;
  final double? value;

  const ReadingPointModel({this.at, this.value});

  factory ReadingPointModel.fromJson(Map<String, dynamic> json) {
    return ReadingPointModel(
      at: json['at']?.toString(),
      value: json['value'] != null
          ? double.tryParse(json['value'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (at != null) 'at': at,
    if (value != null) 'value': value,
  };

  @override
  List<Object?> get props => [at, value];
}
