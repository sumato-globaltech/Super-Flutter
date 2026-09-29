import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_view_state.dart';

/// Screen-level state: live camera snapshot plus layer pipeline status.
class MapScreenState {
  final MapViewState mapViewState;

  /// True while base layers are being applied at style setup.
  final bool layersLoading;

  /// Layer ids that failed to apply (empty = all ready).
  final List<String> layersFailed;

  const MapScreenState({
    required this.mapViewState,
    this.layersLoading = false,
    this.layersFailed = const [],
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
  }) {
    return MapScreenState(
      mapViewState: mapViewState ?? this.mapViewState,
      layersLoading: layersLoading ?? this.layersLoading,
      layersFailed: layersFailed ?? this.layersFailed,
    );
  }
}
