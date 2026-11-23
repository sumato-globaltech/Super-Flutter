import 'package:go_router/go_router.dart';

import '../access/feature_registry.dart';
import 'tab_placeholder_screen.dart';

/// [routes] with a placeholder for every feature off the tabs that has no
/// route of its own yet, so opening it shows "coming soon" rather than an
/// error. A feature's real routes replace its placeholder once registered.
List<RouteBase> withPlaceholderRoutes(
  FeatureRegistry registry,
  List<RouteBase> routes,
) {
  final known = <String>{};
  void collect(List<RouteBase> routes, String parent) {
    for (final route in routes) {
      switch (route) {
        case GoRoute(:final path):
          final full = path.startsWith('/')
              ? path
              : '${parent == '/' ? '' : parent}/$path';
          known.add(full);
          collect(route.routes, full);
        case StatefulShellRoute(:final branches):
          for (final branch in branches) {
            collect(branch.routes, parent);
          }
        case ShellRouteBase():
          collect(route.routes, parent);
      }
    }
  }

  collect(routes, '/');
  final placeholders = <String>{};
  return [
    ...routes,
    for (final feature in registry.features)
      if (feature.tab == null &&
          !known.contains(feature.path) &&
          placeholders.add(feature.path))
        GoRoute(
          path: feature.path,
          builder: (context, state) => TabPlaceholderScreen(feature: feature),
        ),
  ];
}
