import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_bloc.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_event.dart';

/// Raw MapLibre view. Forwards the native controller to [MapCameraBloc] and
/// renders nothing else — controls live in `map_camera_controls.dart`.
class MapView extends StatefulWidget {
  const MapView({
    super.key,
    this.initialTarget = const LatLng(26.115103, 91.703239),
    this.initialZoom = 12,
  });

  final LatLng initialTarget;
  final double initialZoom;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: 'https://api.protomaps.com/styles/v5/dark/en.json?key=73c45a97eddd43fb',
      initialCameraPosition: CameraPosition(target: widget.initialTarget, zoom: widget.initialZoom),
      trackCameraPosition: true,
      onMapCreated: (controller) {
        if (mounted) {
          context.read<MapCameraBloc>().add(MapCameraReady(controller));
        }
      },
      onStyleLoadedCallback: () {
        if (mounted) {
          context.read<MapCameraBloc>().add(const MapStyleLoaded());
        }
      },
    );
  }
}
