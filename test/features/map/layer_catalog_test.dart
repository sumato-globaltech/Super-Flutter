import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/features/map/presentation/map/layers/asset_layer_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled catalog parses, substitutes variables, stays valid', () async {
    final defs = await AssetLayerCatalog().load();

    expect(defs.map((d) => d.id), containsAll([
      'satellite_layer',
      'nh_layer',
      'villages_layer',
    ]));
    // No unsubstituted placeholders survive in data URLs.
    for (final def in defs) {
      final source = def.source.toString();
      expect(source.contains('{tileHost}'), false, reason: def.id);
    }
    // One eager base group; overlays lazy.
    expect(defs.where((d) => d.eager).map((d) => d.id), ['satellite_layer']);
    expect(
      defs.where((d) => !d.eager).map((d) => d.group).toSet(),
      {'overlays'},
    );
    // Villages load hidden; the toggle reveals them without refetch.
    final villages = defs.firstWhere((d) => d.id == 'villages_layer');
    expect(villages.visible, false);
  });

  test('new layer kinds parse with paint and flags', () async {
    final defs = await AssetLayerCatalog().load();
    final byId = {for (final d in defs) d.id: d};

    final labels = byId['village_labels']!;
    expect(labels.textField, '{Vill_Name}');
    expect(labels.supportsOpacity, true);
    expect(labels.supportsExaggeration, false);

    final markers = byId['poi_markers']!;
    expect(markers.iconImage, 'village-marker');
    expect(markers.iconAsset, 'assets/map/icons/marker.png');

    final fill = byId['district_fill']!;
    expect(fill.fillColor, '#22c55e');

    final hillshade = byId['terrain_hillshade']!;
    expect(hillshade.supportsOpacity, false);
    expect(hillshade.supportsExaggeration, true);
    expect(hillshade.hillshadeExaggeration, 1.5);

    final heatmap = byId['villages_heatmap']!;
    expect(heatmap.heatmapRadius, 30.0);
  });

  test('sources are defined once and shared by reference', () async {
    final defs = await AssetLayerCatalog().load();
    final villagesUsers = defs
        .where((d) => d.sourceId == 'villages_source')
        .toList();
    expect(villagesUsers.length, greaterThan(1));
    for (final def in villagesUsers) {
      expect(def.source, isNotNull);
    }
  });

  group('joinCatalog', () {
    Map<String, dynamic> doc({
      Map<String, dynamic> sharedSources = const {},
      Map<String, dynamic>? featureSections,
    }) => {
      'variables': {'tileHost': 'https://tiles.example'},
      'shared': {'sources': sharedSources},
      'features': featureSections ?? {},
    };

    Map<String, dynamic> geojsonSource() => {
      'type': 'geojson',
      'data': '{tileHost}/data.geojson',
    };

    Map<String, dynamic> layer(String id, String sourceId) => {
      'id': id,
      'sourceId': sourceId,
      'group': 'overlays',
      'kind': 'circle',
      'paint': {'circleRadius': 4.0},
    };

    Map<String, dynamic> featureSection({
      Map<String, dynamic> sources = const {},
      required List<Map<String, dynamic>> layers,
    }) => {
      'sources': sources,
      'layers': layers,
    };

    test('joins feature layers with shared sources', () {
      final defs = AssetLayerCatalog.joinCatalog(
        catalogDoc: doc(
          sharedSources: {'shared': geojsonSource()},
          featureSections: {
            'map': featureSection(layers: [
              layer('a', 'shared'),
              layer('b', 'shared'),
            ]),
          },
        ),
      );

      expect(defs.map((d) => d.id), ['a', 'b']);
      expect(defs[0].source, defs[1].source);
      expect(
        (defs[0].source as dynamic).toString(),
        contains('https://tiles.example/data.geojson'),
      );
    });

    test('two features share one villages-like source object', () {
      final defs = AssetLayerCatalog.joinCatalog(
        catalogDoc: doc(
          sharedSources: {'villages': geojsonSource()},
          featureSections: {
            'map': featureSection(layers: [layer('circles', 'villages')]),
            'school': featureSection(layers: [layer('labels', 'villages')]),
          },
        ),
      );

      expect(defs.map((d) => d.id), ['circles', 'labels']);
      expect(defs[0].source, same(defs[1].source));
    });

    test('rejects cross-feature source references', () {
      expect(
        () => AssetLayerCatalog.joinCatalog(
          catalogDoc: doc(
            featureSections: {
              'map': featureSection(
                sources: {'nh': geojsonSource()},
                layers: [layer('line', 'nh')],
              ),
              'school': featureSection(
                layers: [layer('sneaky', 'nh')],
              ),
            },
          ),
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('school'),
          ),
        ),
      );
    });

    test('rejects sources shadowing shared ids', () {
      expect(
        () => AssetLayerCatalog.joinCatalog(
          catalogDoc: doc(
            sharedSources: {'shared': geojsonSource()},
            featureSections: {
              'map': featureSection(
                sources: {'shared': geojsonSource()},
                layers: [layer('a', 'shared')],
              ),
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects layers referencing unknown sources', () {
      expect(
        () => AssetLayerCatalog.joinCatalog(
          catalogDoc: doc(
            featureSections: {
              'map': featureSection(layers: [layer('a', 'missing')]),
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects duplicate layer ids', () {
      expect(
        () => AssetLayerCatalog.joinCatalog(
          catalogDoc: doc(
            sharedSources: {'shared': geojsonSource()},
            featureSections: {
              'map': featureSection(layers: [layer('a', 'shared')]),
              'school': featureSection(layers: [layer('a', 'shared')]),
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
