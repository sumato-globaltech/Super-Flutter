import 'package:equatable/equatable.dart';

sealed class MapCameraEvent extends Equatable {
  const MapCameraEvent();

  @override
  List<Object?> get props => [];
}

/// Fired from [MapView.onMapCreated] once the native controller exists.
class MapCameraReady extends MapCameraEvent {
  const MapCameraReady(this.controller);

  /// Typed as [Object] to keep the event layer decoupled from the map
  /// package; the Bloc casts it to `MapController` internally.
  final Object controller;

  @override
  List<Object?> get props => [controller];
}

class MapZoomInRequested extends MapCameraEvent {
  const MapZoomInRequested();
}

class MapZoomOutRequested extends MapCameraEvent {
  const MapZoomOutRequested();
}

class MapTiltUpRequested extends MapCameraEvent {
  const MapTiltUpRequested();
}

class MapTiltDownRequested extends MapCameraEvent {
  const MapTiltDownRequested();
}

class MapRotateLeftRequested extends MapCameraEvent {
  const MapRotateLeftRequested();
}

class MapRotateRightRequested extends MapCameraEvent {
  const MapRotateRightRequested();
}

/// Resets to North-up: bearing 0, pitch 0, keeps center and zoom.
class MapNorthUpRequested extends MapCameraEvent {
  const MapNorthUpRequested();
}
