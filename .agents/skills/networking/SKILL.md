---
name: networking
description: Work with the Dio networking layer in this Flutter starter. Use when adding API calls, endpoints, interceptors, or error mapping; enforces per-feature endpoints with auth-critical paths kept in core.
---

# Networking

`DioClient` (main + separate refresh client, strict 2xx) is the only place
that builds `Dio`. Remote data sources are the only place that calls it.

## Endpoint convention (agreed)

- Feature endpoints live **next to the remote source**:
  `lib/data/<feature>/sources/remote/<feature>_endpoints.dart`
  (e.g. `AuthEndpoints.login`, `AuthEndpoints.currentUser`).
- `lib/core/network/api_endpoints.dart` keeps **critical-only** paths consumed
  by `core/`: `login`, `refresh`, `publicPaths`, `isPublic()`. The refresh
  interceptor needs them; `core/` must never import `data/`.
- `login` therefore exists in both files: core's copy is canonical for the
  public-path check, the feature copy owns call sites.
- Unowned speculative paths (products/users/avatar) do not exist — add them
  only with the feature that calls them.

## Remote data source pattern

```dart
@lazySingleton
class <Feature>RemoteDataSource {
  <Feature>RemoteDataSource(this._dioClient);
  final DioClient _dioClient;

  Future<<Model>> fetch() async {
    try {
      final res = await _dioClient.dio.get<dynamic>(<Feature>Endpoints.path);
      // parse + validate tokens/fields; throw NetworkException on bad shape
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);   // -> AppException subtype
    } on NetworkException { rethrow; }
    catch (e) { throw NetworkException('...', cause: e); }
  }
}
```

Error mapping lives in `network_exception_mapper.dart`
(`NoInternet/Timeout/Cancelled/BadRequest/NotFound/Server/Unauthorized`
→ `AppException`). UI renders `AppException.message`; report unexpected ones
via `ErrorReporter`.

## Interceptors (do not reorder casually)

Main client: `AuthInterceptor` (Bearer from `SecureStorage`) →
`RefreshTokenInterceptor` (401 → refresh once via `_refreshClient` →
replay, else `clearTokens` + `onSessionExpired`) → logging (non-prod) →
`ErrorInterceptor`. The refresh client carries only support interceptors to
avoid retry recursion.

## Session expiry

`SessionManagerImpl(storageService).onSessionExpired()` clears the session and
reflects `AuthCubit.unauthenticated()` via **lazy** `GetIt` lookup — never
constructor-inject `AuthCubit` into `core/` (DI cycle:
Cubit → Repository → Remote → DioClient → SessionManager → Cubit).

## Tests

`test/core/network/`: interceptor behavior (non-401 passthrough, retried-401
passthrough, missing-refresh → expired) and session-manager clearing, using
`mocktail` (`MockDio`, `MockSecureStorage`, `MockErrorInterceptorHandler`).
