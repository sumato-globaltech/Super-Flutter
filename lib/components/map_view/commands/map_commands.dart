

import '../models/map_point.dart';
import '../state/map_view_state.dart';

/// Camera intent sent from [MapScreenCubit] to [MapView] over a broadcast
/// stream, keeping the Cubit free of any MapLibre controller reference.
sealed class MapCommand {
  const MapCommand();
}

/// Glide to [target] at [zoom], preserving tilt/bearing unless overridden.
class AnimateTo extends MapCommand {
  final MapPoint target;
  final double zoom;
  final double? tilt;
  final double? bearing;

  const AnimateTo({required this.target, required this.zoom, this.tilt, this.bearing});
}

/// Instantly jump to [target] without animation.
class MoveTo extends MapCommand {
  final MapPoint target;
  const MoveTo({required this.target});
}

/// Absolute camera snapshot emitted by the zoom/tilt/rotate buttons. Null
/// fields fall back to the live camera reading inside the view.
class ControlChanges extends MapCommand {
  final double? zoom;
  final double? tilt;
  final double? bearing;

  const ControlChanges({this.zoom, this.tilt, this.bearing});
}

/// Return the camera to its home position. Currently unhandled by the view
/// and unsent by the Cubit — implement or delete together with its handler.
class ResetCamera extends MapCommand {
  final MapViewState mapViewState;

  const ResetCamera({required this.mapViewState});
}
