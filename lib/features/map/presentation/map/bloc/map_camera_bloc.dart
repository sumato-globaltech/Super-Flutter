import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:maplibre/maplibre.dart';

import 'map_camera_event.dart';
import 'map_camera_state.dart';

/// Screen Bloc for [MapScreen]. Owns animated camera movements (zoom, tilt,
/// bearing) driven by [MapCameraControls]. No-ops until [MapCameraReady].
@injectable
class MapCameraBloc extends Bloc<MapCameraEvent, MapCameraState> {
  MapCameraBloc() : super(const MapCameraState()) {
    on<MapCameraReady>(_onReady);
    on<MapZoomInRequested>((e, emit) => _move(emit, zoomDelta: _zoomStep));
    on<MapZoomOutRequested>((e, emit) => _move(emit, zoomDelta: -_zoomStep));
    on<MapTiltUpRequested>((e, emit) => _move(emit, pitchDelta: _tiltStep));
    on<MapTiltDownRequested>((e, emit) => _move(emit, pitchDelta: -_tiltStep));
    on<MapRotateLeftRequested>((e, emit) => _move(emit, bearingDelta: -_rotateStep));
    on<MapRotateRightRequested>(
      (e, emit) => _move(emit, bearingDelta: _rotateStep),
    );
    on<MapNorthUpRequested>(_onNorthUp);
  }

  static const double _zoomStep = 1;
  static const double _tiltStep = 15;
  static const double _rotateStep = 15;
  static const double _minPitch = 0;
  static const double _maxPitch = 60;
  static const Duration _animationDuration = Duration(milliseconds: 800);

  MapController? _controller;

  void _onReady(MapCameraReady event, Emitter<MapCameraState> emit) {
    _controller = event.controller as MapController;
    emit(state.copyWith(isReady: true));
  }

  Future<void> _move(
    Emitter<MapCameraState> emit, {
    double zoomDelta = 0,
    double pitchDelta = 0,
    double bearingDelta = 0,
  }) async {
    final controller = _controller;
    if (controller == null || state.isMoving) return;
    final camera = controller.getCamera();
    final pitch = (camera.pitch + pitchDelta).clamp(_minPitch, _maxPitch);
    final bearing = (camera.bearing + bearingDelta) % 360;
    emit(state.copyWith(isMoving: true));
    try {
      await controller.animateCamera(
        zoom: camera.zoom + zoomDelta,
        bearing: bearing,
        pitch: pitch,
        nativeDuration: _animationDuration,
      );
    } finally {
      if (!isClosed) emit(state.copyWith(isMoving: false));
    }
  }

  Future<void> _onNorthUp(
    MapNorthUpRequested event,
    Emitter<MapCameraState> emit,
  ) async {
    final controller = _controller;
    if (controller == null || state.isMoving) return;
    emit(state.copyWith(isMoving: true));
    try {
      await controller.animateCamera(
        bearing: 0,
        pitch: 0,
        nativeDuration: _animationDuration,
      );
    } finally {
      if (!isClosed) emit(state.copyWith(isMoving: false));
    }
  }
}
