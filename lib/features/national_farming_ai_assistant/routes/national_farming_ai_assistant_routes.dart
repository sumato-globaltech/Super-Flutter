import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/vistaar/presentation/vistaar/screen/vistaar_screen.dart';

import 'vistaar_route_names.dart';

/// GoRoutes owned by the vistaar feature.
List<GoRoute> buildVistaarRoutes() => [
  GoRoute(
    path: VistaarRouteNames.root,
    name: VistaarRouteNames.root,
    builder: (context, state) => const VistaarScreen(),
  ),
];
