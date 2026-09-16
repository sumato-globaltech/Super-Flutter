import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre/maplibre.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_bloc.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_event.dart';

/// Raw MapLibre view. Forwards the native controller to [MapCameraBloc] and
/// renders nothing else — controls live in `map_camera_controls.dart`.
class MapView extends StatefulWidget {
  const MapView({
    super.key,
    this.initialCenter = const Geographic(lon: -122.4194, lat: 37.7749),
    this.initialZoom = 12,
  });

  final Geographic initialCenter;
  final double initialZoom;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      options: MapOptions(
        initCenter: widget.initialCenter,
        initZoom: widget.initialZoom,
      ),
      onMapCreated: (controller) {
        if (mounted) {
          context.read<MapCameraBloc>().add(MapCameraReady(controller));
        }
      },
    );
  }
}
