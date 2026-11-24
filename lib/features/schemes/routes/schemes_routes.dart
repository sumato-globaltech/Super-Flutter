import 'package:go_router/go_router.dart';
import 'package:super_flutter/features/schemes/presentation/my_applications/screen/my_applications_screen.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/screen/scheme_detail_screen.dart';
import 'package:super_flutter/features/schemes/presentation/schemes/screen/schemes_screen.dart';

import 'schemes_route_names.dart';

/// GoRoutes owned by the schemes feature.
List<GoRoute> buildSchemesRoutes() => [
  GoRoute(
    path: SchemesRouteNames.root,
    name: SchemesRouteNames.root,
    builder: (context, state) => const SchemesScreen(),
  ),
  GoRoute(
    path: SchemesRouteNames.schemeDetail,
    name: SchemesRouteNames.schemeDetail,
    builder: (context, state) =>
        SchemeDetailScreen(scheme: state.pathParameters['scheme']!),
  ),
  GoRoute(
    path: SchemesRouteNames.myApplications,
    name: SchemesRouteNames.myApplications,
    builder: (context, state) => const MyApplicationsScreen(),
  ),
];
