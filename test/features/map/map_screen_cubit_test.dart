import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_cubit.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_state.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_catalog.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_definition.dart';
import 'package:super_flutter/features/map/presentation/map/layers/map_layer_service.dart';

class MockMapController extends Mock implements MapLibreMapController {}

class FakeMapController extends Fake implements MapLibreMapController {}

class MockMapLayerService extends Mock implements MapLayerService {}

class MockLayerCatalog extends Mock implements LayerCatalog {}

const _defs = [
  LayerDefinition(
    id: 'satellite_layer',
    sourceId: 'satellite_source',
    group: 'base',
    kind: LayerKind.raster,
    source: RasterTilesSource(tiles: ['https://tiles.example/{z}/{x}/{y}.png']),
    eager: true,
  ),
  LayerDefinition(
    id: 'villages_layer',
    sourceId: 'villages_source',
    group: 'overlays',
    kind: LayerKind.circle,
    source: GeoJsonSource(data: 'https://tiles.example/villages.geojson'),
    visible: false,
  ),
];

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMapController());
    registerFallbackValue(
      const LayerDefinition(
        id: 'x',
        sourceId: 'x',
        group: 'base',
        kind: LayerKind.raster,
        source: RasterTilesSource(tiles: ['https://x.example']),
      ),
    );
  });

  late MockMapController controller;
  late MockMapLayerService layers;
  late MockLayerCatalog catalog;

  setUp(() {
    controller = MockMapController();
    layers = MockMapLayerService();
    catalog = MockLayerCatalog();
    when(() => catalog.load()).thenAnswer((_) async => _defs);
  });

  MapScreenCubit buildCubit() => MapScreenCubit(layers, catalog);

  blocTest<MapScreenCubit, MapScreenState>(
    'reports loading then ready when base layers apply',
    build: () {
      when(() => layers.ensureEagerLayers(any())).thenAnswer(
        (_) async => const MapLayersResult(applied: ['satellite_layer']),
      );
      return buildCubit();
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
      return buildCubit();
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
      return buildCubit();
    },
    act: (c) async {
      // ignore: unawaited_futures
      c.ensureBaseLayers(controller);
      await c.ensureBaseLayers(controller);
    },
    verify: (_) => verify(() => layers.ensureEagerLayers(any())).called(1),
  );

  blocTest<MapScreenCubit, MapScreenState>(
    'toggle loads the lazy group on first enable then flips visibility',
    build: () {
      when(() => layers.ensureEagerLayers(any())).thenAnswer(
        (_) async => const MapLayersResult(applied: ['satellite_layer']),
      );
      when(() => layers.ensureGroup(any(), any())).thenAnswer(
        (_) async => const MapLayersResult(applied: ['villages_layer']),
      );
      when(() => layers.setVisible(any(), any(), any()))
          .thenAnswer((_) async {});
      return buildCubit();
    },
    act: (c) async {
      await c.ensureBaseLayers(controller);
      clearInteractions(layers);
      await c.toggleLayer(
        controller,
        _defs.firstWhere((d) => d.id == 'villages_layer'),
      );
    },
    skip: 2, // loading + ready emissions
    expect: () => [
      isA<MapScreenState>().having(
        (s) => s.layerVisibility['villages_layer'],
        'visible',
        true,
      ),
    ],
    verify: (_) {
      verify(() => layers.ensureGroup(controller, 'overlays')).called(1);
      verify(() => layers.setVisible(controller, 'villages_layer', true))
          .called(1);
    },
  );

  blocTest<MapScreenCubit, MapScreenState>(
    'opacity commit delegates to the service and updates state',
    build: () {
      when(() => layers.ensureEagerLayers(any())).thenAnswer(
        (_) async => const MapLayersResult(applied: ['satellite_layer']),
      );
      when(() => layers.updateOpacity(any(), any(), any(),
              visible: any(named: 'visible'))).thenAnswer((_) async {});
      return buildCubit();
    },
    act: (c) async {
      await c.ensureBaseLayers(controller);
      clearInteractions(layers);
      await c.setLayerOpacity(
        controller,
        _defs.firstWhere((d) => d.id == 'satellite_layer'),
        0.5,
      );
    },
    skip: 2,
    expect: () => [
      isA<MapScreenState>().having(
        (s) => s.layerOpacity['satellite_layer'],
        'opacity',
        0.5,
      ),
    ],
    verify: (_) => verify(
      () => layers.updateOpacity(controller, _defs.first, 0.5, visible: true),
    ).called(1),
  );
}
