import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/new_post_feature_dep/presentation/deep_post/screen/deep_post_screen.dart';

import 'new_post_feature_dep_route_names.dart';

/// GoRoutes owned by the new_post_feature_dep feature.
List<GoRoute> buildNewPostFeatureDepRoutes() => [
  GoRoute(
    path: NewPostFeatureDepRouteNames.root,
    name: NewPostFeatureDepRouteNames.root,
    builder: (context, state) => const DeepPostScreen(),
  ),
];
