# `components/map_view` — reusable MapLibre view

A self-contained map component any feature can embed. It owns the native
`MapLibreMapController` and nothing else: camera intent flows in, camera
state flows out, and styling/layers stay in the owning feature.

```
lib/components/map_view/
  view/map_view.dart         # MapView widget (native controller owner)
  state/map_view_state.dart  # MapViewState snapshot + LatLng/CameraPosition adapters
  commands/map_commands.dart # MapCommand sealed family (AnimateTo/MoveTo/ControlChanges/ResetCamera)
  models/map_point.dart      # MapPoint lat/lng value object
  models/map_bounding_box.dart  # MapBoundingBox (reserved for fit-bounds)
```

## Reuse contract

- **Imports:** Flutter, `maplibre_gl`, `equatable` only. Never import
  `features/` or app code — that's what keeps every consumer safe.
- **In:** `mapViewState` (initial camera + snapshot), `Stream<MapCommand>`
  for camera moves, `minMaxZoomPreference`, `styleString`, gesture flags.
- **Out:** `onMapCreated` (raw controller), `onStyleLoadedCallback` (style
  ready), `onMapViewState` (snapshot on every camera-idle).
- **Not here:** style URLs, tile sources, layer setup, and panel UI live in
  the owning feature (see `features/map/.../layers/` and the screen's panel).

## Usage

```dart
MapView(
  mapViewState: state.mapViewState,
  mapCommand: cubit.mapCommand,          // Stream<MapCommand>
  onMapReady: (controller) => cubit.ensureBaseLayers(controller),
  onMapViewState: (snapshot) => cubit.mapViewStateChanged(snapshot),
)
```

To drive the camera, emit a command, e.g.
`MapCommand` → `ControlChanges(zoom: ..., tilt: ..., bearing: ...)`; the view
translates it into `animateCamera`/`moveCamera` calls internally.
