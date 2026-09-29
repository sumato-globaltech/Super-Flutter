import 'layer_definition.dart';

/// Source of [LayerDefinition]s. Asset-backed by default
/// ([AssetLayerCatalog]); a remote implementation can slot in later without
/// touching [MapLayerService] or callers.
abstract interface class LayerCatalog {
  Future<List<LayerDefinition>> load();
}
