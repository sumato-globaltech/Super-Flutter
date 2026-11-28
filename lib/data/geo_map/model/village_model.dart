import 'package:equatable/equatable.dart';

/// A village point from the Nagaland village GeoJSON dataset.
class VillageModel extends Equatable {
  const VillageModel({
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
    this.latitudeDms = '',
    this.longitudeDms = '',
  });

  factory VillageModel.fromProperties(Map<String, dynamic> properties) {
    return VillageModel(
      name: _text(properties['Vill_Name']),
      district: _text(properties['dtname']),
      latitude: 0,
      longitude: 0,
      latitudeDms: _text(properties['Latitude']),
      longitudeDms: _text(properties['Longitude']),
    );
  }

  /// Reads a GeoJSON feature, using the point geometry for coordinates.
  factory VillageModel.fromFeature(Map<String, dynamic> feature) {
    final properties =
        (feature['properties'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final geometry = (feature['geometry'] as Map?)?.cast<String, dynamic>();
    final coordinates = geometry?['coordinates'];
    var latitude = 0.0;
    var longitude = 0.0;
    if (coordinates is List && coordinates.length >= 2) {
      longitude = _number(coordinates[0]) ?? 0;
      latitude = _number(coordinates[1]) ?? 0;
    }
    return VillageModel(
      name: _text(properties['Vill_Name']),
      district: _text(properties['dtname']),
      latitude: latitude,
      longitude: longitude,
      latitudeDms: _text(properties['Latitude']),
      longitudeDms: _text(properties['Longitude']),
    );
  }

  final String name;
  final String district;
  final double latitude;
  final double longitude;
  final String latitudeDms;
  final String longitudeDms;

  /// Stable identity for search rows; names repeat across districts.
  String get key => '$name@$latitude,$longitude';

  @override
  List<Object?> get props => [name, district, latitude, longitude];
}

String _text(Object? value) => value == null ? '' : '$value';

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}
