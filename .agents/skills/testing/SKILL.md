---
name: testing
description: Write tests in this Super Flutter with bloc_test and mocktail. Use when adding or updating unit, bloc, repository, or widget tests; follows the existing per-layer test layout.
---

# Testing

Stack: `flutter_test` + `bloc_test` + `mocktail`. All green is required
before handoff (`flutter test`).

## Layout (mirror the source tree)

```
test/core/network/refresh_token_interceptor_test.dart
test/core/network/session_manager_test.dart
test/features/auth/auth_cubit_test.dart
test/features/auth/login_bloc_test.dart
test/features/dashboard/dashboard_bloc_test.dart
test/data/auth/auth_repository_test.dart
test/features/<new>/<name>_bloc_test.dart
test/data/<new>/<name>_repository_test.dart
```

New feature → `test/features/<f>/` (bloc/cubit) + `test/data/<f>/` (repository).
Router/storage/widget/theme/l10n tests are the known gap — add them where the
task touches those layers.

## Patterns

**Bloc** (`bloc_test`): seed state where needed; assert event → state sequence;
`verify`/`verifyNever` on use-cases and `AuthCubit` status reflection:
```dart
blocTest<LoginBloc, LoginState>(
  'emits submitting then success ...',
  build: () { when(() => login(...)).thenAnswer((_) async => user); return LoginBloc(login, authCubit); },
  seed: () => const LoginState(username: 'u', password: 'p'),
  act: (b) => b.add(const LoginSubmitted()),
  expect: () => [submittingState, successState],
  verify: (_) { verify(() => login(...)).called(1); verify(() => authCubit.authenticated()).called(1); },
);
```

**Status-only AuthCubit**: plain `blocTest` on `initialize()` (true→
authenticated, false→unauthenticated) plus direct setter tests.

**Repository** (`mocktail`): mock remote + local data sources; assert token
persistence on login (`saveTokens` with exact tokens), delegation on
`hasSession`/`logout`.

**SessionManager**: registers a `MockAuthCubit` in `GetIt` in `setUp`
(unregisters in `tearDown`) because the impl looks `AuthCubit` up lazily:
```dart
GetIt.instance.registerSingleton<AuthCubit>(authCubit);
sessionManager = SessionManagerImpl(storageService: storage);
```

**Interceptors**: `MockDio` + `MockSecureStorage` + `MockErrorInterceptorHandler`;
cover non-401 passthrough, already-retried 401, missing-refresh → expired.

## Rules

- Mocks extend `Mock implements <Type>`; stub every called method
  (`when(...)`) or mocktail throws.
- `blocTest` needs `seed` when the behavior depends on pre-existing state
  (e.g. filled login form).
- Do not test generated code (`.g.dart`, `injection.config.dart`,
  `app_localizations*.dart`).
