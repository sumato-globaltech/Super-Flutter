import 'package:equatable/equatable.dart';

class MapBoundingBox extends Equatable {
  final double west;
  final double south;
  final double east;
  final double north;

  const new({required this.west, required this.south, required this.east, required this.north});

  @override
  List<Object?> get props => [west, south, east, north];
}
