import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/publications/presentation/publications/screen/publications_screen.dart';

import 'publications_route_names.dart';

/// GoRoutes owned by the publications feature.
List<GoRoute> buildPublicationsRoutes() => [
  GoRoute(
    path: PublicationsRouteNames.root,
    name: PublicationsRouteNames.root,
    builder: (context, state) => const PublicationsScreen(),
  ),
];
