import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_cubit.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_state.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_definition.dart';
import 'package:super_flutter/features/map/presentation/map/layers/map_layer_service.dart';

class MockMapController extends Mock implements MapLibreMapController {}

class FakeMapController extends Fake implements MapLibreMapController {}

class MockMapLayerService extends Mock implements MapLayerService {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMapController());
  });

  late MockMapController controller;
  late MockMapLayerService layers;

  setUp(() {
    controller = MockMapController();
    layers = MockMapLayerService();
  });

  blocTest<MapScreenCubit, MapScreenState>(
    'reports loading then ready when base layers apply',
    build: () {
      when(() => layers.ensureEagerLayers(any())).thenAnswer(
        (_) async => const MapLayersResult(applied: ['satellite_layer']),
      );
      return MapScreenCubit(layers);
    },
    act: (c) => c.ensureBaseLayers(controller),
    expect: () => [
      isA<MapScreenState>().having((s) => s.layersLoading, 'loading', true),
      isA<MapScreenState>()
          .having((s) => s.layersLoading, 'loading', false)
          .having((s) => s.layersFailed, 'failed', isEmpty),
    ],
  );

  blocTest<MapScreenCubit, MapScreenState>(
    'reports failed layer ids for retry',
    build: () {
      when(() => layers.ensureEagerLayers(any())).thenAnswer(
        (_) async => const MapLayersResult(failed: ['satellite_layer']),
      );
      return MapScreenCubit(layers);
    },
    act: (c) => c.ensureBaseLayers(controller),
    skip: 1, // skip the loading emission
    expect: () => [
      isA<MapScreenState>().having((s) => s.layersFailed, 'failed', [
        'satellite_layer',
      ]),
    ],
  );

  blocTest<MapScreenCubit, MapScreenState>(
    'ignores duplicate ensure calls while loading',
    build: () {
      when(() => layers.ensureEagerLayers(any())).thenAnswer(
        (_) async => const MapLayersResult(applied: ['satellite_layer']),
      );
      return MapScreenCubit(layers);
    },
    act: (c) async {
      // ignore: unawaited_futures
      c.ensureBaseLayers(controller);
      await c.ensureBaseLayers(controller);
    },
    verify: (_) => verify(() => layers.ensureEagerLayers(any())).called(1),
  );
}
