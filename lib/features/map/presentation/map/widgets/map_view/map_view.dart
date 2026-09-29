import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/logging/app_logger.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_commands.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_point.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_view_state.dart';

typedef MapInitialized = void Function(MapLibreMapController controller);
typedef MapReady = void Function(MapLibreMapController controller);

class MapView extends StatefulWidget {
  final String styleString;
  final MapInitialized? onMapInitialized;
  final MapViewState mapViewState;
  final Stream<MapCommand> mapCommand;

  final ValueChanged<MapViewState> onMapViewState;
  final double minZoom;
  final double maxZoom;

  final MapReady? onMapReady;

  const new({
    super.key,
    this.styleString = "https://api.protomaps.com/styles/v5/dark/en.json?key=73c45a97eddd43fb",
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

  final AppLogger appLogger = getIt.get<AppLogger>();

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
      // styleString: widget.styleString,
      styleString: MapLibreStyles.demo,
      onMapCreated: (controller) {
        _mapController = controller;
        widget.onMapInitialized?.call(controller);
      },
      onStyleLoadedCallback: () {
        appLogger.debug("style loaded ${DateTime.now()}", name: "mridx");
        // if (_mapController != null) {
        //   widget.onMapReady?.call(_mapController!);
        //   addMapLayers(_mapController!);
        // }
        _onStyleLoaded();
      },
      minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
      initialCameraPosition: CameraPosition(
        target: widget.mapViewState.center.latLng,
        zoom: widget.mapViewState.zoom,
        tilt: widget.mapViewState.tilt,
        bearing: widget.mapViewState.bearing,
      ),
      onCameraIdle: () {
        _onCameraChanged();
      },
      trackCameraPosition: true,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: true,
      logoEnabled: false,
      attributionButtonMargins: Point(-100, 100),
    );
  }

  Future<void> addMapLayers(MapLibreMapController controller) async {
    final sources = await controller.getSourceIds();
    final layers = await controller.getLayerIds();

    if (!sources.contains('satellite_source')) {
      await controller.addSource(
        'satellite_source',
        const RasterSourceProperties(
          tiles: ['https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'],
          tileSize: 256,
          volatile: true,
        ),
      );
    }

    if (!layers.contains('satellite_layer')) {
      await controller.addRasterLayer(
        'satellite_source',
        'satellite_layer',
        RasterLayerProperties(rasterOpacity: 1.0),
      );
    }

    if (!sources.contains('nh')) {
      await controller.addSource(
        "nh",
        VectorSourceProperties(
          url: "pmtiles://http://64.227.134.64/pmtiles.php?file=nagaland_NH.pmtiles",
        ),
      );
    }

    if (!layers.contains('nh_layer')) {
      await controller.addLayer(
        'nh',
        'nh_layer',
        LineLayerProperties(lineColor: "#E03F4F", lineWidth: 8.0),
        sourceLayer: 'nagaland',
      );
    }

    if (!sources.contains('villages_source')) {
      await controller.addSource(
        'villages_source',
        GeojsonSourceProperties(data: 'http://64.227.134.64/nagaland_vill.geojson'),
      );
    }

    if (!layers.contains('villages_layer')) {
      await controller.addCircleLayer(
        'villages_source',
        'villages_layer',
        const CircleLayerProperties(
          circleRadius: 8.0,
          circleColor: "#11b4da",
          circleStrokeColor: "000000",
          circleStrokeWidth: 2.0,
          visibility: 'none',
        ),
      );
    }
  }

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
              bearing: mapCommand.bearing ?? controller.cameraPosition?.bearing ?? 0.0,
            ),
          ),
        );

      case MoveTo():
        await controller.moveCamera(CameraUpdate.newLatLng(mapCommand.target.latLng));

      case ControlChanges():
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: widget.mapViewState.center.latLng,
              tilt: mapCommand.tilt ?? controller.cameraPosition?.tilt ?? widget.mapViewState.tilt,
              zoom: mapCommand.zoom ?? controller.cameraPosition?.zoom ?? widget.mapViewState.zoom,
              bearing:
                  mapCommand.bearing ??
                  controller.cameraPosition?.bearing ??
                  widget.mapViewState.bearing,
            ),
          ),
        );
      case ResetCamera():
      //
    }
  }

  Future<void> _onCameraChanged() async {
    final controller = _mapController;
    if (controller == null) {
      appLogger.debug(name: "mridx", " controller is null");
      return;
    }
    final cameraPosition = controller.cameraPosition;

    if (cameraPosition?.target == null) {
      appLogger.debug(name: "mridx", "camera position is null");
      return;
    }

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

  void _onStyleLoaded() {
    _styleSetupFuture ??= _setupStyle().whenComplete(() {
      _styleSetupFuture = null;
    });
  }

  Future<void> _setupStyle() async {
    final controller = _mapController;

    if (controller == null) {
      return;
    }

    // await _ensureVillageSource(controller);
    // await _ensureVillageLayer(controller);
    await addMapLayers(controller);
    widget.onMapReady?.call(controller);
  }

  Future<void> _ensureVillageSource(MapLibreMapController controller) async {
    final sources = await controller.getSourceIds();

    if (sources.contains('villages_source')) {
      return;
    }

    await controller.addSource(
      'villages_source',
      GeojsonSourceProperties(data: 'http://64.227.134.64/nagaland_vill.geojson'),
    );
  }

  Future<void> _ensureVillageLayer(MapLibreMapController controller) async {
    final layers = await controller.getLayerIds();

    if (layers.contains('villages_layer')) {
      return;
    }

    await controller.addCircleLayer(
      'villages_source',
      'villages_layer',
      const CircleLayerProperties(
        circleRadius: 4.0,
        circleColor: '#fb923c',
        circleStrokeColor: '#000000',
        circleStrokeWidth: 2.0,
      ),
    );
  }
}
