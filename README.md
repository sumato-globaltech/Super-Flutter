# Flutter Starter (`starter`)

A production-grade Flutter boilerplate with multi-flavor config, Clean Architecture
(feature-first), BLoC state management, GoRouter navigation, GetIt + Injectable DI,
Dio networking, Drift + Secure Storage persistence, Material 3 design system, and
EN/ES localization.

> Status: `app/` + `core/` shell is functional. The `auth` vertical is partially
> implemented (see [Known gaps](#known-gaps)). `dashboard` / `search` / `account`
> route names are reserved but not all routes are wired yet.

## Table of contents

- [Stack](#stack)
- [Quickstart](#quickstart)
- [Flavors & entrypoints](#flavors--entrypoints)
- [Project structure](#project-structure)
- [Module glossary](#module-glossary)
- [Architecture & conventions](#architecture--conventions)
- [Adding a new module](#adding-a-new-module--worked-example-school-dashboard)
- [Codegen & routine commands](#codegen--routine-commands)
- [Assets, fonts, theme, l10n](#assets-fonts-theme-l10n)
- [Tests](#tests)
- [Known gaps](#known-gaps)
- [FAQ](#faq)

## Stack

| Concern | Package |
|---|---|
| SDK | Dart `^3.13.2`, Flutter (Material 3) |
| State | `flutter_bloc ^9.1.1`, `bloc ^9.2.1`, `equatable ^2.1.0` |
| Navigation | `go_router ^18.0.1` |
| DI | `get_it ^9.2.1`, `injectable ^3.0.0`, `injectable_generator` |
| Network | `dio ^5.11.1` |
| Persistence | `drift ^2.34.4`, `drift_flutter ^0.3.1`, `flutter_secure_storage ^11.0.0` |
| Models | `json_annotation`, `json_serializable`, `build_runner`, `drift_dev` |
| l10n | `flutter_localizations` (SDK), `intl ^0.20.2`, `flutter gen-l10n` |
| Test | `flutter_test`, `bloc_test ^10.0.0`, `mocktail ^1.0.5` |
| Lints | `flutter_lints ^6.0.0` |

## Quickstart

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs

# Run a flavor (use the matching entrypoint):
flutter run -t lib/main_development.dart --flavor development
flutter run -t lib/main_staging.dart     --flavor staging
flutter run -t lib/main_production.dart  --flavor production

flutter test
flutter analyze
```

`lib/main.dart` defaults to production. Prefer the explicit `-t lib/main_<flavor>.dart`
entrypoint above during development.

## Flavors & entrypoints

```
lib/main.dart              -> main_production.dart
lib/main_development.dart  -> bootstrap(AppConfig.development())
lib/main_staging.dart      -> bootstrap(AppConfig.staging())
lib/main_production.dart   -> bootstrap(AppConfig.production())
```

- `lib/app/config/flavor.dart` — `enum Flavor { development, staging, production }`
  with `label` (`DEV` / `STAGING` / `PROD`) and `is*` helpers.
- `lib/app/config/environment.dart` — immutable per-flavor settings:
  `appName`, `apiBaseUrl` (currently `https://dummyjson.com` for all flavors),
  `databaseName`, connect/receive/send timeouts, `enableHttpLogging`,
  `enableVerboseLogging`, `showFlavorBanner`, `useFakeAuth` (from
  `--dart-define=FAKE_AUTH=true`).
- `lib/app/config/app_config.dart` — wrapper adding `defaultPageSize` (30),
  `productCacheTtl` (10 min), `searchDebounce` (400 ms).
- `lib/app/app.dart :: bootstrap()` — the composition root:
  `ensureInitialized` → `configureDependencies(config)` →
  `AppErrorHandler().initialize()` → `Bloc.observer` (non-prod) →
  `StorageService.restoreSession()` → `runApp(MyApp())`, all inside
  `runZonedGuarded` reporting to `ErrorReporter`. `MyApp` wires
  `MaterialApp.router` (theme, l10n, flavor `Banner`).

## Project structure

```
lib/
  main.dart / main_development.dart / main_staging.dart / main_production.dart
  app/
    app.dart                    # bootstrap() + MyApp
    config/                     # flavor.dart, environment.dart, app_config.dart
    router/                     # app_router.dart, routes_names.dart, router_refresh.dart
    startup/                    # splash_screen.dart
  core/
    constants/                  # app_constants.dart, asset_constants.dart
    di/                         # injection.dart, app_modules.dart, storage_module.dart,
                                # network_module.dart, injection.config.dart (generated)
    error/                      # app_exception.dart, app_error_handler.dart,
                                # error_reporter.dart, composite/logger reporters,
                                # exceptions/ (cache/parse/validation/unauthorized/unknown)
    extensions/                 # context/string/date extensions
    localization/               # arb/app_en.arb, arb/app_es.arb + generated outputs
    logging/                    # app_logger.dart, logging_bloc_observer.dart
    network/                    # dio_client.dart, api_endpoints.dart, network_constants.dart,
                                # network_exception_mapper.dart, session_manager.dart,
                                # interceptors/ (auth/refresh/error/logging)
    storage/                    # secure_storage.dart, local_storage.dart (+.g.dart),
                                # storage_service.dart, storage_keys.dart
    ui/
      theme/                    # app_theme.dart, app_colors.dart, design_colors.dart,
                                # app_text_styles.dart, app_dimensions.dart, app_spacing.dart
      widgets/                  # app_button/text_field/loader/empty/error/network_image
      layouts/                  # app_scaffold.dart, responsive_layout.dart
  data/auth/
    model/                      # user_model.dart (+.g.dart)
    sources/local+remote/       # auth_local_data_source.dart, auth_remote_data_source.dart
    repositories/               # auth_repository_impl.dart
  domain/auth/
    entities/                   # user.dart, auth_token.dart, auth_session.dart
    repositories/               # auth_repository.dart (interface)
    use_cases/                  # check_auth_status.dart, login.dart, logout.dart
  features/auth/
    routes/                       # auth_route_names.dart, auth_routes.dart (buildAuthRoutes)
    presentation/
      bloc/                       # auth_cubit.dart + auth_state.dart (status-only, router-owned),
                                  # login_bloc.dart, login_event.dart, login_state.dart
      screen/                     # login_screen.dart
  features/dashboard/
    routes/                       # dashboard_route_names.dart, dashboard_routes.dart
    presentation/
      bloc/                       # dashboard_bloc.dart, dashboard_event.dart, dashboard_state.dart
      screen/                     # dashboard_screen.dart
  features/school/                # pattern for new features (see guide below)
assets/{images,icons,animations,fonts/}
test/core/network/
l10n.yaml
analysis_options.yaml
```

## Module glossary

### `app/` — composition root (no business logic)

| File | Means |
|---|---|
| `app.dart` | `bootstrap()` startup sequence + `MyApp` (`MaterialApp.router`, theme, l10n delegates, flavor banner, `BlocProvider(AuthCubit)`). |
| `config/flavor.dart` | Build flavor enum. Use for banner color and prod-gating logs. |
| `config/environment.dart` | Per-flavor URLs, DB name, timeouts, logging flags. Add new env values here. |
| `config/app_config.dart` | App-wide tunables (`defaultPageSize`, cache TTL, debounce). |
| `router/app_router.dart` | Aggregates feature routes (`buildAuthRoutes()`, …) + app-owned `splash`. Owns the single auth `redirect` (`unknown→splash`, `unauth→login`, `auth+splash/login→dashboard`) + `refreshListenable` on `AuthCubit.stream`. |
| `router/routes_names.dart` | App-shell paths (`splash`) + compat re-exports of feature paths. New code should import `features/<f>/routes/*_route_names.dart` directly. |
| `router/router_refresh.dart` | `GoRouterRefreshStream` — bridges `authCubit.stream` to GoRouter refreshes. |
| `startup/splash_screen.dart` | Minimal loading gate while `AuthCubit.initialize()` resolves. |

### `core/constants/`

- `app_constants.dart` — `bearerPrefix`, token lifetime, min lengths, breakpoints (tablet 600 / desktop 1024), log truncation, transition duration.
- `asset_constants.dart` — all asset paths (`logo`, `placeholder`, icons, animations). Never hardcode `assets/...` strings in UI.

### `core/di/` — dependency injection

- `injection.dart` — `getIt` instance + `configureDependencies(AppConfig)` (registers `AppConfig`, calls generated `init()`).
- `app_modules.dart` (`CoreModule`) — `AppLogger`, `appEnvironment(AppConfig)` (exposes per-flavor `Environment`), `ErrorReporter → CompositeErrorReporter([LoggerErrorReporter])`.
- `storage_module.dart` (`StorageModule`) — `SecureStorage`, `LocalDatabase`, `StorageService`.
- `network_module.dart` (`NetworkModule`) — `DioClient` (needs `Environment`, `SecureStorage`, `AppLogger`, `SessionManager`).
- `injection.config.dart` — generated. Re-run `build_runner` after adding `@injectable` / `@module` / `@LazySingleton` classes; never hand-edit.

### `core/error/`

- `app_exception.dart` — base `AppException(message, statusCode?, cause?)`.
- `exceptions/` — `CacheException`, `ParseException`, `ValidationException(fieldErrors)`, `UnauthorizedException(401)`, `UnknownException`.
- `error_reporter.dart` + `composite_error_reporter.dart` + `logger_error_reporter.dart` — fan-out reporting interface (swap in Crashlytics/Sentry by adding a reporter).
- `app_error_handler.dart` — wires `FlutterError.onError` + `PlatformDispatcher.onError` to the reporter. Initialized in `bootstrap()`.

### `core/network/`

- `dio_client.dart` — builds two `Dio` instances: main (auth + refresh + support interceptors) and `_refreshClient` (no auth loop) to avoid retry recursion. Strict 2xx `validateStatus`, JSON defaults, env timeouts/base URL.
- `interceptors/auth_interceptor.dart` — attaches `Bearer <accessToken>` from `SecureStorage`.
- `interceptors/refresh_token_interceptor.dart` — on 401, refreshes via `tokenClient`, retries once, else calls `onSessionExpired`.
- `interceptors/error_interceptor.dart` — pass-through hook for error normalization.
- `interceptors/logging_interceptor.dart` — HTTP logs when `environment.enableHttpLogging`.
- `session_manager.dart` — `SessionManagerImpl(storageService).onSessionExpired()` clears session + reflects `AuthCubit.unauthenticated()` via lazy lookup (avoids DI cycle). `AuthCubit` stays status-only.
- `network_exception_mapper.dart` — Dio/parse errors → `AppException` subtypes.
- `api_endpoints.dart`, `network_constants.dart` — endpoint paths + header names. Add new endpoints here, not inline in data sources.

### `core/storage/`

- `secure_storage.dart` — `FlutterSecureStorage` wrapper (Android `resetOnError` + namespace, iOS `first_unlock_this_device`), in-memory token cache, `restore/saveTokens/clearTokens`.
- `local_storage.dart` (+ generated `.g.dart`) — Drift `LocalDatabase`: `ProductRows` + `KeyValueRows`, `schemaVersion: 1`, `read/write/deleteSetting`, `clearUserData()`.
- `storage_service.dart` — facade over both stores (`restoreSession`, `hasSession`, tokens, `get/setSetting`, `get/setFlag`, `themeMode`, `clearSession`).
- `storage_keys.dart` — all keys (`auth.*`, `settings.*`, `sync.*`, DB name). New persisted values start here.

### `core/ui/` — design system (use, don't reinvent)

- `theme/app_theme.dart` — Material 3 `light()` / `dark()` (buttons, inputs, cards, dialogs, nav bars, etc.).
- `theme/app_colors.dart` — `AppColors` (light), `AppDarkColors`, `seedFor(flavor)` (debug banner only), gradients/shadows, `AppColorsExt` theme extension.
- `theme/design_colors.dart` — legacy bulk palette (mostly unused; prefer `AppColors`).
- `theme/app_text_styles.dart` — `appFontFamily = 'Inter'`, `AppFontSizes`, `font()` factory, `textThemeFor()`.
- `theme/app_dimensions.dart` / `app_spacing.dart` — radii, button/field sizes, `maxContentWidth` (720), `maxFormWidth` (420), `Gap` helpers.
- `widgets/` — `AppButton` (filled/tonal/outlined/text/destructive + loading), `AppTextField` (label/hint/validation/password toggle), `AppLoader`/`AppInlineLoader`/`AppSkeleton`, `AppEmptyView`, `AppNetworkImage` (loading/error placeholders). `AppErrorView` is currently commented out (see gaps).
- `layouts/` — `AppScaffold` (max-width, keyboard dismiss, FAB/nav slots), `AppFormScaffold` (centered 420 form), `ResponsiveLayout` + `ConstrainedContent` (phone/tablet/desktop via `AppConstants` breakpoints).

### `core/localization/`, `core/logging/`, `core/extensions/`

- Localization: source of truth is `lib/core/localization/arb/app_en.arb` (+ `app_es.arb`); outputs generated via `flutter gen-l10n` (`l10n.yaml`, `generate: true`). Wired in `MyApp` delegates. ~30 keys: app title, auth, shop, greetings, stock/plural, error states.
- Logging: `AppLogger(debug/info/warning/error)` over `dart:developer.log`; `LoggingBlocObserver` logs Bloc lifecycle in non-prod.
- Extensions: `context` (theme/colors/textStyles, media, breakpoints, snackBar, hideKeyboard), `string` (blank/capitalized/initials/truncate/parse), `date` (formatted/relative/staleness).

### `data/` / `domain/` / `features/` — Clean Architecture split

- `data/<feature>/` — DTOs (`model/`, `@JsonSerializable`), I/O (`sources/local|remote/`), and `repositories/<feature>_repository_impl.dart` mapping DTOs → entities and exceptions → `AppException`. Depends on `core/network` + `core/storage`.
- `domain/<feature>/` — pure Dart: `entities/`, `repositories/<feature>_repository.dart` (interface), `use_cases/` (one action per file, `call()`). No Flutter/Dio/Drift imports.
- `features/<feature>/` — every feature contains `routes/` (path constants + `build<Feature>Routes()` list, aggregated by app router) and `presentation/` (`bloc/` events + states + Blocs/Cubits, `screen/` widgets; one Bloc per screen plus small shared Cubits like status-only `AuthCubit`). UI dispatches events, Blocs call use-cases only — never import `data/` directly.
- Reference: `auth` (login-only routes; `AuthRepository{hasSession,login,logout}`, `CheckAuthStatus`/`Login`/`Logout` use-cases, status-only `AuthCubit{initialize,authenticated,unauthenticated}` + `AuthStatus{…}`, screen Bloc `LoginBloc` (`UsernameChanged/PasswordChanged/Submitted`)), `dashboard` (`DashboardRouteNames`, `DashboardBloc` (`SignOutRequested`)).

## Architecture & conventions

```
presentation (features/) ──calls──> domain (entities/repo iface/use-cases)
       │                                  ▲
       │ uses widgets/theme/l10n          │ implements
       ▼                                  │
data (models/sources/repo impl) ──────────┘
       │ uses core/network + core/storage
core ── shared by all, imports no feature ──
app ─── composes everything (config/router/startup) ──
```

Rules:

1. UI imports `domain/` + `core/ui` only. No `data/` imports in `features/`.
2. `data/` maps failures to `AppException` via `NetworkExceptionMapper`; UI renders `AppException.message`.
3. New persisted value → `StorageKeys` → `StorageService` or Drift table (bump `schemaVersion` + migration).
4. New API → `ApiEndpoints` + remote data source using `getIt<DioClient>().dio`.
5. New string → ARB + `flutter gen-l10n`, never hardcoded user-facing text.
6. New asset → file + `AssetConstants` + `pubspec.yaml` (already declares `images/`, `icons/`, `animations/`).
7. New injectable → annotation + `build_runner`, verify `injection.config.dart`.
8. New route → `features/<feature>/routes/` (`*_route_names.dart` + `build*Routes()`) + aggregate in `app_router.dart`; redirect stays in app router.

## Adding a new module — worked example: School Dashboard

Goal: add a `school` feature showing classes, students, and attendance at `/school`.

Suppose the API offers `GET /school/dashboard`, `GET /school/students`. Follow the
checklist below; each step names the exact file to create/edit.

### 1. Route first (feature-owned)

Every feature contains `routes/` + `presentation/`; `presentation/` contains
`bloc/` + `screen/` (one Bloc per screen).

`lib/features/school/routes/school_route_names.dart`:

```dart
abstract final class SchoolRouteNames {
  static const dashboard = '/school';
}
```

`lib/features/school/routes/school_routes.dart`:

```dart
List<GoRoute> buildSchoolRoutes() => [
  GoRoute(
    path: SchoolRouteNames.dashboard,
    name: SchoolRouteNames.dashboard,
    builder: (context, state) => const SchoolDashboardScreen(),
  ),
];
```

`lib/app/router/app_router.dart` — aggregate (guard stays here):

```dart
routes: [
  GoRoute(path: RouteNames.splash, ...),
  ...buildAuthRoutes(),
  ...buildDashboardRoutes(),
  ...buildSchoolRoutes(),
],
```

Extend `redirect` if the page requires auth (mirror the dashboard case). Run and
visit `/school` before writing logic — the placeholder screen should render.

### 2. Domain (pure Dart, no Flutter/Dio)

Create:

- `lib/domain/school/entities/school_class.dart` — e.g. `{id, name, studentCount}`.
- `lib/domain/school/entities/student.dart` — e.g. `{id, name, grade, attendanceRate}`.
- `lib/domain/school/entities/attendance_summary.dart` — e.g. `{date, present, absent}`.
- `lib/domain/school/repositories/school_repository.dart`:

```dart
abstract interface class SchoolRepository {
  Future<List<SchoolClass>> getClasses();
  Future<List<Student>> getStudents(String classId);
}
```

- `lib/domain/school/use_cases/get_school_dashboard.dart`:

```dart
class GetSchoolDashboard {
  GetSchoolDashboard(this._repo);
  final SchoolRepository _repo;
  Future<List<SchoolClass>> call() => _repo.getClasses();
}
```

Keep entities `Equatable`/immutable; one action per use-case file.

### 3. Data (DTOs + sources + impl)

- `lib/data/school/model/school_class_model.dart` with `@JsonSerializable()` +
  `part 'school_class_model.g.dart';` → `toEntity()` mapper. Run codegen (below).
- `lib/data/school/sources/remote/school_remote_data_source.dart`:

```dart
@lazySingleton
class SchoolRemoteDataSource {
  SchoolRemoteDataSource(this._dioClient);
  final DioClient _dioClient;

  Future<List<SchoolClassModel>> getClasses() async {
    try {
      final res = await _dioClient.dio.get(ApiEndpoints.schoolDashboard);
      return (res.data as List).map((e) => SchoolClassModel.fromJson(e)).toList();
    } catch (e, s) {
      throw NetworkExceptionMapper.map(e, s); // -> AppException
    }
  }
}
```

Add `schoolDashboard = '/school/dashboard'` to `lib/core/network/api_endpoints.dart`.

- `lib/data/school/sources/local/school_local_data_source.dart` — optional cache
  via `StorageService` settings or a new Drift table (bump `schemaVersion`).
- `lib/data/school/repositories/school_repository_impl.dart`:

```dart
@LazySingleton(as: SchoolRepository)
class SchoolRepositoryImpl implements SchoolRepository {
  SchoolRepositoryImpl(this._remote, this._local);
  // map models -> entities, fall back to cache on NetworkException
}
```

### 4. Presentation (one Bloc per screen)

- `lib/features/school/presentation/bloc/school_dashboard_event.dart`:
  `DashboardStarted`, `DashboardRefreshed`, `RetryRequested`.
- `lib/features/school/presentation/bloc/school_dashboard_state.dart`:
  `SchoolStatus { initial, loading, loaded, error }` + `classes`, `message`, `copyWith`.
- `lib/features/school/presentation/bloc/school_dashboard_bloc.dart`:

```dart
@injectable
class SchoolDashboardBloc extends Bloc<SchoolDashboardEvent, SchoolDashboardState> {
  SchoolDashboardBloc(this._getDashboard) : super(const SchoolDashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onStarted);
  }
  final GetSchoolDashboard _getDashboard;
  Future<void> _onStarted(event, emit) async {
    emit(state.copyWith(status: SchoolStatus.loading));
    try {
      emit(state.copyWith(status: SchoolStatus.loaded, classes: await _getDashboard()));
    } on AppException catch (e) {
      emit(state.copyWith(status: SchoolStatus.error, message: e.message));
    }
  }
}
```

- `lib/features/school/presentation/screen/school_dashboard_screen.dart` —
  `AppScaffold(title: context.l10n.schoolTitle, body: BlocBuilder<SchoolDashboardBloc, ...>(...))`
  with `AppLoader` (loading), `AppEmptyView` (empty), error view + `AppButton(label: retry)` → `add(RetryRequested)`.
- Small rows/cards go in `lib/features/school/presentation/screen/widgets/`. Reuse `AppTextStyles`,
  `AppSpacing`, `AppColors` — no ad-hoc colors, radii, or asset strings.
- Keep tiny shared tasks (e.g. session status) in `presentation/bloc/` Cubits like `AuthCubit`; main screen work uses Blocs.

### 5. DI

Annotate new classes (`@lazySingleton`, `@LazySingleton(as: ...)`, `@injectable`
for use-cases), then:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Open `lib/core/di/injection.config.dart` and confirm `SchoolRepository`,
`SchoolRemoteDataSource`, `SchoolDashboardBloc`, `GetSchoolDashboard` are registered.

### 6. l10n, assets, theme

- Add keys to `lib/core/localization/arb/app_en.arb` (+ `app_es.arb`):
  `schoolTitle`, `schoolStudents`, `schoolAttendance`, `schoolRetry`.
- `flutter gen-l10n`, use `context.l10n.schoolTitle` (via `AppLocalizations.of`).
- Images/icons/animations → `assets/` + `AssetConstants` + reference the constant.

### 7. Tests

- `test/features/school/school_dashboard_bloc_test.dart` (`bloc_test`: started→loading→loaded, loading→error on `AppException`).
- `test/data/school/school_repository_test.dart` (`mocktail` remote/local data sources).
- Widget test: dashboard renders list / empty / error + retry adds `DashboardRefreshed`.
- Keep `flutter test` green alongside existing `test/core/network/` tests.

### 8. Verify

```bash
flutter analyze
flutter test
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter run -t lib/main_development.dart --flavor development
# open /school, toggle offline to check error/empty states
```

## Codegen & routine commands

| Task | Command |
|---|---|
| Deps | `flutter pub get` |
| l10n | `flutter gen-l10n` (auto on run/build; config `l10n.yaml`) |
| Injectable/JSON/Drift | `dart run build_runner build --delete-conflicting-outputs` |
| Watch mode | `dart run build_runner watch --delete-conflicting-outputs` |
| Analyze | `flutter analyze` |
| Test | `flutter test` |

Never hand-edit generated files: `lib/core/di/injection.config.dart`,
`lib/core/localization/app_localizations*.dart`, `*.g.dart`, `local_storage.g.dart`.

## Assets, fonts, theme, l10n

- Assets: `assets/images/`, `assets/icons/`, `assets/animations/` are declared in
  `pubspec.yaml`. Reference via `AssetConstants` (`lib/core/constants/asset_constants.dart`).
- Fonts: `Inter` 400/500/600/700 in `assets/fonts/`; `AppTextStyles.appFontFamily`
  is the single family — add weights here and in `pubspec.yaml` together.
- Theme: `AppTheme.light()/dark()` + `AppColors`/`AppDarkColors` + dimensions/spacing.
  Build new UI from these tokens and `core/ui` widgets/layouts.
- l10n: edit ARB files, run `flutter gen-l10n`, use delegates already wired in `MyApp`.

## Tests

- Existing: `test/core/network/` (401 retry, session expiry), `test/features/auth/` (auth status, login form+submission), `test/features/dashboard/` (sign-out), `test/data/auth/` (repo delegates + token persist).
- Missing (contributions welcome): router redirect, storage, widget/theme/l10n tests. Use `bloc_test` + `mocktail` patterns from the auth/network tests.

## Known gaps (remaining)

1. `AssetConstants` references image/animation files that don't exist (`assets/*` are `.gitkeep` only) — add files or prune constants.
2. `AppTheme.light/dark(flavor)` is flavor-independent by design (only banner uses `seedFor`); `design_colors.dart` is mostly unused legacy;
   product/search tunables + `ProductRows` table have no owning feature.
3. `search`/`account` route names were removed with feature-owned routes; re-add via `features/<f>/routes/` when those features land.

## FAQ

- **Where do I put business logic?** Use-cases in `domain/<feature>/use_cases/`. Screen Blocs orchestrate use-cases (small shared tasks may use Cubits like `AuthCubit`); repositories hide I/O.
- **Where do API calls live?** Remote data sources in `data/<feature>/sources/remote/` using `DioClient` + `ApiEndpoints`. Map errors with `NetworkExceptionMapper`.
- **Where do I cache?** `StorageService` (settings/flags/tokens) or Drift `LocalDatabase` (tables). Register keys in `StorageKeys`.
- **How do I handle errors?** Throw/catch `AppException` subtypes; report unexpected ones via `ErrorReporter`; show `message` in UI with retry.
- **How do flavors differ?** `Environment.development/staging/production()` — app name, API URL, DB name, timeouts, HTTP logging, flavor banner. Pass `--dart-define=FAKE_AUTH=true` for fake auth in non-prod.
- **First Flutter project?** See [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter),
  [first app codelab](https://docs.flutter.dev/get-started/codelab), and the
  [online docs](https://docs.flutter.dev/).
