---
name: verify
description: Run the mandatory verification pipeline in this Super Flutter. Use after any code change and before handoff or commit; fails the task if any step is red.
---

# Verify

Run in this order. Stop and fix on the first red step.

```bash
dart run build_runner build
flutter analyze --no-pub
flutter test
flutter gen-l10n
git status --short
```

## What each step catches

1. **Codegen** — regenerates `injection.config.dart`, `*.g.dart`
   (json_serializable, drift). Expected warning only:
   `[Environment] depends on unregistered type [AppConfig]` — `AppConfig` is
   deliberately registered manually in `configureDependencies()` before
   `getIt.init()`; the generated `gh<AppConfig>()` resolves at runtime.
   Any other `Missing dependencies` warning or `InvalidType` is a real error.
2. **Analyze** — must report `No issues found!`. Generated files
   (`*.g.dart`, `*.config.dart`, `app_localizations*.dart`) are excluded in
   `analysis_options.yaml`; findings in them mean the generator input is wrong.
3. **Test** — `flutter test` all green (currently 18 tests: network, auth
   status/login, dashboard sign-out, auth repository).
4. **l10n** — `flutter gen-l10n`; `git status` should show no unexpected
   changes to generated localization outputs.
5. **Hygiene** — `git status --short`: only intended files; no secrets,
   no `build/` artifacts, no hand-edited generated files.

## DI gotchas that break codegen

- `package:injectable/injectable.dart` exports an `Environment` annotation
  that clashes with the app's `Environment` class. Every DI module importing
  both must use `import 'package:injectable/injectable.dart' hide Environment;`
  (`app_modules.dart`, `storage_module.dart`, `network_module.dart`) or the
  build fails with `InvalidType is not a class element`.
- `SessionManagerImpl` must look up `AuthCubit` lazily via `GetIt` (never
  constructor-inject) — otherwise the graph cycles
  (Cubit → Repository → Remote → DioClient → SessionManager → Cubit) and DI
  resolution fails at runtime.
- Never hand-edit `injection.config.dart`, `*.g.dart`, `local_storage.g.dart`,
  or `app_localizations*.dart`. Fix the annotated input and re-run codegen.
