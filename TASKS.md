# Super Flutter — Build Tasks

Backend: `~/Herd/dam/routes/api.php` (Laravel, `/api/v1`, envelope `{success, message, data, errors?, meta?}`)
UI source to port: `ino_irrigation/lib/ui/custom/{bottom_bar,confirm_sheet}.dart`, `TitleDetailsCard`
Feature reference only (no UI copy): `kheti_manu/lib`
Rules: generate through `sf` CLI · official Flutter / go_router patterns · strings via `final l10n = AppLocalizations.of(context);` (English only for now) · Firebase later

**Done when:** `dart analyze` clean · `flutter test` green · `go test ./...` green (if CLI changed) · verified in running app · `graphify update .`

## Access model (from `dam`)
Nothing is hardcoded per role. Every screen and tab is shown only if the signed-in user may use it.

- **Roles** (`App\Enums\UserRole`): `super-admin`, `admin`, `state_officer`, `district_officer`, `call_center_agent`, `farmer`, `vendor`, `driver`
- **Permissions** (`config/access.php`): `<module>.<feature>`, e.g. `markets.view`, `schemes.review`, `shipments.drive`, `helpdesk.manage`
  - Effective = role permissions (editable in admin) + user `grant` − user `deny`; `super-admin` has all
- **Profile gates:** `farmer/*` needs an active farmer profile; `vendor|driver/shipments` need role + active party profile
- **Public (API key only):** crops, markets, schemes, notices, alerts, banners, publications, meetings, facilities, master data
- **App rule:** each feature registers `AppFeature { id, tab?, rule }`, where the rule is a role, a permission, `any`/`all`, or public
  - Tabs are built from the allowed features, in order; Material `NavigationBar` takes 3–5, extras go to a "More" tab
  - The router redirects away from features the user isn't allowed
  - Access is recomputed after login, `/me` refresh and app resume

| Feature | Rule | Tab |
|---|---|---|
| Home | any signed-in user | ✓ |
| Market | public (favourites: signed in) | ✓ |
| Crops / advisory | public | More |
| Farms, IoT, Farmer profile, Help desk tickets, Scheme apply | role `farmer` + profile | ✓ (Farms) |
| Schemes | public; officer list needs `schemes.view` | ✓ |
| Shipments (farmer) | `shipments.request` | ✓ |
| Shipments (vendor) | `shipments.handle` | ✓ |
| Shipments (driver) | `shipments.drive` | ✓ |
| Production insights | `production.view` or `production.manage` | ✓ |
| Help desk queue | `helpdesk.manage` | ✓ |
| Manage notices / alerts | `notices.manage` / `alerts.manage` | More |
| Notices, publications, meetings, facilities | public | More |
| Profile | any signed-in user | — account button in the top bar (approved at T1.5) |

## Open questions
- [x] Roles: all roles, decided at runtime by permissions (see Access model)
- [x] Login: email/password **and** phone OTP (`otp/request` → `otp/verify`)
- [x] Bottom tabs: dynamic per user (see Access model)
- [x] Local base URL + API key header/value: `http://dam.test`, header `X-Api-Key`, value in `dart_defines/dev.json` (gitignored)
- [x] CLI kits: embedded with `go:embed`, built only after you approve the UI (T1.5)
- [x] Backend changes allowed at **API level only** (resources, API controllers, API tests). No web/admin/DB schema changes

## UI conventions (approved in the UI gallery)
Every hand-written screen and every screen `sf` generates follows these. The UI gallery (`lib/features/ui_gallery`) is the reference.

- **Strings:** `final l10n = AppLocalizations.of(context);`, keys in `app_en.arb`, English only for now. Sample/mock data is the only exception.
- **Page body:** `SingleChildScrollView` → `SafeArea` → `Padding(AppSpacing.pagePadding.copyWith(bottom: 0))` → `Column(crossAxisAlignment: .stretch)`. No fixed bottom padding: `SafeArea` handles the notch, home indicator, Android system bars and landscape cut-outs. Sliver pages use `SliverSafeArea`; forms add `maintainBottomViewPadding: true`.
- **Top bar:** `AppTopBar` (or `AppSliverTopBar` on scrolling home screens), title from l10n.
- **Detail data:** `DesignCard(title:, paddingChild: .fromLTRB(14, 14, 14, 16))` holding `TitleDetailsCard`s, as in `ino_irrigation/scheme_details.dart`:
  - first row `isFirstItem: true`; every row gets `iconData` + a `DesignColor.accent*` colour
  - two short values side by side: `Row` of two `Flexible`, the right one `isCrossAxisAlignmentStart: false`
  - loading → `isTextLoading`; long text → `isReadMore`; IDs → `isCopyable`; links (phone, map) → `onTap` with `Utils.launchUrl2` / `Utils.navigateToMapLocation`; photos → `imagePreviewUrls`
- **List / navigation rows:** one `DesignCard(onTap:)` per item wrapping a `TitleDetailsCard(isFirstItem: true, showNavigateIcon: true)`, cards separated by `8.height`.
- **Confirm / choose:** `ConfirmSheet.confirm` / `ConfirmSheet.choose`; never a raw `AlertDialog`.
- **States:** loading = shimmer rows (`isTextLoading`), error = `AppErrorView.fromException` with retry, empty = `AppEmptyView`, pull-to-refresh on lists.
- **Colour:** only theme tokens (`theme.appColors`, `colorScheme`, `DesignColor`). Avoid `colorScheme.secondary` for foreground: it is white in light mode.

## Phase 0 — Foundation fixes
- [x] **T0.1** Align `ApiEndpoints` with `api.php` (`/api/v1/me`, `/api/v1/token/refresh`, …), add API-key interceptor (`--dart-define`), verify login sends `device_name`
  - Sanctum refresh: proactive refresh inside 1 day of `expires_at`; a 401 ends the session
  - Regenerated stale `injection.config.dart` (referenced deleted `new_post_feature_dep`)
- [x] **T0.2** Update `sf make api` templates for correct endpoints/headers + Go tests
  - `sf create` starter is this repo (`sumato-globaltech/Super-Flutter@main`), so T0.1 reaches new projects once pushed
  - `sf make api`/`sf make model` sample fetch sends the project API key (`NetworkConstants.apiKeyHeader` + `dart_defines/dev.json`) to the dev host only, and shows the backend's error message
  - App: 403 → `ForbiddenException` ("Access denied"), no longer treated as an expired session
- [x] **T0.3** Backend (`dam`): return effective `permissions` and `profile_active` in `UserResource`, so login, OTP verify and `/me` all carry them, + PHPUnit tests
  - `user.permissions` (sorted, effective) + `user.profile_active` (farmer/vendor/driver profile active), on login, OTP verify and `/me`
  - `tests/Feature/Api/UserAccessApiTest.php` (8 tests); `AuthApiTest` helper updated; full suite 4260 passed, 2 pre-existing web failures (accessibility audit, vendored asset versions)
  - App `UserModel` updated with `sf make model --update`; fixed sf bug that deleted nested classes (`RoleModel`) on `--update`

## Phase 1 — Shared UI & access (built in this project, for your review)
- [x] **T1.1** Confirm sheet + title/details card in `lib/core/ui/widgets`, widget tests, shown on a demo screen
  - `AppConfirmSheet` (`confirm` / `choose` / `show`, async action with spinner + inline error + retry), `TitleDetailsCard` (icon chip, link, loading, copy, read more, blockquote, align end, thumbnails)
  - Demo: `ui_gallery` feature (generated with `sf make feature`), dashboard button outside production
  - 20 widget tests; sf fix: `bloc=skip` no longer leaves orphan event/state files
  - Revised on review: `ConfirmSheet` + `TitleDetailsCard` now copied 1:1 from `ino_irrigation` (with `ShimmerCard`, `ImagePreview`; added `shimmer`, `cached_network_image`). Fixes on top: l10n, `isLoading` honoured, no double submit, close respects dismissible/busy, errors shown not thrown, invisible light-mode tick, read-more font, long-title overflow, null thumbnail URLs
  - Theme fix: duplicate `AppColorsExt` in `app_theme.dart` made `theme.appColors` return light colours in dark mode everywhere
  - `DesignCard` copied 1:1 from `ino_irrigation`; UI gallery cards composed exactly like `scheme_details.dart` (details card, contact card, action cards). `Utils.launchUrl2` / `navigateToMapLocation` re-enabled. Accent icons kept at WCAG 3:1 contrast (dark-mode `tealDeep` etc. were invisible)
- [x] **T1.2** App bar + bottom bar in `lib/core/ui/widgets`, widget tests
  - `AppBottomBar` (2–5 items, active icon, badge count/dot, re-tap reported, theme colours, safe area, clamped text scale) + `AppTopBar` / `AppSliverTopBar` (title + subtitle, actions, bottom, auto back)
  - In UI gallery with a 2/3/5-tab switch; 16 widget tests
- [x] **T1.3** Access layer: `Permission`/`Role` value types, `AccessPolicy` from user, `FeatureRegistry`, unit tests per role
  - Domain: `AccessRule` (public / signedIn / role / permission / profile / any / all), `AccessPolicy`, `Roles`, `Permissions`, `GetCurrentUser`; `User` carries permissions + profileActive
  - `AuthState` carries the user and exposes `access`; `AuthCubit.refreshUser()` for after `/me`
  - `lib/app/access/`: `FeatureRegistry` (tabs by priority, one per path, "More" over 5, secondary list, route guard) + `app_features.dart` table
  - Shipments also need role + active profile (API `shipment.party`), so admins don't get three shipment tabs
- [x] **T1.4** Dynamic home shell: tabs from allowed features, "More" overflow, router guard, rebuild on access change + tests (farmer / vendor / driver / officer / agent)
  - `StatefulShellRoute.indexedStack` with one fixed branch per tab path (`buildAppShellRoute`); `AppShell` shows only allowed tabs, "More" sheet over 5, back returns to Home first
  - Guard in `resolveRedirect`: routes the user may not open go Home; Home never redirects (no loops)
  - Unbuilt tabs show `TabPlaceholderScreen`; dashboard routes moved from the top-level `sf` block into the Home branch (now `appTabRoutes()` in `lib/app/shell/tab_routes.dart`)
  - `AuthCubit` provided in `app.dart`; 11 new tests
- [x] **T1.5** 🔒 **Review gate: you approve the UI and architecture.** Nothing in Phase 2 starts until this is ticked
  - Approved: Phase 1 widgets, UI conventions, access model, dynamic shell
  - Profile = account button in the top bar (built with T3.12); tab order = Home → role work → Market → Schemes

## Phase 2 — CLI (only after T1.5 is approved)
Kits are copied from the approved Phase 1 code. Reinstalling a kit into this project must produce no diff. Generated screens follow the **UI conventions** above.
- [x] **T2.1** Screen template + `sf make screen <feature> <name>`
  - template body is `SingleChildScrollView` → `SafeArea` → `Padding(pagePadding, bottom 0)` → `Column`, with `AppTopBar`
  - title as an l10n key written to `app_en.arb` and read with `final l10n = AppLocalizations.of(context);` (today the template hardcodes `'UI gallery'`)
  - new screen in an existing feature: event/state/bloc/screen + route registration
  - fix existing `sf make feature` output to the same template; golden tests for the template
  - Done: `internal/l10n` (reads `l10n.yaml`, edits ARB in place); title key `<feature><Screen>Title` written to `app_en.arb` + `flutter gen-l10n` run; `AppTopBar`/`AppSpacing` used when present, else `AppBar`/literals; form screens get `maintainBottomViewPadding`
  - `sf make screen <name> --feature <f>`: screen + bloc + route constant + `GoRoute` in the feature's files; registration never duplicated (shell tabs safe)
  - 5 new CLI tests, 3 new goldens, l10n tests; verified on a copy of this project (`flutter analyze`: 0 errors/warnings)
- [x] **T2.2** `sf make widget <name>`: shared widget in `lib/core/ui/widgets`
  - stateless by default, `--variant widget=stateful`; never replaces; `--dry-run` / `--output-json` / `--no-format`
  - widget variants added to the sumato_standard architecture and to this project's `sf.yaml`; 5 CLI tests; verified on a copy (`flutter analyze`: no issues)
- [x] **T2.3** `sf install <kit>`: kits embedded in the `sf` binary (`go:embed`), each with its l10n keys and package dependencies
  - `confirm-sheet`, `title-details-card` (+ `shimmer-card`, `image-preview`, adds `shimmer`, `cached_network_image`), `design-card`, `bottom-bar`, `app-bar`
  - a kit that needs another kit installs it first; reinstall into this project = no diff
  - Done: 7 kits embedded (`internal/kits/data`, synced by `make sync-kits`); package name rewritten; needs derived from imports; missing packages via `flutter pub add`; missing messages added (existing kept) + `gen-l10n`; conflicts need `--force`; `--list` / `--dry-run` / `--no-pub` / `--output-json`
  - Verified on copies of this project: reinstall = no diff; strip + reinstall = identical widgets, packages and messages back, `flutter analyze` 0 errors/warnings. 7 CLI tests + kit tests + starter-sync guard
- [x] **T2.4** `sf install shell`: dynamic home shell + access layer kit
  - Refactor here: `buildAppShellRoute` moved to `lib/app/shell/app_shell_route.dart` (kit), tab routes to `lib/app/shell/tab_routes.dart` (project-owned)
  - Kits gained `base: lib`, seed files (written only when missing: Home-only `app_features.dart`, `tab_routes.dart`) and checks (router uses the shell + guard, `AuthCubit` provided) reported as hints
  - Verified on copies: reinstall = no diff; strip 6 files + 2 seeds and install = identical files, seeds written, `flutter analyze` 0 errors/warnings. 3 new CLI tests
- [x] **T2.5** `sf make feature/screen --access <rule> [--tab]`: registers the feature's access rule and tab in `app_features.dart`; a `--tab` feature's routes go into `appTabRoutes()` in `lib/app/shell/tab_routes.dart` (shell branch), not the top-level `sf:feature-routes` block
  - Done: rule syntax `public | signed-in | profile | role:x | permission:a.b`, `+` all, `|` any, `all()/any()`; `Roles`/`Permissions` constants used when declared; `--tab --icon --priority`; screen-level `--access`; tab features and `sf make screen` never register at the router top level; table + tab routes formatted
  - Verified on a copy: router untouched, `flutter analyze` 0 errors/warnings; 7 new tests
- [ ] **T2.6** Extend `sf make api` (split into sub-tasks, one per "next")
  - [x] **T2.6a** Path parameters: ids (number, hex/UUID, **ULID**) or `{name}` / `:name` become parameters; `ApiEndpoints` gets `static String farmCrops(String farm) => ...`; call takes `String farm`; same route reused; names follow the path (`scheme`, `farm_crops`); calls needing ids print the bloc snippet instead of wiring. Verified against dam.test (`/schemes/{scheme}`), 6 new tests
  - [x] **T2.6b** Query parameters: `?page=1&search=x` → optional named params (typed int/double/bool/String from the sample) + `queryParameters` with null-aware entries; endpoint without the query; keywords suffixed, `filter[x]` skipped with a warning; clashes refused. Also fixed: a list GET was wired into the bloc as `Model` instead of `List<Model>` (compile error). Verified against dam.test `/crops?page=&per_page=&search=`; 3 new tests
  - [x] **T2.6c** Pagination: `meta.current_page`/`last_page` in the sample → `Paged<Model>` via `Paged.fromEnvelope`; starter `lib/core/network/paged.dart` (items, page, lastPage, perPage, total, hasMore, nextPage, append) + 5 tests; `--paged` / `--no-paged`; falls back to the list without `paged.dart`; bloc wiring declares and imports `Paged`. Verified with dam.test crops: no errors; 3 new CLI tests
  - [x] **T2.6d** Multipart upload: `image` / `file` field types (guessed from keys like `photo`, `document`) → `FormData` + `MultipartFile.fromFile`; form fields open `image_picker` / `file_picker`; packages added pinned (`image_picker:^1.2.4`, `file_picker:^13.4.1`); iOS `NSPhotoLibraryUsageDescription` added. Also fixed: `dart format` was given ARB/plist/dirs and formatted nothing. Verified on a copy (real pub add, 0 errors/warnings); 2 new tests. dam's upload routes have ids, so their form screens come with T2.6g
  - [x] **T2.6e** 422 `errors` → per-field errors on generated forms: verified, no change needed. On a copy, `sf make api otp_request -X POST --field phone:phone:required`; real `POST dam.test/api/v1/otp/request` with `phone=123` → `ValidationException(phone: "The phone must be 10 digits.")` → generated bloc `phoneError`; widget test of the generated screen: error under the field, cleared on edit, form submits again (3 tests, all passing)
  - [ ] **T2.6f** Form text → l10n keys: labels, hints, "Select…", "… is required", success toast
  - [ ] **T2.6g** Forms on routes with path params (e.g. `POST /farms/{farm}/crops`): screen takes the id, bloc passes it
  - (T2.7 note) a wired GET leaves its result in an unused local (`unused_local_variable` warning) until the bloc puts it into state - T2.7's loading/success/failure state removes it
  - [ ] **T2.6h** `sf make feature` with a data layer: generated repository leaves `_remoteDataSource` / `_localDataSource` unused (2 analyzer warnings) until methods are added
- [ ] **T2.7** `sf make api` GET → view UI (`--view detail|list|none`)
  - **detail** (object response): a `DesignCard` of `TitleDetailsCard`s, one row per model field, in response order
  - **list** (list response): one `DesignCard(onTap:)` + `TitleDetailsCard(showNavigateIcon: true)` per item, pull-to-refresh, empty state, "load more" when `meta` has pages
  - field → row mapping: label = l10n key from the JSON key (`land_area_ha` → "Land area ha", editable before writing); icon + `DesignColor.accent*` by name/type (`phone` → phone + `onTap` call, `email` → envelope, `*_at`/date → calendar + formatted date, `latitude`+`longitude` → one "Location" row with map `onTap`, `id`/`uin`/`code` → `isCopyable`, long text → `isReadMore`, URL list → `imagePreviewUrls`, bool → Yes/No, nested object → its own `DesignCard`)
  - two consecutive short fields may be paired into one `Row` (asked, or `--pair`)
  - bloc gets loading/success/failure; loading renders `isTextLoading` rows, failure renders `AppErrorView` with retry
  - fields are asked as a checklist so hidden/internal fields can be left out; choices saved so `sf refresh` can regenerate
  - Go tests + golden Dart output; generated screen passes `dart analyze` and a widget test

## Phase 3 — Features (built with the Phase 2 CLI)
Each GET screen starts from `sf make api --view`, then is adjusted by hand where the design needs it.
- [ ] **T3.1** Auth: email/password login, phone OTP request/verify (resend timer from `meta.expires_in`), `/me`, logout, logout-all, forced change password when `password_change_required`
- [ ] **T3.2** Home: banners, alerts, notices, quick actions (only allowed features)
- [ ] **T3.3** Markets: list, summary, price history, favourites
- [ ] **T3.4** Crops: list, detail, advisory, calendar, fertilizers, economics, recommendations
- [ ] **T3.5** Farms *(farmer)*: CRUD, archive/unarchive, farm crops, transactions + summary, photos
- [ ] **T3.6** IoT *(farmer)*: devices, sync, soil-sensor account, readings
- [ ] **T3.7** Schemes: list, detail; farmer apply/applications/documents/withdraw; officer list (`schemes.view`)
- [ ] **T3.8** Help desk: farmer call centre/call-back/tickets; agent queue summary (`helpdesk.manage`)
- [ ] **T3.9** Shipments: farmer request/cancel; vendor accept/reject/assign/receive/reweigh; driver picked/pickup/reach
- [ ] **T3.10** Production insights (`production.view|manage`)
- [ ] **T3.11** Admin notices & alerts (`notices.manage`, `alerts.manage`): list, create, edit, publish/archive/restore, activate/cancel
- [ ] **T3.12** Profile: user info, farmer profile show/update, change password
- [ ] **T3.13** Communication: notices, publications, meetings, facilities + stats
- [ ] **T3.14** Device registration (FCM): after Firebase setup
