import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../commands/map_commands.dart';
import '../models/map_point.dart';
import '../state/map_view_state.dart';

typedef MapInitialized = void Function(MapLibreMapController controller);

/// Raw MapLibre view: owns the native controller, translates the inbound
/// [MapCommand] stream into camera moves, and reports camera state outward.
///
/// Layer setup lives in [MapLayerService] (driven by the screen Cubit), not
/// here — this widget only forwards `onMapReady` once the style loads.
class MapView extends StatefulWidget {
  final String styleString;
  final MapInitialized? onMapInitialized;
  final MapViewState mapViewState;
  final Stream<MapCommand> mapCommand;

  final ValueChanged<MapViewState> onMapViewState;
  final double minZoom;
  final double maxZoom;

  final MapInitialized? onMapReady;

  const MapView({
    super.key,
    // this.styleString = "https://api.protomaps.com/styles/v5/dark/en.json?key=73c45a97eddd43fb",
    this.styleString = "https://demotiles.maplibre.org/style.json",
    this.onMapInitialized,
    this.onMapReady,
    required this.mapViewState,
    required this.mapCommand,
    required this.onMapViewState,
    this.minZoom = 4.0,
    this.maxZoom = 22.0,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapLibreMapController? _mapController;

  StreamSubscription<MapCommand>? _mapCommand;

  @override
  void initState() {
    super.initState();
    _mapCommand = widget.mapCommand.listen(_handleMapCommands);
  }

  @override
  void dispose() {
    _mapCommand?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: widget.styleString,
      onMapCreated: (controller) {
        _mapController = controller;
        widget.onMapInitialized?.call(controller);
      },
      onStyleLoadedCallback: _onStyleLoaded,
      minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
      initialCameraPosition: CameraPosition(
        target: widget.mapViewState.center.latLng,
        zoom: widget.mapViewState.zoom,
        tilt: widget.mapViewState.tilt,
        bearing: widget.mapViewState.bearing,
      ),
      onCameraIdle: _onCameraChanged,
      trackCameraPosition: true,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: true,
      logoEnabled: false,
    );
  }

  /// Translates one [MapCommand] from the Cubit's broadcast stream into a
  /// native camera call. Silently drops commands arriving before
  /// `onMapCreated` has supplied a controller.
  Future<void> _handleMapCommands(MapCommand mapCommand) async {
    final controller = _mapController;
    if (controller == null) return;

    switch (mapCommand) {
      case AnimateTo():
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: mapCommand.target.latLng,
              zoom: mapCommand.zoom,
              tilt: mapCommand.tilt ?? controller.cameraPosition?.tilt ?? 0.0,
              bearing:
                  mapCommand.bearing ?? controller.cameraPosition?.bearing ?? 0.0,
            ),
          ),
        );

      case MoveTo():
        await controller.moveCamera(
          CameraUpdate.newLatLng(mapCommand.target.latLng),
        );

      case ControlChanges():
        // instead of the widget snapshot to avoid stale mid-glide targets.
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _mapController?.cameraPosition?.target ?? widget.mapViewState.center.latLng,
              tilt: mapCommand.tilt ?? _mapController?.cameraPosition?.tilt ?? widget.mapViewState.tilt,
              zoom: mapCommand.zoom ?? _mapController?.cameraPosition?.zoom ?? widget.mapViewState.zoom,
              bearing: mapCommand.bearing ?? _mapController?.cameraPosition?.bearing ?? widget.mapViewState.bearing,
            ),
          ),
        );
      case ResetCamera():
        await controller.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: mapCommand.mapViewState.center.latLng,
            tilt: mapCommand.mapViewState.tilt,
            zoom: mapCommand.mapViewState.zoom,
            bearing: mapCommand.mapViewState.bearing
          )
        ));
        break;
    }
  }

  /// Reads the live native camera position on every camera-idle event and
  /// forwards it as [MapViewState], keeping the Cubit's snapshot (and hence
  /// the zoom/tilt/bearing buttons) in sync with gesture-driven moves.
  Future<void> _onCameraChanged() async {
    final controller = _mapController;
    if (controller == null) return;
    final cameraPosition = controller.cameraPosition;

    if (cameraPosition?.target == null) return;

    final newState = MapViewState(
      center: MapPoint(
        latitude: cameraPosition!.target.latitude,
        longitude: cameraPosition.target.longitude,
      ),
      zoom: cameraPosition.zoom,
      tilt: cameraPosition.tilt,
      bearing: cameraPosition.bearing,
    );

    widget.onMapViewState(newState);
  }

  Future<void>? _styleSetupFuture;

  /// Coalesces rapid style-loaded callbacks: only one [_setupStyle] runs at
  /// a time, and the guard resets when it completes so later reloads re-run.
  void _onStyleLoaded() {
    _styleSetupFuture ??= _setupStyle().whenComplete(() {
      _styleSetupFuture = null;
    });
  }

  /// Forwards the ready controller to the parent exactly once per style
  /// load. Layer setup itself is the Cubit's job (see `ensureBaseLayers`),
  /// triggered from the parent's `onMapReady` callback.
  Future<void> _setupStyle() async {
    final controller = _mapController;
    if (controller == null) return;
    widget.onMapReady?.call(controller);
  }
}
