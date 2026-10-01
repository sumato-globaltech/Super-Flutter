import 'layer_definition.dart';

/// Source of [LayerDefinition]s. Asset-backed by default
/// ([AssetLayerCatalog]); a remote implementation can slot in later without
/// touching [MapLayerService] or callers.
abstract interface class LayerCatalog {
  /// Loads and validates every [LayerDefinition], joining layers with their
  /// shared sources. Results may be cached by the implementation.
  Future<List<LayerDefinition>> load();
}
