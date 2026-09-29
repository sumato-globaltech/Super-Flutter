import 'package:equatable/equatable.dart';

class MapPoint extends Equatable {
  final double latitude;
  final double longitude;

  const MapPoint({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];

  static MapPoint fromLatLong(double latitude, double longitude) {
    return MapPoint(latitude: latitude, longitude: longitude);
  }

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
