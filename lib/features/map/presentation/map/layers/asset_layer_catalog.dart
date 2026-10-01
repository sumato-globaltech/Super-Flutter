import 'dart:convert';

import 'package:flutter/services.dart';

import 'layer_catalog.dart';
import 'layer_definition.dart';

/// [LayerCatalog] backed by two bundled JSON assets: `sources` (tile/data
/// origins, defined once) joined with `layers` (which reference them by
/// `sourceId`). Adding layer #31 is one JSON entry — no Dart change.
///
/// `{tileHost}`-style variables declared in the sources file are substituted
/// everywhere, so environments differ by one value, not thirty URLs. A
/// remote catalog can replace this class later behind the same interface.
class AssetLayerCatalog implements LayerCatalog {
  AssetLayerCatalog({
    this.sourcesPath = 'assets/map/sources.catalog.v1.json',
    this.layersPath = 'assets/map/layers.catalog.v1.json',
  });

  final String sourcesPath;
  final String layersPath;

  List<LayerDefinition>? _cache;

  /// Loads both JSON assets, substitutes variables, and returns the joined
  /// definitions. The result is cached for the process lifetime; catalog
  /// edits require an app restart to take effect.
  @override
  Future<List<LayerDefinition>> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final sourcesRaw = await rootBundle.loadString(sourcesPath);
    final layersRaw = await rootBundle.loadString(layersPath);
    final defs = joinCatalog(
      sourcesDoc: jsonDecode(sourcesRaw),
      layersDoc: jsonDecode(layersRaw),
    );
    _cache = defs;
    return defs;
  }

  /// Joins raw decoded JSON documents into validated definitions. Pure and
  /// directly unit-testable (no asset bundle needed).
  static List<LayerDefinition> joinCatalog({
    required dynamic sourcesDoc,
    required dynamic layersDoc,
  }) {
    if (sourcesDoc is! Map<String, dynamic>) {
      throw const FormatException('Sources catalog root must be an object');
    }
    if (layersDoc is! Map<String, dynamic>) {
      throw const FormatException('Layers catalog root must be an object');
    }
    final variables = _variablesOf(sourcesDoc);
    final sourcesNode = sourcesDoc['sources'];
    if (sourcesNode is! Map<String, dynamic>) {
      throw const FormatException('Sources catalog is missing "sources"');
    }
    final sources = <String, LayerSource>{
      for (final entry in sourcesNode.entries)
        entry.key: _parseSource(
          _substitute(entry.value, variables) as Map<String, dynamic>,
          sourceId: entry.key,
        ),
    };
    final layers = layersDoc['layers'];
    if (layers is! List) {
      throw const FormatException('Layers catalog is missing "layers"');
    }
    final defs = layers
        .map((e) => _parseLayer(_substitute(e, variables), sources))
        .toList(growable: false);
    _assertUniqueIds(defs);
    _assertBelowRefsExist(defs);
    return defs;
  }

  /// Reads the `variables` map out of a catalog document. Returns empty when
  /// absent, so layers files can stay variable-free if they need no templating.
  static Map<String, String> _variablesOf(Map<String, dynamic> doc) {
    final variables = doc['variables'];
    if (variables is! Map) return const {};
    return {
      for (final e in variables.entries)
        '${e.key}': '${e.value}',
    };
  }

  /// Recursively substitutes `{variable}` placeholders in strings.
  static dynamic _substitute(dynamic node, Map<String, String> variables) {
    if (node is String) {
      var out = node;
      variables.forEach((key, value) {
        out = out.replaceAll('{$key}', value);
      });
      return out;
    }
    if (node is Map) {
      return Map<String, dynamic>.fromEntries(
        node.entries.map(
          (e) => MapEntry('${e.key}', _substitute(e.value, variables)),
        ),
      );
    }
    if (node is List) return node.map((e) => _substitute(e, variables)).toList();
    return node;
  }

  /// Parses one layer entry and joins it to its shared [LayerSource] from
  /// the sources catalog. Throws [FormatException] on unknown kinds or on a
  /// `sourceId` with no matching source (except sourceless `background`).
  static LayerDefinition _parseLayer(
    dynamic node,
    Map<String, LayerSource> sources,
  ) {
    if (node is! Map<String, dynamic>) {
      throw const FormatException('Layer entry must be an object');
    }
    final map = node;
    String str(String key, {bool required = true}) {
      final v = map[key];
      if (v is String) return v;
      if (required) throw FormatException('Layer is missing "$key": $map');
      return '';
    }

    final kind = switch (str('kind')) {
      'raster' => LayerKind.raster,
      'line' => LayerKind.line,
      'circle' => LayerKind.circle,
      'symbol' => LayerKind.symbol,
      'fill' => LayerKind.fill,
      'fillExtrusion' => LayerKind.fillExtrusion,
      'hillshade' => LayerKind.hillshade,
      'colorRelief' => LayerKind.colorRelief,
      'background' => LayerKind.background,
      'heatmap' => LayerKind.heatmap,
      final other => throw FormatException('Unknown layer kind "$other"'),
    };
    final paint = map['paint'];
    final paintMap = paint is Map<String, dynamic> ? paint : {};
    double? paintNum(String key) => (paintMap[key] as num?)?.toDouble();

    final sourceId = str('sourceId');
    final source = sources[sourceId];
    if (source == null && kind != LayerKind.background) {
      throw FormatException(
        'Layer "${map['id']}" references unknown source "$sourceId"',
      );
    }

    return LayerDefinition(
      id: str('id'),
      sourceId: sourceId,
      group: map['group'] is String ? map['group'] as String : 'overlays',
      kind: kind,
      source: source,
      eager: map['eager'] == true,
      visible: map['visible'] != false,
      belowLayerId: map['belowLayerId'] as String?,
      sourceLayer: map['sourceLayer'] as String?,
      minzoom: (map['minzoom'] as num?)?.toDouble(),
      maxzoom: (map['maxzoom'] as num?)?.toDouble(),
      lineColor: paintMap['lineColor'] as String?,
      lineWidth: paintNum('lineWidth'),
      lineOpacity: paintNum('lineOpacity'),
      circleRadius: paintNum('circleRadius'),
      circleColor: paintMap['circleColor'] as String?,
      circleStrokeColor: paintMap['circleStrokeColor'] as String?,
      circleStrokeWidth: paintNum('circleStrokeWidth'),
      circleOpacity: paintNum('circleOpacity'),
      rasterOpacity: paintNum('rasterOpacity'),
      textField: paintMap['textField'] as String?,
      textSize: paintNum('textSize'),
      textColor: paintMap['textColor'] as String?,
      iconImage: paintMap['iconImage'] as String?,
      iconSize: paintNum('iconSize'),
      textOpacity: paintNum('textOpacity'),
      iconOpacity: paintNum('iconOpacity'),
      iconAsset: paintMap['iconAsset'] as String?,
      fillColor: paintMap['fillColor'] as String?,
      fillOpacity: paintNum('fillOpacity'),
      fillExtrusionColor: paintMap['fillExtrusionColor'] as String?,
      fillExtrusionHeight: paintNum('fillExtrusionHeight'),
      fillExtrusionBase: paintNum('fillExtrusionBase'),
      fillExtrusionOpacity: paintNum('fillExtrusionOpacity'),
      hillshadeExaggeration: paintNum('hillshadeExaggeration'),
      hillshadeShadowColor: paintMap['hillshadeShadowColor'] as String?,
      hillshadeHighlightColor: paintMap['hillshadeHighlightColor'] as String?,
      hillshadeAccentColor: paintMap['hillshadeAccentColor'] as String?,
      colorReliefColor: paintMap['colorReliefColor'] as String?,
      colorReliefOpacity: paintNum('colorReliefOpacity'),
      backgroundColor: paintMap['backgroundColor'] as String?,
      backgroundOpacity: paintNum('backgroundOpacity'),
      heatmapRadius: paintNum('heatmapRadius'),
      heatmapOpacity: paintNum('heatmapOpacity'),
      heatmapWeight: paintNum('heatmapWeight'),
    );
  }

  /// Parses one sources-catalog entry into its typed [LayerSource].
  /// Wraps structural problems in [FormatException] naming the offending
  /// [sourceId], so a broken catalog entry points at itself in logs.
  static LayerSource _parseSource(Map<String, dynamic> source,
      {required String sourceId}) {
    try {
      return switch (source['type']) {
        'rasterTiles' => RasterTilesSource(
          tiles: (source['tiles'] as List).map((e) => '$e').toList(),
          tileSize: (source['tileSize'] as num?)?.toDouble(),
          attribution: source['attribution'] as String?,
        ),
        'rasterDem' => RasterDemSource(
          tiles: (source['tiles'] as List).map((e) => '$e').toList(),
          encoding: source['encoding'] as String? ?? 'mapbox',
          tileSize: (source['tileSize'] as num?)?.toDouble() ?? 512,
          maxzoom: (source['maxzoom'] as num?)?.toDouble() ?? 15,
          attribution: source['attribution'] as String?,
        ),
        'vectorUrl' => VectorUrlSource(url: source['url'] as String),
        'geojson' => GeoJsonSource(data: source['data']),
        final other => throw FormatException('Unknown source type "$other"'),
      };
    } catch (e) {
      throw FormatException('Invalid source "$sourceId": $e');
    }
  }

  /// Rejects duplicate layer ids, which would otherwise make toggles and
  /// opacity updates address the wrong layer.
  static void _assertUniqueIds(List<LayerDefinition> defs) {
    final ids = defs.map((d) => d.id).toList();
    if (ids.toSet().length != ids.length) {
      throw FormatException('Duplicate layer ids in catalog: $ids');
    }
  }

  /// Rejects `belowLayerId` references to layers that do not exist, since a
  /// dangling z-order anchor would silently mis-stack the map.
  static void _assertBelowRefsExist(List<LayerDefinition> defs) {
    final ids = defs.map((d) => d.id).toSet();
    for (final def in defs) {
      final below = def.belowLayerId;
      if (below != null && !ids.contains(below)) {
        throw FormatException(
          'Layer "${def.id}" references unknown belowLayerId "$below"',
        );
      }
    }
  }
}
