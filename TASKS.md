# Super Flutter — Build Tasks

Backend: `~/Herd/dam/routes/api.php` (Laravel, `/api/v1`, envelope `{success, message, data, errors?, meta?}`)
UI source to port: `ino_irrigation/lib/ui/custom/{bottom_bar,confirm_sheet}.dart`, `TitleDetailsCard`
Feature reference only (no UI copy): `kheti_manu/lib`
Rules: generate through `sf` CLI · official Flutter / go_router patterns · strings via `final l10n = AppLocalizations.of(context);` (English only for now) · Firebase later

**Done when:** `dart analyze` clean · `flutter test` green · `go test ./...` green (if CLI changed) · verified in running app · `graphify update .`

## Open questions
- [ ] Roles: farmer only, or vendor / driver / officer too?
- [ ] Login: email/password, OTP, or both?
- [ ] Bottom tabs: Home · Market · Farms · Schemes · Profile?
- [ ] Local base URL + API key header/value
- [ ] CLI kits embedded in `sf` binary (`go:embed`)?

## Phase 0 — Foundation fixes
- [ ] **T0.1** Align `ApiEndpoints` with `api.php` (`/api/v1/me`, `/api/v1/token/refresh`, …), add API-key interceptor (`--dart-define`), verify login sends `device_name`
- [ ] **T0.2** Update `sf make api` templates for correct endpoints/headers + Go tests

## Phase 1 — CLI commands
- [ ] **T1.1** `sf make screen <feature> <name>` — event/state/bloc/screen in existing feature, route registration, l10n keys in `app_en.arb`
- [ ] **T1.2** `sf make widget <name>` — shared widget in `lib/core/ui/widgets`
- [ ] **T1.3** `sf install <kit>` — `bottom-bar`, `app-bar`, `confirm-sheet`, `title-details-card` (+ l10n keys)
- [ ] **T1.4** `sf install shell` + `sf make tab <feature>` — `StatefulShellRoute.indexedStack` home shell, add/remove tabs
- [ ] **T1.5** Extend `sf make api` — path params, query params, pagination (`meta`/`links`), multipart upload, 422 `errors` → field errors

## Phase 2 — Shared UI
- [ ] **T2.1** Install confirm sheet + title/details card, widget tests
- [ ] **T2.2** Install app bar + bottom bar, widget tests
- [ ] **T2.3** Home shell with tabs + router redirect test

## Phase 3 — Features
- [ ] **T3.1** Auth — login, OTP request/verify, me, logout, logout-all, token refresh
- [ ] **T3.2** Home — banners, alerts, notices, quick actions
- [ ] **T3.3** Markets — list, summary, price history, favourites
- [ ] **T3.4** Crops — list, detail, advisory, calendar, fertilizers, economics, recommendations
- [ ] **T3.5** Farms — CRUD, archive/unarchive, farm crops, transactions + summary, photos
- [ ] **T3.6** IoT — devices, sync, soil-sensor account, readings
- [ ] **T3.7** Schemes — list, detail, apply, applications, document upload, withdraw
- [ ] **T3.8** Help desk — call centre, call-back, tickets
- [ ] **T3.9** Profile — show/update, change password
- [ ] **T3.10** Communication — notices, publications, meetings, facilities + stats
- [ ] **T3.11** Device registration (FCM) — after Firebase setup
