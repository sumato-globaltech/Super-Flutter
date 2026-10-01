import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/logging/app_logger.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_catalog.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_definition.dart';
import 'package:super_flutter/features/map/presentation/map/layers/map_layer_service.dart';

class MockMapController extends Mock implements MapLibreMapController {}

AppLogger _silentLogger() => AppLogger(enabled: false);

class FakeCatalog extends Fake implements LayerCatalog {
  FakeCatalog(this.defs);

  final List<LayerDefinition> defs;

  @override
  Future<List<LayerDefinition>> load() async => defs;
}

const _raster = LayerDefinition(
  id: 'satellite_layer',
  sourceId: 'satellite_source',
  group: 'base',
  kind: LayerKind.raster,
  source: RasterTilesSource(tiles: ['https://tiles.example/{z}/{x}/{y}.png']),
  eager: true,
);

const _line = LayerDefinition(
  id: 'nh_layer',
  sourceId: 'nh',
  group: 'overlays',
  kind: LayerKind.line,
  source: VectorUrlSource(url: 'pmtiles://https://tiles.example/nh.pmtiles'),
  sourceLayer: 'roads',
  lineColor: '#E03F4F',
  lineWidth: 8.0,
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const RasterSourceProperties(tiles: ['https://x.example']),
    );
    registerFallbackValue(RasterLayerProperties(rasterOpacity: 1.0));
    registerFallbackValue(
      const LineLayerProperties(lineColor: '#000000', lineWidth: 1.0),
    );
    registerFallbackValue(
      const CircleLayerProperties(circleRadius: 1.0),
    );
    registerFallbackValue(
      const SymbolLayerProperties(),
    );
    registerFallbackValue(
      const FillLayerProperties(),
    );
    registerFallbackValue(
      const FillExtrusionLayerProperties(),
    );
    registerFallbackValue(
      const HillshadeLayerProperties(),
    );
    registerFallbackValue(
      const ColorReliefLayerProperties(),
    );
    registerFallbackValue(
      const BackgroundLayerProperties(),
    );
    registerFallbackValue(
      const HeatmapLayerProperties(),
    );
  });

  late MockMapController controller;

  /// Sources/layers the mock has "added", so concurrent ensures observe
  /// each other's work like the real platform controller would.
  late Set<String> addedSources;
  late Set<String> addedLayers;

  setUp(() {
    controller = MockMapController();
    addedSources = {};
    addedLayers = {};
    when(() => controller.getSourceIds())
        .thenAnswer((_) async => addedSources.toList());
    when(() => controller.getLayerIds())
        .thenAnswer((_) async => addedLayers.toList());
    when(() => controller.addSource(any(), any())).thenAnswer((invocation) async {
      addedSources.add(invocation.positionalArguments[0] as String);
    });
    when(
      () => controller.addRasterLayer(any(), any(), any(),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[1] as String);
    });
    when(
      () => controller.addLayer(any(), any(), any(),
          belowLayerId: any(named: 'belowLayerId'),
          sourceLayer: any(named: 'sourceLayer'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[1] as String);
    });
    when(
      () => controller.addSymbolLayer(any(), any(), any(),
          sourceLayer: any(named: 'sourceLayer'),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[1] as String);
    });
    when(
      () => controller.addFillLayer(any(), any(), any(),
          sourceLayer: any(named: 'sourceLayer'),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[1] as String);
    });
    when(
      () => controller.addFillExtrusionLayer(any(), any(), any(),
          sourceLayer: any(named: 'sourceLayer'),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[1] as String);
    });
    when(
      () => controller.addHillshadeLayer(any(), any(), any(),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[1] as String);
    });
    when(
      () => controller.addColorReliefLayer(any(), any(), any(),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[1] as String);
    });
    when(
      () => controller.addBackgroundLayer(any(), any(),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[0] as String);
    });
    when(
      () => controller.addHeatmapLayer(any(), any(), any(),
          sourceLayer: any(named: 'sourceLayer'),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((invocation) async {
      addedLayers.add(invocation.positionalArguments[1] as String);
    });
    when(
      () => controller.setLayerVisibility(any(), any()),
    ).thenAnswer((_) async {});
  });

  test('skips sources and layers that already exist', () async {
    when(() => controller.getSourceIds())
        .thenAnswer((_) async => ['satellite_source']);
    when(() => controller.getLayerIds())
        .thenAnswer((_) async => ['satellite_layer']);
    final service = MapLayerService(
      FakeCatalog([_raster]),
      _silentLogger(),
    );

    final result = await service.ensureEagerLayers(controller);

    expect(result.applied, ['satellite_layer']);
    expect(result.failed, isEmpty);
    verifyNever(() => controller.addSource(any(), any()));
  });

  test('one failing layer does not block its siblings', () async {
    when(() => controller.addSource('nh', any())).thenThrow(
      Exception('offline tile host'),
    );
    final service = MapLayerService(
      FakeCatalog([_raster, _line]),
      _silentLogger(),
    );

    final result = await service.ensureGroup(controller, 'overlays');

    // Only the overlays group runs; nh fails in isolation.
    expect(result.applied, isEmpty);
    expect(result.failed, ['nh_layer']);
  });

  test('ensureGroup only runs the requested group', () async {
    final service = MapLayerService(
      FakeCatalog([_raster, _line]),
      _silentLogger(),
    );

    final result = await service.ensureGroup(controller, 'base');

    expect(result.applied, ['satellite_layer']);
    verifyNever(() => controller.addSource('nh', any()));
  });

  test('updateOpacity re-adds the layer with new paint', () async {
    when(() => controller.removeLayer(any())).thenAnswer((_) async {});
    when(
      () => controller.addCircleLayer(any(), any(), any(),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).thenAnswer((_) async {});
    const circle = LayerDefinition(
      id: 'villages_layer',
      sourceId: 'villages_source',
      group: 'overlays',
      kind: LayerKind.circle,
      source: GeoJsonSource(data: 'https://tiles.example/v.geojson'),
    );
    final service = MapLayerService(
      FakeCatalog([circle]),
      _silentLogger(),
    );

    await service.updateOpacity(controller, circle, 0.4, visible: false);

    verify(() => controller.removeLayer('villages_layer')).called(1);
    final captured = verify(
      () => controller.addCircleLayer(
        'villages_source',
        'villages_layer',
        captureAny(),
        belowLayerId: any(named: 'belowLayerId'),
        minzoom: any(named: 'minzoom'),
        maxzoom: any(named: 'maxzoom'),
      ),
    ).captured;
    expect(
      (captured.single as CircleLayerProperties).toJson()['circle-opacity'],
      0.4,
    );
    verify(() => controller.setLayerVisibility('villages_layer', false))
        .called(1);
  });

  test('concurrent ensures serialize instead of double-adding', () async {
    final service = MapLayerService(
      FakeCatalog([_raster]),
      _silentLogger(),
    );

    final results = await Future.wait([
      service.ensureGroup(controller, 'base'),
      service.ensureGroup(controller, 'base'),
    ]);

    for (final result in results) {
      expect(result.applied, ['satellite_layer']);
      expect(result.failed, isEmpty);
    }
    // Second ensure observes the layer added by the first and skips it.
    verify(() => controller.addSource('satellite_source', any())).called(1);
  });

  test('already-exists races are treated as success', () async {
    when(() => controller.addSource('satellite_source', any())).thenThrow(
      Exception('Source satellite_source already exists'),
    );
    final service = MapLayerService(
      FakeCatalog([_raster]),
      _silentLogger(),
    );

    final result = await service.ensureGroup(controller, 'base');

    expect(result.applied, ['satellite_layer']);
    expect(result.failed, isEmpty);
  });

  test('each new layer kind calls its typed add-method', () async {
    const defs = [
      LayerDefinition(
        id: 'labels',
        sourceId: 's',
        group: 'g',
        kind: LayerKind.symbol,
        source: GeoJsonSource(data: 'https://x.example/p.geojson'),
        textField: '{name}',
      ),
      LayerDefinition(
        id: 'fill',
        sourceId: 's',
        group: 'g',
        kind: LayerKind.fill,
        source: GeoJsonSource(data: 'https://x.example/p.geojson'),
      ),
      LayerDefinition(
        id: 'hill',
        sourceId: 'dem',
        group: 'g',
        kind: LayerKind.hillshade,
        source: RasterDemSource(tiles: ['https://x.example/{z}/{x}/{y}.png']),
      ),
      LayerDefinition(
        id: 'heat',
        sourceId: 's',
        group: 'g',
        kind: LayerKind.heatmap,
        source: GeoJsonSource(data: 'https://x.example/p.geojson'),
      ),
      LayerDefinition(
        id: 'bg',
        sourceId: '',
        group: 'g',
        kind: LayerKind.background,
        source: GeoJsonSource(data: 'https://x.example/p.geojson'),
      ),
    ];
    final service = MapLayerService(FakeCatalog(defs), _silentLogger());

    final result = await service.ensureGroup(controller, 'g');

    expect(result.failed, isEmpty);
    expect(result.applied, ['labels', 'fill', 'hill', 'heat', 'bg']);
    verify(
      () => controller.addSymbolLayer(any(), any(), any(),
          sourceLayer: any(named: 'sourceLayer'),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).called(1);
    verify(
      () => controller.addHillshadeLayer(any(), any(), any(),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).called(1);
    verify(
      () => controller.addBackgroundLayer(any(), any(),
          belowLayerId: any(named: 'belowLayerId'),
          minzoom: any(named: 'minzoom'),
          maxzoom: any(named: 'maxzoom')),
    ).called(1);
    // Background skips the source step entirely.
    verifyNever(() => controller.addSource('', any()));
  });

  test('hillshade exaggeration re-adds with new paint', () async {
    when(() => controller.removeLayer(any())).thenAnswer((_) async {});
    const def = LayerDefinition(
      id: 'hill',
      sourceId: 'dem',
      group: 'g',
      kind: LayerKind.hillshade,
      source: RasterDemSource(tiles: ['https://x.example/{z}/{x}/{y}.png']),
    );
    final service = MapLayerService(FakeCatalog([def]), _silentLogger());

    await service.updateExaggeration(controller, def, 2.5);

    final captured = verify(
      () => controller.addHillshadeLayer(
        'dem',
        'hill',
        captureAny(),
        belowLayerId: any(named: 'belowLayerId'),
        minzoom: any(named: 'minzoom'),
        maxzoom: any(named: 'maxzoom'),
      ),
    ).captured;
    expect(
      (captured.single as HillshadeLayerProperties)
          .toJson()['hillshade-exaggeration'],
      2.5,
    );
  });
}
