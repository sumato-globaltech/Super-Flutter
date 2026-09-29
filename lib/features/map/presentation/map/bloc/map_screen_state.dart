import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_view_state.dart';

class MapScreenState {
  final MapViewState mapViewState;

  const MapScreenState({required this.mapViewState});

  factory MapScreenState.initial() {
    return const MapScreenState(mapViewState: MapViewState());
  }

  MapScreenState copyWith({MapViewState? mapViewState}) {
    return MapScreenState(mapViewState: mapViewState ?? this.mapViewState);
  }
}
