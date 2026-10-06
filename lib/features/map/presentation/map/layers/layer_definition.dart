import 'package:equatable/equatable.dart';

/// Layer render kind. Maps 1:1 to the controller's typed add-methods.
enum LayerKind {
  raster,
  line,
  circle,
  symbol,
  fill,
  fillExtrusion,
  hillshade,
  colorRelief,
  background,
  heatmap,
}

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

/// Elevation tiles for hillshade / color-relief rendering.
class RasterDemSource extends LayerSource {
  const RasterDemSource({
    required this.tiles,
    this.encoding = 'mapbox',
    this.tileSize = 512,
    this.maxzoom = 15,
    this.attribution,
  });

  final List<String> tiles;
  final String? encoding;
  final double? tileSize;
  final double? maxzoom;
  final String? attribution;

  @override
  List<Object?> get props => [tiles, encoding, tileSize, maxzoom, attribution];
}

/// URL or inline GeoJSON document. Inline content must be a JSON-serializable
/// map (the plugin accepts `Object?` here).
class GeoJsonSource extends LayerSource {
  const GeoJsonSource({required this.data});

  final Object data;

  @override
  List<Object?> get props => [data];
}

/// One map layer: where its data comes from, how it paints, when it loads.
class LayerDefinition extends Equatable {
  const LayerDefinition({
    required this.id,
    required this.sourceId,
    required this.group,
    required this.feature,
    required this.kind,
    this.source,
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
    // Symbol paint.
    this.textField,
    this.textSize,
    this.textColor,
    this.iconImage,
    this.iconSize,
    this.textOpacity,
    this.iconOpacity,
    // Bundled asset loaded via `addImage` before the layer is added.
    this.iconAsset,
    // Fill paint.
    this.fillColor,
    this.fillOpacity,
    // Fill-extrusion paint.
    this.fillExtrusionColor,
    this.fillExtrusionHeight,
    this.fillExtrusionBase,
    this.fillExtrusionOpacity,
    // Hillshade controls.
    this.hillshadeExaggeration,
    this.hillshadeShadowColor,
    this.hillshadeHighlightColor,
    this.hillshadeAccentColor,
    // Color-relief paint.
    this.colorReliefColor,
    this.colorReliefOpacity,
    // Background paint.
    this.backgroundColor,
    this.backgroundOpacity,
    // Heatmap paint.
    this.heatmapRadius,
    this.heatmapOpacity,
    this.heatmapWeight,
  });

  /// Stable layer id (also used for visibility toggles).
  final String id;

  /// Stable source id shared by layers reading the same tiles. Unused for
  /// sourceless kinds ([LayerKind.background]).
  final String sourceId;

  /// Catalog group, e.g. `base` (loaded at startup) or `overlays` (lazy).
  final String group;

  /// Owning feature section from the catalog (`map`, `school`, …). Stamped by
  /// the parser — never hand-written — so loading and panels can scope to one
  /// feature without leaking another's layers.
  final String feature;

  final LayerKind kind;

  /// Resolved data origin, joined from the sources catalog by [sourceId].
  /// Null for sourceless kinds ([LayerKind.background]).
  final LayerSource? source;

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

  final String? textField;
  final double? textSize;
  final String? textColor;
  final String? iconImage;
  final double? iconSize;
  final double? textOpacity;
  final double? iconOpacity;
  final String? iconAsset;

  final String? fillColor;
  final double? fillOpacity;

  final String? fillExtrusionColor;
  final double? fillExtrusionHeight;
  final double? fillExtrusionBase;
  final double? fillExtrusionOpacity;

  final double? hillshadeExaggeration;
  final String? hillshadeShadowColor;
  final String? hillshadeHighlightColor;
  final String? hillshadeAccentColor;

  final String? colorReliefColor;
  final double? colorReliefOpacity;

  final String? backgroundColor;
  final double? backgroundOpacity;

  final double? heatmapRadius;
  final double? heatmapOpacity;
  final double? heatmapWeight;

  /// Whether the panel shows an opacity slider for this kind.
  bool get supportsOpacity => switch (kind) {
    LayerKind.raster ||
    LayerKind.line ||
    LayerKind.circle ||
    LayerKind.symbol ||
    LayerKind.fill ||
    LayerKind.fillExtrusion ||
    LayerKind.colorRelief ||
    LayerKind.background ||
    LayerKind.heatmap => true,
    LayerKind.hillshade => false,
  };

  /// Whether the panel shows an exaggeration slider (hillshade only).
  bool get supportsExaggeration => kind == LayerKind.hillshade;

  /// Sourceless kinds skip the source step entirely.
  bool get needsSource => source != null;

  /// Copy with overridden paint. Used by opacity updates, which re-add the
  /// layer since the plugin exposes no paint setters.
  LayerDefinition copyWith({
    double? lineOpacity,
    double? circleOpacity,
    double? rasterOpacity,
    double? textOpacity,
    double? iconOpacity,
    double? fillOpacity,
    double? fillExtrusionOpacity,
    double? hillshadeExaggeration,
    double? colorReliefOpacity,
    double? backgroundOpacity,
    double? heatmapOpacity,
  }) {
    return LayerDefinition(
      id: id,
      sourceId: sourceId,
      group: group,
      feature: feature,
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
      textField: textField,
      textSize: textSize,
      textColor: textColor,
      iconImage: iconImage,
      iconSize: iconSize,
      iconAsset: iconAsset,
      textOpacity: textOpacity ?? this.textOpacity,
      iconOpacity: iconOpacity ?? this.iconOpacity,
      fillColor: fillColor,
      fillOpacity: fillOpacity ?? this.fillOpacity,
      fillExtrusionColor: fillExtrusionColor,
      fillExtrusionHeight: fillExtrusionHeight,
      fillExtrusionBase: fillExtrusionBase,
      fillExtrusionOpacity: fillExtrusionOpacity ?? this.fillExtrusionOpacity,
      hillshadeExaggeration:
          hillshadeExaggeration ?? this.hillshadeExaggeration,
      hillshadeShadowColor: hillshadeShadowColor,
      hillshadeHighlightColor: hillshadeHighlightColor,
      hillshadeAccentColor: hillshadeAccentColor,
      colorReliefColor: colorReliefColor,
      colorReliefOpacity: colorReliefOpacity ?? this.colorReliefOpacity,
      backgroundColor: backgroundColor,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      heatmapRadius: heatmapRadius,
      heatmapOpacity: heatmapOpacity ?? this.heatmapOpacity,
      heatmapWeight: heatmapWeight,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sourceId,
    group,
    feature,
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
