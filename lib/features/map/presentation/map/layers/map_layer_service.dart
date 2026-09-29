import 'package:injectable/injectable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/core/logging/app_logger.dart';

import 'layer_catalog.dart';
import 'layer_definition.dart';

/// Owns map layer setup: loads a [LayerCatalog], adds missing sources/layers
/// in catalog order with explicit z-order, and isolates per-layer failures.
///
/// Call [ensureEagerLayers] once at style setup; load the rest on demand with
/// [ensureGroup] (e.g. when a category toggles on).
@injectable
class MapLayerService {
  MapLayerService(this._catalog, this._logger);

  final LayerCatalog _catalog;
  final AppLogger _logger;

  /// Adds every `eager` layer definition. Returns applied/failed ids.
  Future<MapLayersResult> ensureEagerLayers(
    MapLibreMapController controller,
  ) async {
    final defs = (await _catalog.load()).where((d) => d.eager).toList();
    return _ensureAll(controller, defs);
  }

  /// Adds one catalog group (e.g. `overlays`). Already-present layers are
  /// skipped, so toggles can safely re-invoke this.
  Future<MapLayersResult> ensureGroup(
    MapLibreMapController controller,
    String group,
  ) async {
    final defs = (await _catalog.load())
        .where((d) => d.group == group)
        .toList();
    return _ensureAll(controller, defs);
  }

  Future<void> setVisible(
    MapLibreMapController controller,
    String layerId,
    bool visible,
  ) {
    return controller.setLayerVisibility(layerId, visible);
  }

  Future<MapLayersResult> _ensureAll(
    MapLibreMapController controller,
    List<LayerDefinition> defs,
  ) async {
    final applied = <String>[];
    final failed = <String>[];
    for (final def in defs) {
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

  Future<void> _ensureOne(
    MapLibreMapController controller,
    LayerDefinition def,
  ) async {
    final sources = await controller.getSourceIds();
    if (!sources.contains(def.sourceId)) {
      await controller.addSource(def.sourceId, _sourceProperties(def.source));
    }
    final layers = await controller.getLayerIds();
    if (layers.contains(def.id)) return;
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
          ),
          belowLayerId: def.belowLayerId,
          minzoom: def.minzoom,
          maxzoom: def.maxzoom,
        );
    }
    if (!def.visible) {
      await controller.setLayerVisibility(def.id, false);
    }
  }

  SourceProperties _sourceProperties(LayerSource source) {
    return switch (source) {
      RasterTilesSource() => RasterSourceProperties(
        tiles: source.tiles,
        tileSize: source.tileSize,
        attribution: source.attribution,
      ),
      VectorUrlSource() => VectorSourceProperties(url: source.url),
      GeoJsonSource() => GeojsonSourceProperties(data: source.data),
    };
  }
}
