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
  Future<MapLayersResult> ensureEagerLayers(
    MapLibreMapController controller,
  ) {
    return _serialize(() async {
      final defs = (await _catalog.load()).where((d) => d.eager).toList();
      return _ensureAll(controller, defs);
    });
  }

  /// Adds one catalog group (e.g. `overlays`). Already-present layers are
  /// skipped, so toggles can safely re-invoke this.
  Future<MapLayersResult> ensureGroup(
    MapLibreMapController controller,
    String group,
  ) {
    return _serialize(() async {
      final defs = (await _catalog.load())
          .where((d) => d.group == group)
          .toList();
      return _ensureAll(controller, defs);
    });
  }

  Future<void> setVisible(
    MapLibreMapController controller,
    String layerId,
    bool visible,
  ) {
    return _serialize(
      () => controller.setLayerVisibility(layerId, visible),
    );
  }

  /// Applies a new opacity to an already-added layer. The plugin exposes no
  /// paint setters, so the layer is removed and re-added with overridden
  /// paint (its source is untouched, nothing refetches). [visible] restores
  /// the pre-update visibility afterwards.
  Future<void> updateOpacity(
    MapLibreMapController controller,
    LayerDefinition def,
    double opacity, {
    bool visible = true,
  }) {
    return _serialize(() async {
      final clamped = opacity.clamp(0.0, 1.0);
      final updated = switch (def.kind) {
        LayerKind.raster => def.copyWith(rasterOpacity: clamped),
        LayerKind.line => def.copyWith(lineOpacity: clamped),
        LayerKind.circle => def.copyWith(circleOpacity: clamped),
      };
      try {
        await controller.removeLayer(def.id);
      } catch (e) {
        // Lost a race with a concurrent ensure: the layer is already gone,
        // which is exactly the state remove wanted. Re-add below heals it.
        _logger.info('Layer ${def.id} already removed: $e', name: 'map');
      }
      await _addLayer(controller, updated);
      if (!visible) {
        await controller.setLayerVisibility(def.id, false);
      }
    });
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
      try {
        await controller.addSource(def.sourceId, _sourceProperties(def.source));
      } catch (e) {
        if (!_isAlreadyExists(e)) rethrow;
        _logger.info('Source ${def.sourceId} already exists', name: 'map');
      }
    }
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

  Future<void> _addLayer(
    MapLibreMapController controller,
    LayerDefinition def,
  ) async {
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
