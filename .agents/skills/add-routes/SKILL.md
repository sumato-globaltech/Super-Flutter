---
name: add-routes
description: Add feature-owned GoRouter routes in this Super Flutter. Use when exposing a new screen path; each feature owns its route names and GoRoute list, the app router only aggregates them and owns the auth guard.
---

# Add Routes

Features own paths. The app router aggregates. The guard stays central.

## Files

```
lib/features/<feature>/routes/<feature>_route_names.dart   # e.g. AuthRouteNames.login = '/login'
lib/features/<feature>/routes/<feature>_routes.dart        # List<GoRoute> build<Feature>Routes()
lib/app/router/app_router.dart      # aggregate + redirect (do not define feature paths here)
lib/app/router/routes_names.dart    # app-shell paths (splash) + compat re-exports only
lib/app/router/router_refresh.dart  # unchanged (bridges AuthCubit.stream to GoRouter)
```

## Workflow

1. Add the path constant in the feature's `*_route_names.dart`. Keep existing
   path values stable (deep links); new code imports the feature names
   directly, never string literals.
2. Add the `GoRoute` in the feature's `build*Routes()`:
   ```dart
   List<GoRoute> build<Feature>Routes() => [
     GoRoute(
       path: <Feature>RouteNames.detail,
       name: <Feature>RouteNames.detail,
       builder: (context, state) => const <Feature>Screen(),
     ),
   ];
   ```
3. Aggregate in `app_router.dart` routes list:
   ```dart
   routes: [
     GoRoute(path: RouteNames.splash, ...),
     ...buildAuthRoutes(),
     ...buildDashboardRoutes(),
     ...build<Feature>Routes(),
   ],
   ```
4. Extend `redirect` only for auth gating (mirror the existing
   unknown→splash / unauth→login / auth+splash|login→dashboard cases).
   Per-feature redirect logic is not allowed — one guard in the app router.
5. `splash` stays app-owned (`app/startup/`, `RouteNames.splash`). Delete dead
   placeholder paths instead of leaving them.

## Verify

- `flutter analyze --no-pub` (no unused imports/keys).
- Manual: visit the new path unauthenticated (expect redirect to login where
  guarded) and authenticated (renders).
- Reference: `features/auth/routes/`, `features/dashboard/routes/`,
  `lib/app/router/app_router.dart`.
