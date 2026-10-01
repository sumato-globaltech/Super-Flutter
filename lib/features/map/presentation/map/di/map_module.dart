import 'package:injectable/injectable.dart';
import 'package:super_flutter/features/map/presentation/map/layers/asset_layer_catalog.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_catalog.dart';

/// Injectable module wiring the map feature's catalog. The factory calls the
/// constructor directly (instead of constructor injection) because
/// injectable turns every constructor parameter into a GetIt lookup, and
/// plain `String`/`Map` defaults are intentionally not registered.
@module
abstract class MapModule {
  /// Provides the asset-backed [LayerCatalog] as a process-wide singleton,
  /// so the JSON is parsed once and shared by the service and the Cubit.
  @lazySingleton
  LayerCatalog layerCatalog() => AssetLayerCatalog();
}
