import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/data/geo_map/model/village_model.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/geo_map_geometry.dart';

void main() {
  group('polygonAreaSquareMeters', () {
    test('a small square has a positive area and no value below 3 points', () {
      const square = [
        GeoPoint(latitude: 25.00, longitude: 94.00),
        GeoPoint(latitude: 25.00, longitude: 94.01),
        GeoPoint(latitude: 25.01, longitude: 94.01),
        GeoPoint(latitude: 25.01, longitude: 94.00),
      ];

      final area = polygonAreaSquareMeters(square);
      expect(area, greaterThan(0));
      expect(formatHectares(area), endsWith(' ha'));
      expect(formatAcres(area), endsWith(' acres'));
      expect(polygonAreaSquareMeters(square.take(2).toList()), 0);
    });
  });

  group('VillageModel.fromFeature', () {
    test('reads the name, district, point and DMS properties', () {
      final village = VillageModel.fromFeature({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [94.1086, 25.6751],
        },
        'properties': {
          'Vill_Name': 'Kohima',
          'dtname': 'Kohima',
          'Latitude': '25° 40\' 30.36" N',
          'Longitude': '94° 6\' 30.96" E',
        },
      });

      expect(village.name, 'Kohima');
      expect(village.district, 'Kohima');
      expect(village.latitude, 25.6751);
      expect(village.longitude, 94.1086);
      expect(village.latitudeDms, contains('25°'));
    });
  });
}
