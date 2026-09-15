---
name: add-feature
description: Scaffold a new Clean Architecture feature in this Flutter starter. Use when adding a feature module spanning features/<name> (routes + presentation), domain/<name> (entities, repository interface, use-cases), and data/<name> (models, data sources, repository impl).
---

# Add Feature

Scaffold order matters: domain first, then data, then presentation, then routes, then DI.

## Required layout

```
lib/features/<name>/
  routes/<name>_route_names.dart
  routes/<name>_routes.dart            # build<Name>Routes()
  presentation/
    bloc/                              # shared small cubits only (optional)
    screen/  (or <screen>/bloc + <screen>/view for multi-screen features)
lib/domain/<name>/
  entities/ repositories/<name>_repository.dart  use_cases/
lib/data/<name>/
  model/  sources/local|remote/  repositories/<name>_repository_impl.dart
  sources/remote/<name>_endpoints.dart            # feature endpoints (see networking skill)
test/features/<name>/ test/data/<name>/
```

Single-screen features use flat `presentation/bloc` + `presentation/screen`
(like `features/dashboard`). Multi-screen features nest per screen
(`presentation/login/bloc` + `presentation/login/view`) — either is fine, but
one Bloc per screen always.

## Rules

1. `domain/` is pure Dart: no Flutter, Dio, Drift, GetIt imports. One action per
   use-case file with `call()`, `@injectable`.
2. `data/` maps DTOs to entities (`toEntity()`) and failures to `AppException`
   via `NetworkExceptionMapper`. UI never imports `data/`.
3. `features/` presentation talks to use-cases only. Main screen work uses
   `Bloc` + events; tiny shared tasks (e.g. session status) may use `Cubit`.
4. New persisted value starts at `core/storage/storage_keys.dart`. New API path
   goes in `data/<name>/sources/remote/<name>_endpoints.dart` (auth-critical
   `login`/`refresh` stay mirrored in `core/network/api_endpoints.dart`).
5. New user-facing string goes in ARB first, then `flutter gen-l10n`.

## Workflow

1. Domain: entities (`Equatable`, immutable) → repository interface →
   use-cases (e.g. `Get<Thing>`).
2. Data: `@JsonSerializable` models + `toEntity()` → remote data source
   (`getIt<DioClient>().dio`, map errors) → local source if caching →
   `@LazySingleton(as: <Name>Repository)` impl.
3. Presentation: per-screen `bloc/<n>_bloc|event|state.dart` + `screen/`
   widget built from `core/ui` tokens/widgets only.
4. Routes: `*_route_names.dart` + `build*Routes()` (see add-routes skill);
   aggregate in `lib/app/router/app_router.dart`. Guard stays in app router.
5. DI: annotate (`@lazySingleton`, `@injectable`), run codegen, confirm
   `lib/core/di/injection.config.dart` contains the new types.
6. Tests: cubit/bloc (`bloc_test`), repository (`mocktail`), widget smoke.
7. Run the verify skill (codegen → analyze → test → gen-l10n).
