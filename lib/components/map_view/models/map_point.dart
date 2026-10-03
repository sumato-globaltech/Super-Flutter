import 'package:equatable/equatable.dart';

/// Latitude/longitude pair used by commands and camera snapshots.
class MapPoint extends Equatable {
  final double latitude;
  final double longitude;

  const MapPoint({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];

  /// Builds a point from raw coordinates. Prefer the const constructor for
  /// compile-time constants; this helper exists for values parsed at runtime.
  static MapPoint fromLatLong(double latitude, double longitude) {
    return MapPoint(latitude: latitude, longitude: longitude);
  }

  /// JSON-style rendering for the on-screen debug overlay.
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write("{");
    buffer.write("\"latitude\": $latitude");
    buffer.write("\"longitude\": $longitude");
    buffer.write("}");
    return buffer.toString();
  }
}

extension MapPointX on MapPoint {}
