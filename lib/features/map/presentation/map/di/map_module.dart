import 'package:injectable/injectable.dart';
import 'package:super_flutter/features/map/presentation/map/layers/asset_layer_catalog.dart';
import 'package:super_flutter/features/map/presentation/map/layers/layer_catalog.dart';

@module
abstract class MapModule {
  @lazySingleton
  LayerCatalog layerCatalog() => AssetLayerCatalog();
}
