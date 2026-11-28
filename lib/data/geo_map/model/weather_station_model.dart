import 'package:equatable/equatable.dart';

/// A weather station from the bundled station GeoJSON dataset.
class WeatherStationModel extends Equatable {
  const WeatherStationModel({
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.attributes,
  });

  factory WeatherStationModel.fromFeature(Map<String, dynamic> feature) {
    final properties =
        (feature['properties'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final geometry = (feature['geometry'] as Map?)?.cast<String, dynamic>();
    final coordinates = geometry?['coordinates'];
    var latitude = 0.0;
    var longitude = 0.0;
    if (coordinates is List && coordinates.length >= 2) {
      longitude = double.tryParse('${coordinates[0]}') ?? 0;
      latitude = double.tryParse('${coordinates[1]}') ?? 0;
    }
    return WeatherStationModel(
      district: '${properties['dist_name'] ?? ''}',
      latitude: latitude,
      longitude: longitude,
      attributes: {
        for (final entry in properties.entries)
          if (entry.value != null && '${entry.value}'.isNotEmpty)
            entry.key: '${entry.value}',
      },
    );
  }

  final String district;
  final double latitude;
  final double longitude;
  final Map<String, String> attributes;

  @override
  List<Object?> get props => [district, latitude, longitude];
}
