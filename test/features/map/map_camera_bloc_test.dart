import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_bloc.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_event.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_state.dart';
import 'package:super_flutter/features/map/presentation/map/style/map_style_enhancer.dart';

class MockMapController extends Mock implements MapLibreMapController {}

class FakeMapController extends Fake implements MapLibreMapController {}

class MockMapStyleEnhancer extends Mock implements MapStyleEnhancer {}

CameraPosition _position({
  double zoom = 12,
  double bearing = 0,
  double tilt = 0,
}) => CameraPosition(
  target: const LatLng(37.7749, -122.4194),
  zoom: zoom,
  bearing: bearing,
  tilt: tilt,
);

void main() {
  setUpAll(() {
    registerFallbackValue(CameraUpdate.zoomIn());
    registerFallbackValue(const Duration(milliseconds: 800));
    registerFallbackValue(FakeMapController());
  });

  late MockMapController controller;
  late MockMapStyleEnhancer enhancer;

  setUp(() {
    controller = MockMapController();
    enhancer = MockMapStyleEnhancer();
    when(() => enhancer.enhance(any())).thenAnswer((_) async => true);
    when(() => enhancer.setGlobeEnabled(any(), any())).thenAnswer((_) async {});
    when(
      () => controller.animateCamera(any(), duration: any(named: 'duration')),
    ).thenAnswer((_) async => true);
  });

  blocTest<MapCameraBloc, MapCameraState>(
    'ignores camera moves before the controller is ready',
    build: () => MapCameraBloc(enhancer),
    act: (b) => b.add(const MapZoomInRequested()),
    expect: () => [],
    verify: (_) => verifyNever(
      () => controller.animateCamera(any(), duration: any(named: 'duration')),
    ),
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'zooms in with animation',
    build: () => MapCameraBloc(enhancer),
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapZoomInRequested()),
    expect: () => [
      const MapCameraState(isReady: true, isMoving: true),
      const MapCameraState(isReady: true),
    ],
    verify: (_) {
      final captured = verify(
        () => controller.animateCamera(
          captureAny(),
          duration: const Duration(milliseconds: 800),
        ),
      ).captured;
      expect((captured.single as CameraUpdate).toJson(), ['zoomIn']);
    },
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'tilts up and clamps tilt at 60 degrees',
    build: () {
      when(() => controller.cameraPosition).thenReturn(_position(tilt: 50));
      return MapCameraBloc(enhancer);
    },
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapTiltUpRequested()),
    verify: (_) {
      final captured = verify(
        () => controller.animateCamera(
          captureAny(),
          duration: any(named: 'duration'),
        ),
      ).captured;
      expect((captured.single as CameraUpdate).toJson(), ['tiltTo', 60.0]);
    },
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'rotates right and wraps bearing at 360 degrees',
    build: () {
      when(() => controller.cameraPosition).thenReturn(_position(bearing: 350));
      return MapCameraBloc(enhancer);
    },
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapRotateRightRequested()),
    verify: (_) {
      final captured = verify(
        () => controller.animateCamera(
          captureAny(),
          duration: any(named: 'duration'),
        ),
      ).captured;
      expect((captured.single as CameraUpdate).toJson(), ['bearingTo', 5.0]);
    },
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'resets to North-up keeping target and zoom',
    build: () {
      when(() => controller.cameraPosition).thenReturn(
        _position(zoom: 14, bearing: 120, tilt: 45),
      );
      return MapCameraBloc(enhancer);
    },
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapNorthUpRequested()),
    verify: (_) {
      final captured = verify(
        () => controller.animateCamera(
          captureAny(),
          duration: any(named: 'duration'),
        ),
      ).captured;
      final json = (captured.single as CameraUpdate).toJson() as List;
      expect(json.first, 'newCameraPosition');
      final position = CameraPosition.fromMap(json[1])!;
      expect(position.bearing, 0);
      expect(position.tilt, 0);
      expect(position.zoom, 14);
      expect(position.target.latitude, 37.7749);
    },
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'applies globe projection, terrain and sky on style load',
    build: () => MapCameraBloc(enhancer),
    seed: () => const MapCameraState(isReady: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapStyleLoaded()),
    expect: () => [
      const MapCameraState(isReady: true, globeEnabled: true),
    ],
    verify: (_) => verify(() => enhancer.enhance(controller)).called(1),
  );

  blocTest<MapCameraBloc, MapCameraState>(
    'toggles projection between globe and mercator',
    build: () => MapCameraBloc(enhancer),
    seed: () => const MapCameraState(isReady: true, globeEnabled: true),
    act: (b) => b
      ..add(MapCameraReady(controller))
      ..add(const MapProjectionToggled()),
    expect: () => [
      const MapCameraState(isReady: true, globeEnabled: false),
    ],
    verify: (_) =>
        verify(() => enhancer.setGlobeEnabled(controller, false)).called(1),
  );
}
