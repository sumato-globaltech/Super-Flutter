import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/production/presentation/production/screen/production_screen.dart';

import 'production_route_names.dart';

/// GoRoutes owned by the production feature.
List<GoRoute> buildProductionRoutes() => [
  GoRoute(
    path: ProductionRouteNames.root,
    name: ProductionRouteNames.root,
    builder: (context, state) => const ProductionScreen(),
  ),
];
