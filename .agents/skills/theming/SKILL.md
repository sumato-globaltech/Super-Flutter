---
name: theming
description: Build UI with the Material 3 design system in this Super Flutter. Use when creating screens, widgets, or layouts; enforces theme tokens, shared components, and asset constants.
---

# Theming

Build from tokens and shared components. No ad-hoc colors, radii, fonts, or
asset strings in feature code.

## Tokens

- `AppTheme.light()/dark()` (`core/ui/theme/app_theme.dart`) — full Material3
  component themes. The `flavor` param is reserved; palettes are intentionally
  flavor-independent (per-flavor accent lives in `AppColors.seedFor`, used
  only for the debug banner).
- `AppColors` (light) / `AppDarkColors` + `AppColorsExt` theme extension
  (`app_colors.dart`). Prefer these; `design_colors.dart` is legacy (mostly
  unused — `prepPurple`/`lightBlue` are spelled-correct aliases).
- `AppTextStyles` — single `Inter` family (400/500/600/700, declared in
  `pubspec.yaml` + `assets/fonts/`); `font()` factory + `textThemeFor()`.
- `AppSizes`/`AppDimensions` (radii incl. `radiusButton: 18`, button heights,
  `maxContentWidth: 720`, `maxFormWidth: 420`) + `AppSpacing`/`Gap`.

## Components (use, don't reinvent)

- Widgets: `AppButton` (filled/tonal/outlined/text/destructive + `isLoading`),
  `AppTextField` (label/hint/validation/password toggle), `AppLoader` /
  `AppInlineLoader` / `AppSkeleton`, `AppEmptyView`, `AppErrorView.fromException`
  (maps `AppException` → icon/title), `AppNetworkImage` (skeleton + fallback).
- Layouts: `AppScaffold` (max-width, keyboard-dismiss, appBar/actions/FAB/sheet
  slots), `AppFormScaffold` (centered 420 form), `ResponsiveLayout` /
  `ConstrainedContent` (breakpoints in `AppConstants`: phone <600, tablet
  600–1024, desktop ≥1024).
- Extensions: `context.theme/colors/textStyles/isDarkMode/screenSize`,
  `showSnackBar`, `hideKeyboard`.

## Assets & fonts

- Declared dirs: `assets/images/`, `assets/icons/`, `assets/animations/`.
  Reference via `AssetConstants` only. Note: several constants currently have
  no matching files (`.gitkeep` only) — add the file before using its constant.
- New font weight → `assets/fonts/` + `pubspec.yaml` + `AppTextStyles`
  together; every style funnels through `font()`.

## Screen checklist

`AppScaffold` + theme `textTheme` + tokens for spacing/radii; loading →
`AppLoader`, empty → `AppEmptyView`, error → `AppErrorView.fromException`
with retry dispatching the Bloc's retry event; failure messages from
`AppException.message`.
