---
name: l10n
description: Manage EN/ES localization in this Super Flutter. Use when adding or changing any user-facing string; ARB files are the source of truth with flutter gen-l10n codegen.
---

# Localization

`lib/core/localization/arb/app_en.arb` (+ `app_es.arb`) is the source of truth.
Generated outputs (`app_localizations*.dart`) are committed but never hand-edited.
Wired in `MyApp` via `AppLocalizations.delegate` + `Global*` delegates.

## Workflow

1. Add the key to `app_en.arb` **and** `app_es.arb` (parity is required —
   both files carry the same key set today).
2. Include `@*` metadata for ICU messages and descriptions:
   ```json
   "inStockCount": "{count, plural, =0{Sold out} =1{1 in stock} other{{count} in stock}}",
   "@inStockCount": {
     "description": "Stock level for a product",
     "placeholders": { "count": { "type": "int" } }
   }
   ```
   Every parameterized key needs `@key.placeholders`; keep `@appTitle`-style
   descriptions so translators have context.
3. Run `flutter gen-l10n` (also runs automatically on `flutter run`/`build`;
   config in `l10n.yaml`: `template: app_en.arb`, `output-class: AppLocalizations`,
   `nullable-getter: false`, `flutter generate: true` in pubspec).
4. Consume via `AppLocalizations.of(context)` (aliased `l10n` in screens):
   `l10n.signIn`, `l10n.inStockCount(3)`. Never hardcode user-facing text —
   including demo hints and error strings (map `AppException` to l10n keys at
   the presentation edge where practical).

## Current coverage (~30 keys)

App title; auth (`signIn/signOut/username/password/...`); shop
(`home/products/search/categories/...`); greetings; ICU (`inStockCount`,
`percentOff`, `showingSavedData`); empty states; errors
(`errorNoConnection/errorTimeout/errorServer/errorSessionExpired/errorUnknown`).

## Gotchas

- `StorageKeys.locale` exists but locale resolution is not wired in `MyApp` —
  do not promise runtime language switching until that is implemented.
- `analysis_options.yaml` excludes generated `app_localizations*.dart` from
  analysis; analyze will not flag issues there.
