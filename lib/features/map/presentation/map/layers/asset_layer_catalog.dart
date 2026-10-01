import 'dart:convert';

import 'package:flutter/services.dart';

import 'layer_catalog.dart';
import 'layer_definition.dart';

/// [LayerCatalog] backed by a bundled JSON asset. Adding layer #31 is one
/// JSON entry — no Dart or config-plumbing change.
///
/// `{tileHost}` (and future `{apiKey}`-style variables) are substituted from
/// [variables], so environments differ by one value, not thirty URLs. A
/// remote catalog can replace this class later behind the same interface.

class AssetLayerCatalog implements LayerCatalog {
  AssetLayerCatalog({
    this.assetPath = 'assets/map/layers.catalog.v1.json',
    // this.variables = const {'tileHost': 'http://64.227.134.64'},
  });

  final String assetPath;
  late Map<String, dynamic> variables;

  List<LayerDefinition>? _cache;

  @override
  Future<List<LayerDefinition>> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Layer catalog root must be an object');
    }
    variables = decoded['variables'];

    final layers = decoded['layers'];
    if (layers is! List) {
      throw const FormatException('Layer catalog is missing "layers"');
    }
    final defs = layers.map((e) => _parse(_substitute(e))).toList(growable: false);
    _assertUniqueIds(defs);
    _assertBelowRefsExist(defs);
    _cache = defs;
    return defs;
  }

  /// Recursively substitutes `{variable}` placeholders in strings.
  dynamic _substitute(dynamic node) {
    if (node is String) {
      var out = node;
      variables.forEach((key, value) {
        out = out.replaceAll('{$key}', value);
      });
      return out;
    }
    if (node is Map) {
      return Map<String, dynamic>.fromEntries(
        node.entries.map((e) => MapEntry('${e.key}', _substitute(e.value))),
      );
    }
    if (node is List) return node.map(_substitute).toList();
    return node;
  }

  LayerDefinition _parse(dynamic node) {
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
      final other => throw FormatException('Unknown layer kind "$other"'),
    };
    final source = map['source'];
    if (source is! Map<String, dynamic>) {
      throw FormatException('Layer "${map['id']}" is missing "source"');
    }
    final paint = map['paint'];
    final paintMap = paint is Map<String, dynamic> ? paint : {};
    double? paintNum(String key) => (paintMap[key] as num?)?.toDouble();

    return LayerDefinition(
      id: str('id'),
      sourceId: str('sourceId'),
      group: map['group'] is String ? node['group'] as String : 'overlays',
      kind: kind,
      source: _parseSource(source),
      eager: map['eager'] == true,
      visible: map['visible'] != false,
      belowLayerId: map['belowLayerId'] as String?,
      sourceLayer: map['sourceLayer'] as String?,
      minzoom: (map['minzoom'] as num?)?.toDouble(),
      maxzoom: (map['maxzoom'] as num?)?.toDouble(),
      lineColor: paintMap['lineColor'] as String?,
      lineWidth: paintNum('lineWidth'),
      circleRadius: paintNum('circleRadius'),
      circleColor: paintMap['circleColor'] as String?,
      circleStrokeColor: paintMap['circleStrokeColor'] as String?,
      circleStrokeWidth: paintNum('circleStrokeWidth'),
      rasterOpacity: paintNum('rasterOpacity'),
    );
  }

  LayerSource _parseSource(Map<String, dynamic> source) {
    return switch (source['type']) {
      'rasterTiles' => RasterTilesSource(
        tiles: (source['tiles'] as List).map((e) => '$e').toList(),
        tileSize: (source['tileSize'] as num?)?.toDouble(),
        attribution: source['attribution'] as String?,
      ),
      'vectorUrl' => VectorUrlSource(url: source['url'] as String),
      'geojson' => GeoJsonSource(data: source['data'] as String),
      final other => throw FormatException('Unknown source type "$other"'),
    };
  }

  void _assertUniqueIds(List<LayerDefinition> defs) {
    final ids = defs.map((d) => d.id).toList();
    if (ids.toSet().length != ids.length) {
      throw FormatException('Duplicate layer ids in catalog: $ids');
    }
  }

  void _assertBelowRefsExist(List<LayerDefinition> defs) {
    final ids = defs.map((d) => d.id).toSet();
    for (final def in defs) {
      final below = def.belowLayerId;
      if (below != null && !ids.contains(below)) {
        throw FormatException('Layer "${def.id}" references unknown belowLayerId "$below"');
      }
    }
  }
}
