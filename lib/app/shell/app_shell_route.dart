import 'package:go_router/go_router.dart';

import '../access/app_features.dart';
import '../access/feature_registry.dart';
import 'app_shell.dart';
import 'tab_placeholder_screen.dart';
import 'tab_routes.dart';

/// The signed-in shell: one branch per tab path of [registry], each with its
/// feature's routes from [appTabRoutes] or a placeholder.
StatefulShellRoute buildAppShellRoute({
  FeatureRegistry? registry,
  Map<String, List<RouteBase>>? tabRoutes,
}) {
  final features = registry ?? appFeatures;
  final routes = tabRoutes ?? appTabRoutes();
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShell(navigationShell: navigationShell, registry: features),
    branches: [
      for (final path in features.tabPaths)
        StatefulShellBranch(
          routes:
              routes[path] ??
              [
                GoRoute(
                  path: path,
                  builder: (context, state) =>
                      TabPlaceholderScreen(feature: features.featureAt(path)),
                ),
              ],
        ),
    ],
  );
}
