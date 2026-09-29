import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_state.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_commands.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_point.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_view_state.dart';

@injectable
class MapScreenCubit extends Cubit<MapScreenState> {
  MapScreenCubit() : super(MapScreenState(mapViewState: MapViewState()));

  final _mapCommandsController = StreamController<MapCommand>.broadcast();

  Stream<MapCommand> get mapCommand => _mapCommandsController.stream;

  static const double _tiltStep = 15;
  static const double _rotateStep = 15;
  static const double _minTilt = 0;
  static const double _maxTilt = 60;

  void mapViewStateChanged(MapViewState mapViewState) {
    emit(state.copyWith(mapViewState: mapViewState));
  }

  void moveToLocation(MapPoint position) {
    _mapCommandsController.add(MoveTo(target: position));
  }

  void animateToLocation({required MapPoint position, required double zoom}) {
    _mapCommandsController.add(AnimateTo(target: position, zoom: zoom));
  }

  void makeZoomIn() {
    _mapCommandsController.add(
      ControlChanges(
        zoom: state.mapViewState.zoom + 1,
        tilt: state.mapViewState.tilt,
        bearing: state.mapViewState.bearing,
      ),
    );
  }

  void makeZoomOut() {
    _mapCommandsController.add(
      ControlChanges(
        zoom: (state.mapViewState.zoom - 1),
        tilt: state.mapViewState.tilt,
        bearing: state.mapViewState.bearing,
      ),
    );
  }

  void tiltUp() {
    _makeTilt(_tiltStep);
  }

  void tiltDown() {
    _makeTilt(-_tiltStep);
  }

  void _makeTilt(double delta) {
    final currentTilt = state.mapViewState.tilt;
    final tilt = (currentTilt + delta).clamp(_minTilt, _maxTilt);
    _mapCommandsController.add(
      ControlChanges(
        zoom: state.mapViewState.zoom,
        tilt: tilt,
        bearing: state.mapViewState.bearing,
      ),
    );
  }

  void rotateLeft() {
    _rotateBy(-_rotateStep);
  }

  void rotateRight() {
    _rotateBy(_rotateStep);
  }

  void _rotateBy(double delta) {
    final bearing = ((state.mapViewState.bearing) + delta) % 360;
    _mapCommandsController.add(
      ControlChanges(
        zoom: state.mapViewState.zoom,
        tilt: state.mapViewState.tilt,
        bearing: bearing,
      ),
    );
  }

  @override
  Future<void> close() {
    _mapCommandsController.close();
    return super.close();
  }
}
