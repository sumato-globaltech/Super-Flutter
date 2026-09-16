---
name: add-feature
description: Scaffold a new Clean Architecture feature in this Flutter starter. Use when adding a feature module spanning features/<name> (routes + presentation), domain/<name> (entities, repository interface, use-cases), and data/<name> (models, data sources, repository impl).
---

# Add Feature

Scaffold order matters: domain first, then data, then presentation, then routes, then DI.

## Required layout

Every feature contains `routes/` plus one folder per screen; there is no
`presentation/` level. Shared state gets its own explicitly-named folder.

```
lib/features/<name>/
  routes/<name>_route_names.dart
  routes/<name>_routes.dart            # build<Name>Routes()
  <screen>/
    screen/<screen>_screen.dart
    bloc/<screen>_bloc.dart, <screen>_event.dart, <screen>_state.dart
    widgets/                           # screen-private components (only when needed)
  <shared-scope>/                      # e.g. session/ — only when needed
    bloc/<shared>_cubit.dart, <shared>_state.dart
  widgets/                             # feature-shared components (only when needed)
lib/domain/<name>/
  entities/ repositories/<name>_repository.dart  use_cases/
lib/data/<name>/
  model/  sources/local|remote/  repositories/<name>_repository_impl.dart
  sources/remote/<name>_endpoints.dart            # feature endpoints (see networking skill)
test/features/<name>/ test/data/<name>/
```

Live examples: `features/auth` (`login/` screen + `session/` shared Cubit),
`features/dashboard` (`dashboard/` screen). One Bloc per screen, always nested
— never a flat shared `bloc/` + `screen/` split.

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
