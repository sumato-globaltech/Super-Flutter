import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_state.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_catalog.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_definition.dart';
import 'package:super_flutter/features/map/presentation/map/layers/map_layer_service.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_commands.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_point.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_view_state.dart';

@injectable
class MapScreenCubit extends Cubit<MapScreenState> {
  MapScreenCubit(this._layers, this._catalog)
    : super(MapScreenState(mapViewState: MapViewState()));

  final MapLayerService _layers;
  final LayerCatalog _catalog;

  List<LayerDefinition> _definitions = const [];

  /// Catalog definitions for the layer panel. Loaded once with base layers.
  List<LayerDefinition> get layerDefinitions => _definitions;

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

  /// Applies eager (base) layers once the style is ready. Call from the
  /// screen's `onMapReady` callback. Also snapshots catalog visibility and
  /// opacity defaults for the layer panel.
  Future<void> ensureBaseLayers(MapLibreMapController controller) async {
    if (state.layersLoading) return;
    emit(state.copyWith(layersLoading: true, layersFailed: const []));
    _definitions = await _catalog.load();
    final result = await _layers.ensureEagerLayers(controller);
    if (isClosed) return;
    emit(
      state.copyWith(
        layersLoading: false,
        layersFailed: result.failed,
        layerVisibility: {for (final d in _definitions) d.id: d.visible},
        layerOpacity: {for (final d in _definitions) d.id: 1.0},
        layerExaggeration: {
          for (final d in _definitions)
            if (d.supportsExaggeration) d.id: d.hillshadeExaggeration ?? 1.0,
        },
      ),
    );
  }

  /// Loads one lazy catalog group on demand (e.g. when its toggle turns on).
  Future<void> ensureOverlayGroup(
    MapLibreMapController controller, [
    String group = 'overlays',
  ]) async {
    final result = await _layers.ensureGroup(controller, group);
    if (isClosed) return;
    emit(state.copyWith(layersFailed: result.failed));
  }

  /// Re-runs the base layer pipeline after a partial failure.
  Future<void> refreshLayers(MapLibreMapController controller) =>
      ensureBaseLayers(controller);

  /// Flips one layer's visibility. Lazy groups load on first enable.
  Future<void> toggleLayer(
    MapLibreMapController controller,
    LayerDefinition def,
  ) async {
    final visible = !(state.layerVisibility[def.id] ?? def.visible);
    if (visible) {
      await _layers.ensureGroup(controller, def.group);
    }
    await _layers.setVisible(controller, def.id, visible);
    if (isClosed) return;
    emit(
      state.copyWith(
        layerVisibility: {...state.layerVisibility, def.id: visible},
      ),
    );
  }

  /// Commits an opacity change (slider `onChangedEnd`). The layer is
  /// re-added with new paint; call sparingly, not per drag tick.
  Future<void> setLayerOpacity(
    MapLibreMapController controller,
    LayerDefinition def,
    double opacity,
  ) async {
    final clamped = opacity.clamp(0.0, 1.0);
    await _layers.updateOpacity(
      controller,
      def,
      clamped,
      visible: state.layerVisibility[def.id] ?? def.visible,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        layerOpacity: {...state.layerOpacity, def.id: clamped},
      ),
    );
  }

  /// Commits a hillshade exaggeration change (0–5). Re-adds the layer, so
  /// call on slider release, not per drag tick.
  Future<void> setHillshadeExaggeration(
    MapLibreMapController controller,
    LayerDefinition def,
    double exaggeration,
  ) async {
    final clamped = exaggeration.clamp(0.0, 5.0);
    await _layers.updateExaggeration(
      controller,
      def,
      clamped,
      visible: state.layerVisibility[def.id] ?? def.visible,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        layerExaggeration: {...state.layerExaggeration, def.id: clamped},
      ),
    );
  }

  @override
  Future<void> close() {
    _mapCommandsController.close();
    return super.close();
  }
}
