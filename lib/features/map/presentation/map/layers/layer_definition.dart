import 'package:equatable/equatable.dart';

/// Layer render kind. Maps 1:1 to the controller's typed add-methods.
enum LayerKind { raster, line, circle }

/// Tile/data origin for one layer.
sealed class LayerSource extends Equatable {
  const LayerSource();
}

/// Raster tile pyramid (e.g. satellite imagery).
class RasterTilesSource extends LayerSource {
  const RasterTilesSource({
    required this.tiles,
    this.tileSize = 256,
    this.attribution,
  });

  final List<String> tiles;
  final double? tileSize;
  final String? attribution;

  @override
  List<Object?> get props => [tiles, tileSize, attribution];
}

/// Vector tile source (supports `pmtiles://` URLs).
class VectorUrlSource extends LayerSource {
  const VectorUrlSource({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}

/// Inline URL / inline GeoJSON document.
class GeoJsonSource extends LayerSource {
  const GeoJsonSource({required this.data});

  final String data;

  @override
  List<Object?> get props => [data];
}

/// One map layer: where its data comes from, how it paints, when it loads.
class LayerDefinition extends Equatable {
  const LayerDefinition({
    required this.id,
    required this.sourceId,
    required this.group,
    required this.kind,
    required this.source,
    this.eager = false,
    this.visible = true,
    this.belowLayerId,
    this.sourceLayer,
    this.minzoom,
    this.maxzoom,
    // Line paint.
    this.lineColor,
    this.lineWidth,
    this.lineOpacity,
    // Circle paint.
    this.circleRadius,
    this.circleColor,
    this.circleStrokeColor,
    this.circleStrokeWidth,
    this.circleOpacity,
    // Raster paint.
    this.rasterOpacity,
  });

  /// Stable layer id (also used for visibility toggles).
  final String id;

  /// Stable source id shared by layers reading the same tiles.
  final String sourceId;

  /// Catalog group, e.g. `base` (loaded at startup) or `overlays` (lazy).
  final String group;

  final LayerKind kind;
  final LayerSource source;

  /// Load with [MapLayerService.ensureEagerLayers] at style setup.
  final bool eager;

  /// Initial visibility (applied via `setLayerVisibility` after adding).
  final bool visible;

  /// Explicit z-order: insert below this layer id when present.
  final String? belowLayerId;

  /// Vector source-layer selector (required for vector line layers).
  final String? sourceLayer;

  final double? minzoom;
  final double? maxzoom;

  final String? lineColor;
  final double? lineWidth;
  final double? lineOpacity;

  final double? circleRadius;
  final String? circleColor;
  final String? circleStrokeColor;
  final double? circleStrokeWidth;
  final double? circleOpacity;

  final double? rasterOpacity;

  /// Copy with overridden paint. Used by opacity updates, which re-add the
  /// layer since the plugin exposes no paint setters.
  LayerDefinition copyWith({
    double? lineOpacity,
    double? circleOpacity,
    double? rasterOpacity,
  }) {
    return LayerDefinition(
      id: id,
      sourceId: sourceId,
      group: group,
      kind: kind,
      source: source,
      eager: eager,
      visible: visible,
      belowLayerId: belowLayerId,
      sourceLayer: sourceLayer,
      minzoom: minzoom,
      maxzoom: maxzoom,
      lineColor: lineColor,
      lineWidth: lineWidth,
      lineOpacity: lineOpacity ?? this.lineOpacity,
      circleRadius: circleRadius,
      circleColor: circleColor,
      circleStrokeColor: circleStrokeColor,
      circleStrokeWidth: circleStrokeWidth,
      circleOpacity: circleOpacity ?? this.circleOpacity,
      rasterOpacity: rasterOpacity ?? this.rasterOpacity,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sourceId,
    group,
    kind,
    source,
    eager,
    visible,
    belowLayerId,
    sourceLayer,
  ];
}

/// Per-group load outcome: failures are isolated, never abort siblings.
class MapLayersResult extends Equatable {
  const MapLayersResult({this.applied = const [], this.failed = const []});

  final List<String> applied;
  final List<String> failed;

  bool get allReady => failed.isEmpty;

  @override
  List<Object?> get props => [applied, failed];
}
