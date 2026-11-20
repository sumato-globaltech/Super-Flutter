import 'package:flutter/widgets.dart';

import '../../core/constants/assets_names.dart';
import '../../core/utils/image_precache.dart';

abstract final class StartupImages {
  static const List<ImageProvider> _images = [AssetImage(AssetsName.appLogo)];
  static Future<void> precache() => ImagePrecache.all(_images);
}
