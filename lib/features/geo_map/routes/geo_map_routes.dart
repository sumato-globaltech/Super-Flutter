import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/screen/geo_map_screen.dart';

import 'geo_map_route_names.dart';

/// GoRoutes owned by the geo map feature.
List<GoRoute> buildGeoMapRoutes() => [
  GoRoute(
    path: GeoMapRouteNames.root,
    name: GeoMapRouteNames.root,
    builder: (context, state) => const GeoMapScreen(),
  ),
];
