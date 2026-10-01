import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_view_state.dart';

/// Screen-level state: live camera snapshot plus layer pipeline status.
class MapScreenState {
  final MapViewState mapViewState;

  /// True while base layers are being applied at style setup.
  final bool layersLoading;

  /// Layer ids that failed to apply (empty = all ready).
  final List<String> layersFailed;

  /// Per-layer visibility keyed by layer id. Populated from the catalog when
  /// base layers load; toggles update it optimistically.
  final Map<String, bool> layerVisibility;

  /// Per-layer opacity (0–1) keyed by layer id. Defaults to 1.0.
  final Map<String, double> layerOpacity;

  /// Per-layer hillshade exaggeration keyed by layer id.
  final Map<String, double> layerExaggeration;

  const MapScreenState({
    required this.mapViewState,
    this.layersLoading = false,
    this.layersFailed = const [],
    this.layerVisibility = const {},
    this.layerOpacity = const {},
    this.layerExaggeration = const {},
  });

  factory MapScreenState.initial() {
    return const MapScreenState(mapViewState: MapViewState());
  }

  bool get layersPartialFailure =>
      !layersLoading && layersFailed.isNotEmpty;

  MapScreenState copyWith({
    MapViewState? mapViewState,
    bool? layersLoading,
    List<String>? layersFailed,
    Map<String, bool>? layerVisibility,
    Map<String, double>? layerOpacity,
    Map<String, double>? layerExaggeration,
  }) {
    return MapScreenState(
      mapViewState: mapViewState ?? this.mapViewState,
      layersLoading: layersLoading ?? this.layersLoading,
      layersFailed: layersFailed ?? this.layersFailed,
      layerVisibility: layerVisibility ?? this.layerVisibility,
      layerOpacity: layerOpacity ?? this.layerOpacity,
      layerExaggeration: layerExaggeration ?? this.layerExaggeration,
    );
  }
}
