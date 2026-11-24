import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/screen/crop_detector_screen.dart';

import 'crop_detector_route_names.dart';

/// GoRoutes owned by the crop_detector feature.
List<GoRoute> buildCropDetectorRoutes() => [
  GoRoute(
    path: CropDetectorRouteNames.root,
    name: CropDetectorRouteNames.root,
    builder: (context, state) => const CropDetectorScreen(),
  ),
];
