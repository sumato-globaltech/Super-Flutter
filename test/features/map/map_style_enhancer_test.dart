import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/logging/app_logger.dart';
import 'package:super_flutter/features/map/presentation/map/style/map_style_enhancer.dart';

class MockMapController extends Mock implements MapLibreMapController {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RasterDemSourceProperties());
    registerFallbackValue(const TerrainProperties(source: 'x'));
    registerFallbackValue(const SkyProperties());
  });

  late MockMapController controller;
  late MapStyleEnhancer enhancer;

  setUp(() {
    controller = MockMapController();
    enhancer = MapStyleEnhancer(AppLogger(enabled: false));

    when(() => controller.addSource(any(), any())).thenAnswer((_) async {});
    when(() => controller.setTerrain(any())).thenAnswer((_) async {});
    when(() => controller.setProjection(any())).thenAnswer((_) async {});
    when(() => controller.setSky(any())).thenAnswer((_) async {});
  });

  test('applies DEM source, terrain, globe and sky in order', () async {
    final applied = await enhancer.enhance(controller);

    expect(applied, true);
    verifyInOrder([
      () => controller.addSource(
        MapStyleEnhancer.terrainSourceId,
        any<RasterDemSourceProperties>(),
      ),
      () => controller.setTerrain(any<TerrainProperties>()),
      () => controller.setProjection('globe'),
      () => controller.setSky(any<SkyProperties>()),
    ]);
  });

  test('returns false without crashing on native platforms', () async {
    when(() => controller.addSource(any(), any())).thenThrow(
      UnsupportedError('3D terrain is web-only'),
    );

    final applied = await enhancer.enhance(controller);

    expect(applied, false);
  });

  test('toggles projection without crashing on native platforms', () async {
    when(
      () => controller.setProjection(any()),
    ).thenThrow(UnsupportedError('projections are web-only'));

    await enhancer.setGlobeEnabled(controller, false);

    verify(() => controller.setProjection('mercator')).called(1);
  });
}
