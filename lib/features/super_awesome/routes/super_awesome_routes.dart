import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/super_awesome/presentation/super_awesome/screen/super_awesome_screen.dart';

import 'super_awesome_route_names.dart';

/// GoRoutes owned by the super_awesome feature.
List<GoRoute> buildSuperAwesomeRoutes() => [
  GoRoute(
    path: SuperAwesomeRouteNames.root,
    name: SuperAwesomeRouteNames.root,
    builder: (context, state) => const SuperAwesomeScreen(),
  ),
];
