import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/core/logging/app_logger.dart';

import 'layer_catalog.dart';
import 'layer_definition.dart';

/// Owns map layer setup: loads a [LayerCatalog], adds missing sources/layers
/// in catalog order with explicit z-order, and isolates per-layer failures.
///
/// All mutating operations are serialized through an internal gate: native
/// add/remove calls are check-then-act, so concurrent ensures (e.g. a toggle
/// racing style setup) would otherwise interleave between the existence
/// check and the add and fail with "already exists". As defense in depth,
/// already-exists races are also swallowed where the end state is correct.
@injectable
class MapLayerService {
  MapLayerService(this._catalog, this._logger);

  final LayerCatalog _catalog;
  final AppLogger _logger;

  /// Serial gate for every mutating operation. Errors never break the chain.
  Future<void> _gate = Future.value();

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _gate.then((_) => operation());
    _gate = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  /// Matches native "already there" failures (wording varies by platform).
  static bool _isAlreadyExists(Object e) {
    final message = e.toString().toLowerCase();
    return message.contains('already exists') ||
        message.contains('already added') ||
        message.contains('duplicate');
  }

  /// Adds every `eager` layer definition. Returns applied/failed ids.
  Future<MapLayersResult> ensureEagerLayers(MapLibreMapController controller) {
    return _serialize(() async {
      final defs = (await _catalog.load()).where((d) => d.eager).toList();
      return _ensureAll(controller, defs);
    });
  }

  /// Adds one catalog group (e.g. `overlays`). Already-present layers are
  /// skipped, so toggles can safely re-invoke this.
  Future<MapLayersResult> ensureGroup(MapLibreMapController controller, String group) {
    return _serialize(() async {
      final defs = (await _catalog.load()).where((d) => d.group == group).toList();
      return _ensureAll(controller, defs);
    });
  }

  Future<void> setVisible(MapLibreMapController controller, String layerId, bool visible) {
    return _serialize(() => controller.setLayerVisibility(layerId, visible));
  }

  /// Applies a new opacity to an already-added layer. The plugin exposes no
  /// paint setters, so the layer is removed and re-added with overridden
  /// paint (its source is untouched, nothing refetches). [visible] restores
  /// the pre-update visibility afterwards. Hillshade has no opacity channel
  /// — use [updateExaggeration] for it.
  Future<void> updateOpacity(
    MapLibreMapController controller,
    LayerDefinition def,
    double opacity, {
    bool visible = true,
  }) {
    return updateOpacityFor(
      controller,
      def,
      opacity.clamp(0.0, 1.0),
      visible: visible,
    );
  }

  Future<MapLayersResult> _ensureAll(
    MapLibreMapController controller,
    List<LayerDefinition> defs,
  ) async {
    debugPrint("mridx");
    final applied = <String>[];
    final failed = <String>[];
    for (final def in defs) {
      debugPrint(def.id);
      try {
        await _ensureOne(controller, def);
        applied.add(def.id);
      } catch (e) {
        _logger.warning('Skipping map layer ${def.id}: $e', name: 'map');
        failed.add(def.id);
      }
    }
    return MapLayersResult(applied: applied, failed: failed);
  }

  Future<void> _ensureOne(MapLibreMapController controller, LayerDefinition def) async {
    if (def.needsSource) {
      final sources = await controller.getSourceIds();
      if (!sources.contains(def.sourceId)) {
        debugPrint(def.id);
        try {
          await controller.addSource(def.sourceId, _sourceProperties(def.source));
        } catch (e) {
          if (!_isAlreadyExists(e)) rethrow;
          _logger.info('Source ${def.sourceId} already exists', name: 'map');
        }
      }
    }
    await _ensureImages(controller, def);
    final layers = await controller.getLayerIds();
    if (layers.contains(def.id)) return;
    try {
      await _addLayer(controller, def);
    } catch (e) {
      if (!_isAlreadyExists(e)) rethrow;
      _logger.info('Layer ${def.id} already exists', name: 'map');
    }
    if (!def.visible) {
      await controller.setLayerVisibility(def.id, false);
    }
  }

  Future<void> _addLayer(MapLibreMapController controller, LayerDefinition def) async {
    switch (def.kind) {
      case LayerKind.raster:
        await controller.addRasterLayer(
          def.sourceId,
          def.id,
          RasterLayerProperties(rasterOpacity: def.rasterOpacity ?? 1.0),
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.line:
        await controller.addLayer(
          def.sourceId,
          def.id,
          LineLayerProperties(
            lineColor: def.lineColor ?? '#000000',
            lineWidth: def.lineWidth ?? 2.0,
            lineOpacity: def.lineOpacity ?? 1.0,
          ),
          sourceLayer: def.sourceLayer,
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.circle:
        await controller.addCircleLayer(
          def.sourceId,
          def.id,
          CircleLayerProperties(
            circleRadius: def.circleRadius ?? 4.0,
            circleColor: def.circleColor ?? '#ffffff',
            circleStrokeColor: def.circleStrokeColor ?? '#000000',
            circleStrokeWidth: def.circleStrokeWidth ?? 1.0,
            circleOpacity: def.circleOpacity ?? 1.0,
          ),
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.symbol:
        await controller.addSymbolLayer(
          def.sourceId,
          def.id,
          SymbolLayerProperties(
            iconImage: def.iconImage,
            iconSize: def.iconSize ?? 1.0,
            iconOpacity: def.iconOpacity ?? 1.0,
            textField: def.textField,
            textSize: def.textSize ?? 12.0,
            textColor: def.textColor ?? '#000000',
            textOpacity: def.textOpacity ?? 1.0,
          ),
          sourceLayer: def.sourceLayer,
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.fill:
        await controller.addFillLayer(
          def.sourceId,
          def.id,
          FillLayerProperties(
            fillColor: def.fillColor ?? '#000000',
            fillOpacity: def.fillOpacity ?? 0.5,
          ),
          sourceLayer: def.sourceLayer,
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.fillExtrusion:
        await controller.addFillExtrusionLayer(
          def.sourceId,
          def.id,
          FillExtrusionLayerProperties(
            fillExtrusionColor: def.fillExtrusionColor ?? '#000000',
            fillExtrusionHeight: def.fillExtrusionHeight ?? 0.0,
            fillExtrusionBase: def.fillExtrusionBase ?? 0.0,
            fillExtrusionOpacity: def.fillExtrusionOpacity ?? 1.0,
          ),
          sourceLayer: def.sourceLayer,
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.hillshade:
        await controller.addHillshadeLayer(
          def.sourceId,
          def.id,
          HillshadeLayerProperties(
            hillshadeExaggeration: def.hillshadeExaggeration ?? 1.0,
            hillshadeShadowColor: def.hillshadeShadowColor,
            hillshadeHighlightColor: def.hillshadeHighlightColor,
            hillshadeAccentColor: def.hillshadeAccentColor,
          ),
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.colorRelief:
        await controller.addColorReliefLayer(
          def.sourceId,
          def.id,
          ColorReliefLayerProperties(
            colorReliefColor: def.colorReliefColor,
            colorReliefOpacity: def.colorReliefOpacity ?? 1.0,
          ),
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.background:
        await controller.addBackgroundLayer(
          def.id,
          BackgroundLayerProperties(
            backgroundColor: def.backgroundColor ?? '#000000',
            backgroundOpacity: def.backgroundOpacity ?? 1.0,
          ),
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
      case LayerKind.heatmap:
        await controller.addHeatmapLayer(
          def.sourceId,
          def.id,
          HeatmapLayerProperties(
            heatmapRadius: def.heatmapRadius ?? 30.0,
            heatmapWeight: def.heatmapWeight ?? 1.0,
            heatmapOpacity: def.heatmapOpacity ?? 1.0,
          ),
          sourceLayer: def.sourceLayer,
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
    }
  }

  /// Loads bundled icon assets referenced by [def] via `addImage`.
  /// Already-registered names are reported as success (duplicate-safe for
  /// concurrent ensures sharing one image).
  Future<void> _ensureImages(
    MapLibreMapController controller,
    LayerDefinition def,
  ) async {
    final asset = def.iconAsset;
    final name = def.iconImage;
    if (asset == null || name == null) return;
    try {
      final bytes = await rootBundle.load(asset);
      await controller.addImage(name, bytes.buffer.asUint8List());
    } catch (e) {
      if (!_isAlreadyExists(e)) rethrow;
      _logger.info('Image $name already registered', name: 'map');
    }
  }

  SourceProperties _sourceProperties(LayerSource source) {
    return switch (source) {
      RasterTilesSource() => RasterSourceProperties(
        tiles: source.tiles,
        tileSize: source.tileSize,
        attribution: source.attribution,
      ),
      RasterDemSource() => RasterDemSourceProperties(
        tiles: source.tiles,
        encoding: source.encoding,
        tileSize: source.tileSize,
        maxzoom: source.maxzoom,
        attribution: source.attribution,
      ),
      VectorUrlSource() => VectorSourceProperties(url: source.url),
      GeoJsonSource() => GeojsonSourceProperties(data: source.data),
    };
  }

  /// Applies opacity to an already-added layer of any kind (hillshade has no
  /// opacity channel — use [updateExaggeration] for it).
  Future<void> updateOpacityFor(
    MapLibreMapController controller,
    LayerDefinition def,
    double opacity, {
    bool visible = true,
  }) {
    final updated = switch (def.kind) {
      LayerKind.raster => def.copyWith(rasterOpacity: opacity),
      LayerKind.line => def.copyWith(lineOpacity: opacity),
      LayerKind.circle => def.copyWith(circleOpacity: opacity),
      LayerKind.symbol => def.copyWith(
        textOpacity: opacity,
        iconOpacity: opacity,
      ),
      LayerKind.fill => def.copyWith(fillOpacity: opacity),
      LayerKind.fillExtrusion => def.copyWith(fillExtrusionOpacity: opacity),
      LayerKind.colorRelief => def.copyWith(colorReliefOpacity: opacity),
      LayerKind.background => def.copyWith(backgroundOpacity: opacity),
      LayerKind.heatmap => def.copyWith(heatmapOpacity: opacity),
      LayerKind.hillshade => def,
    };
    return _repaint(controller, def, updated, visible: visible);
  }

  /// Applies hillshade exaggeration by re-adding the layer (same remove +
  /// re-add pattern as opacity, since the plugin exposes no paint setters).
  Future<void> updateExaggeration(
    MapLibreMapController controller,
    LayerDefinition def,
    double exaggeration, {
    bool visible = true,
  }) {
    final updated = def.copyWith(hillshadeExaggeration: exaggeration);
    return _repaint(controller, def, updated, visible: visible);
  }

  Future<void> _repaint(
    MapLibreMapController controller,
    LayerDefinition def,
    LayerDefinition updated, {
    required bool visible,
  }) {
    return _serialize(() async {
      try {
        await controller.removeLayer(def.id);
      } catch (e) {
        _logger.info('Layer ${def.id} already removed: $e', name: 'map');
      }
      await _addLayer(controller, updated);
      if (!visible) {
        await controller.setLayerVisibility(def.id, false);
      }
    });
  }
}
