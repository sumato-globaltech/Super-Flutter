import 'package:equatable/equatable.dart';

/// Geographic bounds (west/south/east/north) for viewport fitting. Reserved
/// for a future fit-bounds command; currently carried but unread.
class MapBoundingBox extends Equatable {
  final double west;
  final double south;
  final double east;
  final double north;

  const MapBoundingBox({required this.west, required this.south, required this.east, required this.north});

  @override
  List<Object?> get props => [west, south, east, north];
}
