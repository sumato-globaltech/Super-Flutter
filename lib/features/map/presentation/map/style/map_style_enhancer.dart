import 'package:injectable/injectable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/core/logging/app_logger.dart';

/// Applies globe projection, 3D terrain and sky atmosphere to a styled map.
///
/// Globe, terrain and sky are **web-only** in MapLibre Native: every call is
/// guarded so Android/iOS ([UnsupportedError]) simply keep the default
/// mercator style instead of crashing.
@injectable
class MapStyleEnhancer {
  MapStyleEnhancer(this._logger);

  final AppLogger _logger;

  static const terrainSourceId = 'terrain-dem';

  /// Terrarium-encoded elevation tiles (AWS open dataset).
  static const terrainTiles = [
    'https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{z}/{x}/{y}.png',
  ];

  /// Adds the DEM source, enables exaggerated 3D terrain, switches to the
  /// globe projection and adds sky atmosphere. Returns true when applied.
  Future<bool> enhance(MapLibreMapController controller) async {
    try {
      await controller.addSource(
        terrainSourceId,
        const RasterDemSourceProperties(
          tiles: terrainTiles,
          tileSize: 256,
          maxzoom: 15,
          encoding: 'terrarium',
          attribution: '© AWS Terrain Tiles (Terrarium)',
        ),
      );
      await controller.setTerrain(
        const TerrainProperties(source: terrainSourceId, exaggeration: 1.5),
      );
      await controller.setProjection('globe');
      await controller.setSky(
        const SkyProperties(
          skyColor: '#199EF3',
          horizonColor: '#ffffff',
          fogColor: '#ffffff',
          atmosphereBlend: 0.8,
        ),
      );
      return true;
    } on UnsupportedError catch (e) {
      _logger.info('Globe/terrain/sky not supported on this platform: $e');
      return false;
    }
  }

  /// Toggles between globe and mercator projections. No-op with a log on
  /// platforms without projection support.
  Future<void> setGlobeEnabled(
    MapLibreMapController controller,
    bool enabled,
  ) async {
    try {
      await controller.setProjection(enabled ? 'globe' : 'mercator');
    } on UnsupportedError catch (e) {
      _logger.info('Projection switch not supported on this platform: $e');
    }
  }
}
