import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/logging/app_logger.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_cubit.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_state.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_view.dart';

class MapScreenNew extends StatefulWidget {
  const new({super.key});

  @override
  State<MapScreenNew> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenNew> {
  late MapScreenCubit cubit;
  late MapLibreMapController mapController;
  final AppLogger appLogger = getIt.get<AppLogger>();

  @override
  void initState() {
    cubit = getIt.get<MapScreenCubit>();

    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MapScreenCubit, MapScreenState>(
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              body: Stack(
                children: [
                  MapView(
                    onMapInitialized: (controller) async {
                      // mapController = controller;
                    },
                    onMapReady: (controller) async {
                      appLogger.debug(
                        name: 'mridx',
                        'on map ready getting called ${DateTime.now()}!',
                      );
                      mapController = controller;
                      // await addMapLayers(controller);
                    },
                    mapViewState: state.mapViewState,
                    mapCommand: cubit.mapCommand,
                    onMapViewState: (mapViewState) {
                      cubit.mapViewStateChanged(mapViewState);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tilt - ${state.mapViewState.tilt}"),
                        Text("Zoom - ${state.mapViewState.zoom}"),
                        Text("Bearing - ${state.mapViewState.bearing}"),
                        Text("Center - ${state.mapViewState.center.toString()}"),
                        SizedBox(height: 24),
                        _ControlButton(
                          tooltip: 'Zoom in',
                          icon: Icons.add,
                          enabled: true,
                          onPressed: () {
                            cubit.makeZoomIn();
                          },
                        ),
                        const SizedBox(height: 8),
                        _ControlButton(
                          tooltip: 'Zoom out',
                          icon: Icons.remove,
                          enabled: true,
                          onPressed: () {
                            cubit.makeZoomOut();
                          },
                        ),
                        const SizedBox(height: 16),
                        _ControlButton(
                          tooltip: 'Tilt up',
                          icon: Icons.arrow_upward_outlined,
                          enabled: true,
                          onPressed: () {
                            cubit.tiltUp();
                          },
                        ),
                        const SizedBox(height: 8),
                        _ControlButton(
                          tooltip: 'Tilt down',
                          icon: Icons.arrow_downward_outlined,
                          enabled: true,
                          onPressed: () {
                            cubit.tiltDown();
                          },
                        ),
                        const SizedBox(height: 16),
                        _ControlButton(
                          tooltip: 'Rotate left',
                          icon: Icons.rotate_left_outlined,
                          enabled: true,
                          onPressed: () {
                            cubit.rotateLeft();
                          },
                        ),
                        const SizedBox(height: 8),
                        _ControlButton(
                          tooltip: 'Rotate right',
                          icon: Icons.rotate_right_outlined,
                          enabled: true,
                          onPressed: () {
                            cubit.rotateRight();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> addMapLayers(MapLibreMapController controller) async {
    final sources = await controller.getSourceIds();
    if (!sources.contains('villages_source')) {
      await controller.addSource(
        'villages_source',
        GeojsonSourceProperties(data: 'http://64.227.134.64/nagaland_vill.geojson'),
      );
    }

    final layers = await controller.getLayerIds();
    if (!layers.contains('villages_layer')) {
      await controller.addCircleLayer(
        'villages_source',
        'villages_layer',
        const CircleLayerProperties(
          circleRadius: 4.0,
          circleColor: '#fb923c',
          circleStrokeColor: '000000',
          circleStrokeWidth: 2.0,
        ),
      );
    }
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.selected = false,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: tooltip,
      child: FloatingActionButton.small(
        heroTag: tooltip,
        tooltip: tooltip,
        onPressed: enabled ? onPressed : null,
        backgroundColor: selected ? scheme.primary : null,
        foregroundColor: selected ? scheme.onPrimary : null,
        child: Icon(icon),
      ),
    );
  }
}
