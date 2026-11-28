import 'dart:math' as math;

import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';

/// Spherical polygon area in square metres for a closed or open ring.
double polygonAreaSquareMeters(List<GeoPoint> points) {
  if (points.length < 3) return 0;
  const earthRadius = 6378137.0;
  var total = 0.0;
  for (var i = 0; i < points.length; i++) {
    final current = points[i];
    final next = points[(i + 1) % points.length];
    total +=
        _radians(next.longitude - current.longitude) *
        (2 +
            math.sin(_radians(current.latitude)) +
            math.sin(_radians(next.latitude)));
  }
  return (total * earthRadius * earthRadius / 2).abs();
}

double _radians(double degrees) => degrees * math.pi / 180;

String formatAcres(double squareMeters) =>
    '${(squareMeters * 0.000247105).toStringAsFixed(2)} acres';

String formatHectares(double squareMeters) =>
    '${(squareMeters / 10000).toStringAsFixed(2)} ha';

String formatSquareKilometers(double squareMeters) =>
    '${(squareMeters / 1000000).toStringAsFixed(3)} km²';
