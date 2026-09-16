import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre/maplibre.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_bloc.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_event.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_state.dart';

class MockMapController extends Mock implements MapController {}

MapCamera _camera({
  double zoom = 12,
  double bearing = 0,
  double pitch = 0,
}) => MapCamera(
  center: const Geographic(lon: -122.4194, lat: 37.7749),
  zoom: zoom,
  bearing: bearing,
  pitch: pitch,
);

void main() {
  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  late MockMapController controller;

  setUp(() {
    controller = MockMapController();
    when(
      () => controller.animateCamera(
        center: any(named: 'center'),
        zoom: any(named: 'zoom'),
        bearing: any(named: 'bearing'),
        pitch: any(named: 'pitch'),
        nativeDuration: any(named: 'nativeDuration'),
        webSpeed: any(named: 'webSpeed'),
        webMaxDuration: any(named: 'webMaxDuration'),
      ),
    ).thenAnswer((_) async {});
  });

  blocTest<MapCameraBloc, MapCameraState>(
    'ignores camera moves before the controller is ready',
    build: () => MapCameraBloc(),
    act: (b) => b.add(const MapZoomInRequested()),
    expect: () => [],
    verify: (_) => verifyNever(
      () => controller.animateCamera(
        center: any(named: 'center'),
        zoom: any(named: 'zoom'),
        bearing: any(named: 'bearing'),
        pitch: any(named: 'pitch'),
        nativeDuration: any(named: 'nativeDuration'),
        webSpeed: any(named: 'webSpeed'),
        webMaxDuration: any(named: 'webMaxDuration'),
      ),
    ),
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'zooms in by one level with animation',
    build: () {
      when(() => controller.getCamera()).thenReturn(_camera());
      return MapCameraBloc();
    },
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapZoomInRequested()),
    expect: () => [
      const MapCameraState(isReady: true, isMoving: true),
      const MapCameraState(isReady: true),
    ],
    verify: (_) => verify(
      () => controller.animateCamera(
        zoom: 13,
        bearing: 0,
        pitch: 0,
        nativeDuration: const Duration(milliseconds: 800),
      ),
    ).called(1),
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'tilts up and clamps pitch at 60 degrees',
    build: () {
      when(() => controller.getCamera()).thenReturn(_camera(pitch: 50));
      return MapCameraBloc();
    },
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapTiltUpRequested()),
    verify: (_) => verify(
      () => controller.animateCamera(
        zoom: 12,
        bearing: 0,
        pitch: 60,
        nativeDuration: const Duration(milliseconds: 800),
      ),
    ).called(1),
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'rotates right and wraps bearing at 360 degrees',
    build: () {
      when(() => controller.getCamera()).thenReturn(_camera(bearing: 350));
      return MapCameraBloc();
    },
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapRotateRightRequested()),
    verify: (_) => verify(
      () => controller.animateCamera(
        zoom: 12,
        bearing: 5,
        pitch: 0,
        nativeDuration: const Duration(milliseconds: 800),
      ),
    ).called(1),
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'resets to North-up keeping center and zoom',
    build: () {
      when(() => controller.getCamera()).thenReturn(
        _camera(zoom: 14, bearing: 120, pitch: 45),
      );
      return MapCameraBloc();
    },
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapNorthUpRequested()),
    verify: (_) => verify(
      () => controller.animateCamera(
        bearing: 0,
        pitch: 0,
        nativeDuration: const Duration(milliseconds: 800),
      ),
    ).called(1),
  );
}
