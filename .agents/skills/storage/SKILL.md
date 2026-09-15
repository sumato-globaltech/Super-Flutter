---
name: storage
description: Work with persistence in this Flutter starter (SecureStorage, Drift LocalDatabase, StorageService). Use when adding cached data, settings, flags, or session/token handling.
---

# Storage

Two stores, one facade:

- `SecureStorage` (`core/storage/secure_storage.dart`) — tokens and secrets
  only (`flutter_secure_storage`, Android `resetOnError` + namespace, iOS
  `first_unlock_this_device`). In-memory token cache; `restore()` throws
  `CacheException` on failure; `hasSession` requires both tokens.
- `LocalDatabase` (`core/storage/local_storage.dart`, Drift) — tables
  (`ProductRows`, `KeyValueRows`) + `read/write/deleteSetting` helpers.
- `StorageService` — facade over both (`restoreSession`, tokens, `get/setSetting`,
  `get/setFlag`, `themeMode`, `clearSession`).
- `storage_keys.dart` — every key starts here (`auth.*`, `settings.*`, `sync.*`).

## Semantics (do not change casually)

- `clearUserData()` deletes `productRows` + `auth.cached_user` +
  `sync.last_synced_at`. App settings (theme, locale, onboarding) intentionally
  survive logout.
- `StorageService.clearSession()` = `clearTokens()` + `clearUserData()`.
- `LocalDatabase` name comes from `Environment.databaseName` (per-flavor:
  `flutter_kit_dev/staging/`), via `StorageModule` — never hardcode `app_db`.

## Adding persistence

1. Settings/flags/tokens → `StorageKeys` constant + `StorageService` accessor;
   read via `getSetting/getFlag`, write via `setSetting/setFlag`.
2. Structured cache → new Drift table in `local_storage.dart`, bump
   `schemaVersion`, implement `onUpgrade` migration (current `onUpgrade` is a
   noop — fill it when bumping), regenerate (`local_storage.g.dart` via
   codegen skill), expose helpers on `LocalDatabase` or the feature's local
   data source.
3. Tokens → `saveTokens/clearTokens` only; never store tokens in Drift or
   plain prefs.

## Auth session flow

`bootstrap()` → `StorageService.restoreSession()` → `AuthCubit.initialize()`
(`CheckAuthStatus` → `hasSession`). Login persists via
`AuthLocalDataSource.saveTokens`; `SessionManager.onSessionExpired` clears.

## Tests

Drift: `LocalDatabase.forTesting(executor)` with in-memory sqlite. Secure
storage: `SecureStorage(storage: mockFlutterSecureStorage)` constructor
injection. Repo tests mock the local data source, not the database.
