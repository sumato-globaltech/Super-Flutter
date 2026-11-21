import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/ui_gallery/presentation/ui_gallery/screen/ui_gallery_screen.dart';

import 'ui_gallery_route_names.dart';

/// GoRoutes owned by the ui_gallery feature.
List<GoRoute> buildUiGalleryRoutes() => [
  GoRoute(
    path: UiGalleryRouteNames.root,
    name: UiGalleryRouteNames.root,
    builder: (context, state) => const UiGalleryScreen(),
  ),
];
