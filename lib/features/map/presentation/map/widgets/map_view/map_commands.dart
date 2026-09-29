import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_point.dart';

sealed class MapCommand {
  const MapCommand();
}

class AnimateTo extends MapCommand {
  final MapPoint target;
  final double zoom;
  final double? tilt;
  final double? bearing;

  const AnimateTo({required this.target, required this.zoom, this.tilt, this.bearing});
}

class MoveTo extends MapCommand {
  final MapPoint target;
  const MoveTo({required this.target});
}

class ControlChanges extends MapCommand {
  final double? zoom;
  final double? tilt;
  final double? bearing;

  const ControlChanges({this.zoom, this.tilt, this.bearing});
}

class ResetCamera extends MapCommand {
  final MapPoint target;

  const ResetCamera({required this.target});
}
