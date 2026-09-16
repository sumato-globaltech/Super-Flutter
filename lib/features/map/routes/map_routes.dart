import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/map/presentation/map/screen/map_screen.dart';
import 'package:super_flutter/features/map/routes/map_route_names.dart';

List<GoRoute> buildMapRoutes() => [
  GoRoute(
    path: MapRouteNames.mapScreen,
    name: MapRouteNames.mapScreen,
    builder: (context, state) => const MapScreen(),
  ),
];
