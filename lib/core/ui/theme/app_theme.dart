import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/config/flavor.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';
import 'design_colors.dart';

abstract final class AppTheme {
  /// Flavor is accepted for future per-flavor theming. The base light/dark
  /// palettes are currently flavor-independent by design; per-flavor
  /// accents live in [AppColors.seedFor] (debug banner).
  static ThemeData light(Flavor flavor) => _light;

  /// See [light] — [flavor] reserved for future per-flavor dark theming.
  static ThemeData dark(Flavor flavor) => _dark;

  static final ThemeData _light = _buildLight();

  static final ThemeData _dark = _buildDark();

  static const RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusButton)),
  );

  static final TextStyle _buttonTextStyle = AppTextStyles.font(
    fontSize: AppFontSizes.button,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static ElevatedButtonThemeData _elevatedButtonTheme({
    required Color background,
    required Color foreground,
    required Color disabledBg,
    required Color disabledFg,
  }) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size.fromHeight(AppSizes.buttonHeight),
        ),
        padding: const WidgetStatePropertyAll(AppSizes.buttonPadding),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: const WidgetStatePropertyAll(_buttonShape),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledBg;
          return background;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledFg;
          return foreground;
        }),
        overlayColor: WidgetStatePropertyAll(
          foreground.withValues(alpha: 0.08),
        ),
        textStyle: WidgetStatePropertyAll(_buttonTextStyle),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme({
    required Color background,
    required Color foreground,
    required Color disabledBg,
    required Color disabledFg,
  }) {
    return FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size.fromHeight(AppSizes.buttonHeight),
        ),
        padding: const WidgetStatePropertyAll(AppSizes.buttonPadding),
        elevation: const WidgetStatePropertyAll(0),
        shape: const WidgetStatePropertyAll(_buttonShape),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledBg;
          return background;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledFg;
          return foreground;
        }),
        overlayColor: WidgetStatePropertyAll(
          foreground.withValues(alpha: 0.08),
        ),
        textStyle: WidgetStatePropertyAll(_buttonTextStyle),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({
    required Color foreground,
    required Color borderColor,
    required Color disabledFg,
  }) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size.fromHeight(AppSizes.buttonHeight),
        ),
        padding: const WidgetStatePropertyAll(AppSizes.buttonPadding),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: const WidgetStatePropertyAll(_buttonShape),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: borderColor.withValues(alpha: 0.5));
          }
          return BorderSide(color: borderColor, width: 1.4);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledFg;
          return foreground;
        }),
        overlayColor: WidgetStatePropertyAll(
          foreground.withValues(alpha: 0.05),
        ),
        textStyle: WidgetStatePropertyAll(_buttonTextStyle),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme({required Color foreground}) {
    return TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size(0, AppSizes.buttonHeightSm),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSm)),
          ),
        ),
        foregroundColor: WidgetStatePropertyAll(foreground),
        overlayColor: WidgetStatePropertyAll(
          foreground.withValues(alpha: 0.06),
        ),
        textStyle: WidgetStatePropertyAll(
          AppTextStyles.font(
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fill,
    required Color border,
    required Color focusBorder,
    required Color hint,
    required Color label,
    Color error = AppColors.error,
  }) {
    OutlineInputBorder buildBorder(Color color, {double width = 1.2}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: AppSizes.fieldPadding,
      hintStyle: AppTextStyles.font(
        color: hint,
        fontSize: AppFontSizes.body,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: AppTextStyles.font(
        color: label,
        fontSize: AppFontSizes.body,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: AppTextStyles.font(
        color: focusBorder,
        fontSize: AppFontSizes.body,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: hint,
      suffixIconColor: hint,
      border: buildBorder(border),
      enabledBorder: buildBorder(border),
      focusedBorder: buildBorder(focusBorder, width: 1.6),
      errorBorder: buildBorder(error),
      focusedErrorBorder: buildBorder(error, width: 1.6),
    );
  }

  static ThemeData _buildLight() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: appFontFamily,
      scaffoldBackgroundColor: Colors.white,
      splashFactory: InkSparkle.splashFactory,
      extensions: const [AppColorsExt.light],
      colorScheme: const ColorScheme.light(
        primary: AppColors.textPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.secondary,
        secondary: Colors.white,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.primaryContainer,
        onSecondaryContainer: AppColors.secondary,
        tertiary: AppColors.success,
        onTertiary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.field,
        onSurfaceVariant: AppColors.textSecondary,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorContainer,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        shadow: Color(0x141B2559),
      ),
      textTheme: AppTextStyles.textThemeFor(
        body: DesignColor.slate700,
        title: DesignColor.slate900,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.font(
          color: AppColors.textPrimary,
          fontSize: AppFontSizes.titleMd,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: DesignColor.grey150,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x141B2559),
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(
        // Same button colour in both themes — see the dark theme below.
        background: AppDarkColors.accent,
        foreground: AppDarkColors.onAccent,
        disabledBg: AppColors.border,
        disabledFg: AppColors.textSecondary,
      ),
      filledButtonTheme: _filledButtonTheme(
        background: AppColors.primary,
        foreground: AppColors.textPrimary,
        disabledBg: AppColors.border,
        disabledFg: AppColors.textSecondary,
      ),
      outlinedButtonTheme: _outlinedButtonTheme(
        foreground: AppColors.secondary,
        borderColor: AppColors.border,
        disabledFg: AppColors.textSecondary,
      ),
      textButtonTheme: _textButtonTheme(foreground: AppColors.secondary),
      inputDecorationTheme: _inputDecorationTheme(
        fill: AppColors.field,
        border: AppColors.border,
        focusBorder: AppColors.secondary,
        hint: AppColors.textSecondary,
        label: AppColors.textSecondary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      primaryIconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: AppSizes.spaceMd,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.secondary,
        secondarySelectedColor: AppColors.secondary,
        disabledColor: AppColors.field,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.bodySm,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.bodySm,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: const Color(0x141B2559),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        titleTextStyle: AppTextStyles.font(
          color: AppColors.textPrimary,
          fontSize: AppFontSizes.titleMd,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: AppTextStyles.font(
          color: AppColors.textSecondary,
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 4,
        highlightElevation: 2,
        splashColor: Colors.white24,
        extendedTextStyle: AppTextStyles.font(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppDarkColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.caption,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.caption,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.font(
            fontSize: AppFontSizes.caption,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.textPrimary,
        textColor: AppColors.textPrimary,
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        titleTextStyle: AppTextStyles.font(
          fontSize: AppFontSizes.body + 1,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: AppTextStyles.font(
          fontSize: AppFontSizes.bodySm,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
        contentTextStyle: AppTextStyles.font(
          color: Colors.white,
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.secondary;
          return AppColors.border;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.secondary,
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData _buildDark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: appFontFamily,
      scaffoldBackgroundColor: AppDarkColors.background,
      splashFactory: InkSparkle.splashFactory,
      extensions: const [AppColorsExt.dark],
      colorScheme: const ColorScheme.dark(
        primary: AppDarkColors.accent,
        onPrimary: AppDarkColors.onAccent,
        primaryContainer: AppDarkColors.accentContainer,
        onPrimaryContainer: AppDarkColors.onAccentContainer,
        secondary: AppDarkColors.accent,
        onSecondary: AppDarkColors.onAccent,
        secondaryContainer: AppDarkColors.accentContainer,
        onSecondaryContainer: AppDarkColors.onAccentContainer,
        secondaryFixed: AppDarkColors.surfaceRaised,
        onSecondaryFixed: AppDarkColors.textPrimary,
        tertiary: AppDarkColors.success,
        onTertiary: AppDarkColors.onAccent,
        surface: AppDarkColors.surface,
        onSurface: AppDarkColors.textPrimary,
        surfaceContainerLowest: AppDarkColors.background,
        surfaceContainerLow: AppDarkColors.surface,
        surfaceContainer: AppDarkColors.surfaceFrame,
        surfaceContainerHigh: AppDarkColors.surfaceRaised,
        surfaceContainerHighest: AppDarkColors.surfaceRaised,
        onSurfaceVariant: AppDarkColors.textSecondary,
        error: AppDarkColors.error,
        onError: AppDarkColors.onAccent,
        errorContainer: AppDarkColors.errorContainer,
        onErrorContainer: AppDarkColors.onErrorContainer,
        outline: AppDarkColors.border,
        outlineVariant: AppDarkColors.borderSubtle,
        shadow: Colors.black,
        scrim: Colors.black,
      ),
      textTheme: AppTextStyles.textThemeFor(
        body: AppDarkColors.textBody,
        title: AppDarkColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppDarkColors.textPrimary,
        iconTheme: const IconThemeData(color: AppDarkColors.textPrimary),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.font(
          color: AppDarkColors.textPrimary,
          fontSize: AppFontSizes.titleMd,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppDarkColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(
        background: AppDarkColors.accent,
        foreground: AppDarkColors.onAccent,
        disabledBg: AppDarkColors.disabled,
        disabledFg: AppDarkColors.textDisabled,
      ),
      filledButtonTheme: _filledButtonTheme(
        background: AppDarkColors.accent,
        foreground: AppDarkColors.onAccent,
        disabledBg: AppDarkColors.disabled,
        disabledFg: AppDarkColors.textDisabled,
      ),
      outlinedButtonTheme: _outlinedButtonTheme(
        foreground: AppDarkColors.textPrimary,
        borderColor: AppDarkColors.border,
        disabledFg: AppDarkColors.textDisabled,
      ),
      textButtonTheme: _textButtonTheme(foreground: AppDarkColors.accent),
      inputDecorationTheme: _inputDecorationTheme(
        fill: AppDarkColors.field,
        border: AppDarkColors.border,
        focusBorder: AppDarkColors.accent,
        hint: AppDarkColors.textSecondary,
        label: AppDarkColors.textSecondary,
        error: AppDarkColors.error,
      ),
      iconTheme: const IconThemeData(
        color: AppDarkColors.textPrimary,
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(color: AppDarkColors.textPrimary),
      dividerTheme: const DividerThemeData(
        color: AppDarkColors.border,
        thickness: 1,
        space: AppSizes.spaceMd,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppDarkColors.surfaceRaised,
        selectedColor: AppDarkColors.accent,
        secondarySelectedColor: AppDarkColors.accent,
        disabledColor: AppDarkColors.disabled,
        checkmarkColor: AppDarkColors.onAccent,
        showCheckmark: false,
        side: const BorderSide(color: AppDarkColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.bodySm,
          fontWeight: FontWeight.w600,
          color: AppDarkColors.textPrimary,
        ),
        secondaryLabelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.bodySm,
          fontWeight: FontWeight.w600,
          color: AppDarkColors.onAccent,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppDarkColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        titleTextStyle: AppTextStyles.font(
          color: AppDarkColors.textPrimary,
          fontSize: AppFontSizes.titleMd,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: AppTextStyles.font(
          color: AppDarkColors.textSecondary,
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppDarkColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppDarkColors.accent,
        foregroundColor: AppDarkColors.onAccent,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 4,
        highlightElevation: 2,
        splashColor: Colors.white24,
        extendedTextStyle: AppTextStyles.font(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppDarkColors.surface,
        selectedItemColor: AppDarkColors.accent,
        unselectedItemColor: AppDarkColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.caption,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.caption,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppDarkColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppDarkColors.accentContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.font(
            fontSize: AppFontSizes.caption,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppDarkColors.textPrimary,
        textColor: AppDarkColors.textPrimary,
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        titleTextStyle: AppTextStyles.font(
          fontSize: AppFontSizes.body + 1,
          fontWeight: FontWeight.w600,
          color: AppDarkColors.textPrimary,
        ),
        subtitleTextStyle: AppTextStyles.font(
          fontSize: AppFontSizes.bodySm,
          fontWeight: FontWeight.w500,
          color: AppDarkColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppDarkColors.surfaceRaised,
        contentTextStyle: AppTextStyles.font(
          color: AppDarkColors.textPrimary,
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppDarkColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppDarkColors.success;
          }
          return AppDarkColors.surfaceRaised;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppDarkColors.accent,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppDarkColors.accent,
        unselectedLabelColor: AppDarkColors.textSecondary,
        indicatorColor: AppDarkColors.accent,
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.font(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
