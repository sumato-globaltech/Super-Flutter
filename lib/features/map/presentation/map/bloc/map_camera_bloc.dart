import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'map_camera_event.dart';
import 'map_camera_state.dart';

/// Screen Bloc for [MapScreen]. Owns animated camera movements (zoom, tilt,
/// bearing) driven by [MapCameraControls]. No-ops until [MapCameraReady].
@injectable
class MapCameraBloc extends Bloc<MapCameraEvent, MapCameraState> {
  MapCameraBloc() : super(const MapCameraState()) {
    on<MapCameraReady>(_onReady);
    on<MapZoomInRequested>(
      (e, emit) => _animate(emit, CameraUpdate.zoomIn()),
    );
    on<MapZoomOutRequested>(
      (e, emit) => _animate(emit, CameraUpdate.zoomOut()),
    );
    on<MapTiltUpRequested>((e, emit) => _tiltBy(emit, _tiltStep));
    on<MapTiltDownRequested>((e, emit) => _tiltBy(emit, -_tiltStep));
    on<MapRotateLeftRequested>((e, emit) => _rotateBy(emit, -_rotateStep));
    on<MapRotateRightRequested>((e, emit) => _rotateBy(emit, _rotateStep));
    on<MapNorthUpRequested>(_onNorthUp);
  }

  static const double _tiltStep = 15;
  static const double _rotateStep = 15;
  static const double _minTilt = 0;
  static const double _maxTilt = 60;
  static const Duration _animationDuration = Duration(milliseconds: 800);

  MapLibreMapController? _controller;

  void _onReady(MapCameraReady event, Emitter<MapCameraState> emit) {
    _controller = event.controller as MapLibreMapController;
    emit(state.copyWith(isReady: true));
  }

  Future<void> _animate(Emitter<MapCameraState> emit, CameraUpdate update) async {
    final controller = _controller;
    if (controller == null || state.isMoving) return;
    emit(state.copyWith(isMoving: true));
    try {
      await controller.animateCamera(update, duration: _animationDuration);
    } finally {
      if (!isClosed) emit(state.copyWith(isMoving: false));
    }
  }

  Future<void> _tiltBy(Emitter<MapCameraState> emit, double delta) async {
    final currentTilt = _controller?.cameraPosition?.tilt ?? 0;
    final tilt = (currentTilt + delta).clamp(_minTilt, _maxTilt);
    await _animate(emit, CameraUpdate.tiltTo(tilt));
  }

  Future<void> _rotateBy(Emitter<MapCameraState> emit, double delta) async {
    final bearing = ((_controller?.cameraPosition?.bearing ?? 0) + delta) % 360;
    await _animate(emit, CameraUpdate.bearingTo(bearing));
  }

  Future<void> _onNorthUp(
    MapNorthUpRequested event,
    Emitter<MapCameraState> emit,
  ) async {
    final controller = _controller;
    if (controller == null || state.isMoving) return;
    final camera = controller.cameraPosition;
    emit(state.copyWith(isMoving: true));
    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: camera?.target ?? const LatLng(37.7749, -122.4194),
            zoom: camera?.zoom ?? 12,
            bearing: 0,
            tilt: 0,
          ),
        ),
        duration: _animationDuration,
      );
    } finally {
      if (!isClosed) emit(state.copyWith(isMoving: false));
    }
  }
}
