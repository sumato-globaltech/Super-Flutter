import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../../app/config/flavor.dart';
import 'design_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';

const String appFontFamily = 'Inter';

TextStyle _font({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
}) {
  return TextStyle(
    fontFamily: appFontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    textBaseline: TextBaseline.alphabetic,
  );
}

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF7F9FC);
  static const Color primary = Color(0xFF7DD3FC); // soft sky blue
  static const Color primaryContainer = Color(0xFFEAF6FE); // tinted blue
  static const Color secondary = Color(0xFF2D3561); // deep indigo navy
  static const Color card = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B2559);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE8EDF5);
  static const Color success = Color(0xFF22C55E);
  static const Color successContainer = Color(0xFFE8F8EE);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFDECEC);
  static const Color field = Color(0xFFF3F6FB); // input fill

  static const List<Color> chartCategoriesLight = [
    DesignColor.waterblue,
    DesignColor.orange,
    DesignColor.greenLight1,
    DesignColor.blueDark,
  ];
  static const List<Color> chartCategoriesDark = [
    Color(0xFF0A84FF),
    Color(0xFFFF9F0A),
    Color(0xFF64D2FF),
    Color(0xFFBF5AF2),
  ];
}

class AppDarkColors {
  AppDarkColors._();

  static const Color background = Color(0xFF000000);

  static const Color surfaceFrame = Color(0xFF2C2C2E);

  static const Color surface = Color(0xFF1C1C1E);
  static const Color surface1 = Color(0xFF1C1C1E);

  static const Color surfaceRaised = Color(0xFF3A3A3C);

  static const Color field = Color(0xFF2C2C2E);

  static const Color accent = Color(0xFF0A84FF);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color accentContainer = Color(0xFF183149);
  static const Color onAccentContainer = Color(0xFF9CCDFF);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFFEBEBF5);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textDisabled = Color(0xFF636366); // systemGray2

  static const Color border = Color(0xFF38383A);
  static const Color borderSubtle = Color(0xFF2C2C2E);
  static const Color disabled = Color(0xFF3A3A3C);

  static const Color success = Color(0xFF30D158); // systemGreen
  static const Color successContainer = Color(0xFF204029);
  static const Color warning = Color(0xFFFF9F0A); // systemOrange
  static const Color error = Color(0xFFFF453A); // systemRed
  static const Color errorContainer = Color(0xFF492424);
  static const Color onErrorContainer = Color(0xFFFFB3AE);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFDCECFB), // soft sky blue (top)
      Color(0xFFEFF4FB), // light wash
      AppColors.background, // off-white base (#F7F9FC)
    ],
    stops: [0.0, 0.32, 0.7],
  );

  static const LinearGradient backgroundDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppDarkColors.background, AppDarkColors.background],
    stops: [0.0, 1.0],
  );
}

class AppSizes {
  AppSizes._();

  static const double radiusSm = 12;
  static const double radius = 16;
  static const double radiusMd = 20;
  static const double radiusLg = 24; // cards
  static const double radiusXl = 28;
  static const double radiusXxl = 32;
  static const double radiusButton = 18;
  static const double radiusPill = 999;

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double space = 12;
  static const double spaceMd = 16;
  static const double space20 = 20;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  static const double buttonHeight = 52;
  static const double buttonHeightSm = 44;

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 14,
  );
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 16,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
}

class AppFontSizes {
  AppFontSizes._();
  static const double displayLg = 34; // large wallet amounts
  static const double displayMd = 28;
  static const double titleLg = 22;
  static const double titleMd = 18;
  static const double titleSm = 16;
  static const double body = 14;
  static const double bodySm = 13;
  static const double caption = 12;
  static const double button = 16;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0F1B2559), // ~6% navy
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x0A1B2559), // ~4% navy
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A1B2559),
      blurRadius: 14,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: -6,
    ),
  ];
}

@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color border;
  final Color field;
  final Color textSecondary;
  final Color cardShadow;

  final Color cardWrapper;

  final Color cardContent;

  final Color cardRing;

  final Color accent;
  final List<Color> chartCategories;

  const AppColorsExt({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.border,
    required this.field,
    required this.textSecondary,
    required this.cardShadow,
    required this.cardWrapper,
    required this.cardContent,
    required this.cardRing,
    required this.accent,
    required this.chartCategories,
  });

  @override
  AppColorsExt copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? border,
    Color? field,
    Color? textSecondary,
    Color? cardShadow,
    Color? cardWrapper,
    Color? cardContent,
    Color? cardRing,
    Color? accent,
    List<Color>? chartCategories,
  }) {
    return AppColorsExt(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      border: border ?? this.border,
      field: field ?? this.field,
      textSecondary: textSecondary ?? this.textSecondary,
      cardShadow: cardShadow ?? this.cardShadow,
      cardWrapper: cardWrapper ?? this.cardWrapper,
      cardContent: cardContent ?? this.cardContent,
      cardRing: cardRing ?? this.cardRing,
      accent: accent ?? this.accent,
      chartCategories: chartCategories ?? this.chartCategories,
    );
  }

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    return AppColorsExt(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      border: Color.lerp(border, other.border, t)!,
      field: Color.lerp(field, other.field, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      cardWrapper: Color.lerp(cardWrapper, other.cardWrapper, t)!,
      cardContent: Color.lerp(cardContent, other.cardContent, t)!,
      cardRing: Color.lerp(cardRing, other.cardRing, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      chartCategories: [
        for (var i = 0; i < chartCategories.length; i++)
          Color.lerp(
            chartCategories[i],
            other.chartCategories[i % other.chartCategories.length],
            t,
          )!,
      ],
    );
  }
}

extension AppThemeX on ThemeData {
  AppColorsExt get appColors => extension<AppColorsExt>() ?? _lightAppColors;
}

extension AppTextThemeX on TextTheme {
  bool get _isDarkText =>
      (bodyMedium?.color ?? Colors.black).computeLuminance() > 0.5;

  Color get _mutedColor =>
      _isDarkText ? AppDarkColors.textSecondary : DesignColor.grey900;

  TextStyle get h1 => displayMedium ?? const TextStyle();
  TextStyle get h2 => headlineMedium ?? const TextStyle();
  TextStyle get h3 => titleLarge ?? const TextStyle();
  TextStyle get h4 => titleMedium ?? const TextStyle();
  TextStyle get large => titleLarge ?? const TextStyle();
  TextStyle get small => titleSmall ?? const TextStyle();
  TextStyle get p => bodyMedium ?? const TextStyle();
  TextStyle get list => bodyMedium ?? const TextStyle();
  TextStyle get table => titleMedium ?? const TextStyle();
  TextStyle get lead =>
      (bodyLarge ?? const TextStyle()).copyWith(color: _mutedColor);
  TextStyle get muted =>
      (bodySmall ?? const TextStyle()).copyWith(color: _mutedColor);
  TextStyle get blockquote =>
      (bodyMedium ?? const TextStyle()).copyWith(fontStyle: FontStyle.italic);
}

const AppColorsExt _lightAppColors = AppColorsExt(
  success: AppColors.success,
  successContainer: AppColors.successContainer,
  warning: Color(0xFFF59E0B),
  border: AppColors.border,
  field: AppColors.field,
  textSecondary: AppColors.textSecondary,
  cardShadow: Color(0x0F1B2559),
  cardWrapper: Color(0xFFF3F4F6),
  cardContent: Color(0xFFFFFFFF),
  cardRing: Color(0xFFE5E7EB),
  accent: AppDarkColors.accent,
  chartCategories: AppColors.chartCategoriesLight,
);

TextTheme _buildTextTheme({required Color body, required Color title}) {
  return TextTheme(
    displayLarge: _font(
      fontSize: AppFontSizes.displayLg,
      fontWeight: FontWeight.w700,
      color: title,
      height: 1.1,
      letterSpacing: -0.8,
    ),
    displayMedium: _font(
      fontSize: AppFontSizes.displayMd,
      fontWeight: FontWeight.w700,
      color: title,
      height: 1.15,
      letterSpacing: -0.5,
    ),
    headlineMedium: _font(
      fontSize: AppFontSizes.titleLg,
      fontWeight: FontWeight.w700,
      color: title,
      height: 1.25,
      letterSpacing: -0.3,
    ),
    titleLarge: _font(
      fontSize: AppFontSizes.titleMd,
      fontWeight: FontWeight.w600,
      color: title,
      letterSpacing: -0.2,
    ),
    titleMedium: _font(
      fontSize: AppFontSizes.titleSm,
      fontWeight: FontWeight.w600,
      color: title,
    ),
    titleSmall: _font(
      fontSize: AppFontSizes.body,
      fontWeight: FontWeight.w600,
      color: title,
    ),
    bodyLarge: _font(
      fontSize: AppFontSizes.body + 1,
      fontWeight: FontWeight.w500,
      color: body,
      height: 1.5,
    ),
    bodyMedium: _font(
      fontSize: AppFontSizes.body,
      fontWeight: FontWeight.w500,
      color: body,
      height: 1.5,
    ),
    bodySmall: _font(
      fontSize: AppFontSizes.bodySm,
      fontWeight: FontWeight.w500,
      color: body,
      height: 1.45,
    ),
    labelLarge: _font(
      fontSize: AppFontSizes.button,
      fontWeight: FontWeight.w600,
      color: title,
      letterSpacing: 0.1,
    ),
    labelMedium: _font(
      fontSize: AppFontSizes.caption,
      fontWeight: FontWeight.w600,
      color: body,
    ),
    labelSmall: _font(
      fontSize: AppFontSizes.caption - 1,
      fontWeight: FontWeight.w600,
      color: body,
      letterSpacing: 0.2,
    ),
  );
}

const RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusButton)),
);

final TextStyle _buttonTextStyle = _font(
  fontSize: AppFontSizes.button,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
);

ElevatedButtonThemeData _elevatedButtonTheme({
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
      overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0.08)),
      textStyle: WidgetStatePropertyAll(_buttonTextStyle),
    ),
  );
}

FilledButtonThemeData _filledButtonTheme({
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
      overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0.08)),
      textStyle: WidgetStatePropertyAll(_buttonTextStyle),
    ),
  );
}

OutlinedButtonThemeData _outlinedButtonTheme({
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
      overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0.05)),
      textStyle: WidgetStatePropertyAll(_buttonTextStyle),
    ),
  );
}

TextButtonThemeData _textButtonTheme({required Color foreground}) {
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
      overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0.06)),
      textStyle: WidgetStatePropertyAll(
        _font(fontSize: AppFontSizes.body, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

InputDecorationTheme _inputDecorationTheme({
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
    hintStyle: _font(
      color: hint,
      fontSize: AppFontSizes.body,
      fontWeight: FontWeight.w500,
    ),
    labelStyle: _font(
      color: label,
      fontSize: AppFontSizes.body,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: _font(
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

final ThemeData theme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: appFontFamily,
  scaffoldBackgroundColor: Colors.white,
  splashFactory: InkSparkle.splashFactory,
  extensions: const [_lightAppColors],
  colorScheme: const ColorScheme.light(
    primary: AppColors.textPrimary,
    // onPrimary: AppColors.textPrimary,
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
  textTheme: _buildTextTheme(
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
    titleTextStyle: _font(
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
    // Same button colour in both themes — see darkTheme below.
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
    labelStyle: _font(
      fontSize: AppFontSizes.bodySm,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    secondaryLabelStyle: _font(
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
    titleTextStyle: _font(
      color: AppColors.textPrimary,
      fontSize: AppFontSizes.titleMd,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: _font(
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
    extendedTextStyle: _font(
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
    selectedLabelStyle: _font(
      fontSize: AppFontSizes.caption,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: _font(
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
      _font(fontSize: AppFontSizes.caption, fontWeight: FontWeight.w600),
    ),
  ),
  listTileTheme: ListTileThemeData(
    iconColor: AppColors.textPrimary,
    textColor: AppColors.textPrimary,
    tileColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    titleTextStyle: _font(
      fontSize: AppFontSizes.body + 1,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    subtitleTextStyle: _font(
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
    contentTextStyle: _font(
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
    labelStyle: _font(fontSize: AppFontSizes.body, fontWeight: FontWeight.w600),
    unselectedLabelStyle: _font(
      fontSize: AppFontSizes.body,
      fontWeight: FontWeight.w500,
    ),
  ),
);

const AppColorsExt _darkAppColors = AppColorsExt(
  success: AppDarkColors.success,
  successContainer: AppDarkColors.successContainer,
  warning: AppDarkColors.warning,
  border: AppDarkColors.border,
  field: AppDarkColors.field,
  textSecondary: AppDarkColors.textSecondary,
  cardShadow: Color(0x00000000),
  cardWrapper: Color.fromARGB(169, 28, 28, 30),
  cardContent: AppDarkColors.surface,
  cardRing: AppDarkColors.surfaceFrame,
  accent: AppDarkColors.accent,
  chartCategories: AppColors.chartCategoriesDark,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  fontFamily: appFontFamily,
  scaffoldBackgroundColor: AppDarkColors.background,
  splashFactory: InkSparkle.splashFactory,
  extensions: const [_darkAppColors],
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
  textTheme: _buildTextTheme(
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
    titleTextStyle: _font(
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
  iconTheme: const IconThemeData(color: AppDarkColors.textPrimary, size: 24),
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
    labelStyle: _font(
      fontSize: AppFontSizes.bodySm,
      fontWeight: FontWeight.w600,
      color: AppDarkColors.textPrimary,
    ),
    secondaryLabelStyle: _font(
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
    titleTextStyle: _font(
      color: AppDarkColors.textPrimary,
      fontSize: AppFontSizes.titleMd,
      fontWeight: FontWeight.w700,
    ),
    contentTextStyle: _font(
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
    extendedTextStyle: _font(
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
    selectedLabelStyle: _font(
      fontSize: AppFontSizes.caption,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: _font(
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
      _font(fontSize: AppFontSizes.caption, fontWeight: FontWeight.w600),
    ),
  ),
  listTileTheme: ListTileThemeData(
    iconColor: AppDarkColors.textPrimary,
    textColor: AppDarkColors.textPrimary,
    tileColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    titleTextStyle: _font(
      fontSize: AppFontSizes.body + 1,
      fontWeight: FontWeight.w600,
      color: AppDarkColors.textPrimary,
    ),
    subtitleTextStyle: _font(
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
    contentTextStyle: _font(
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
      if (states.contains(WidgetState.selected)) return AppDarkColors.success;
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
    labelStyle: _font(fontSize: AppFontSizes.body, fontWeight: FontWeight.w600),
    unselectedLabelStyle: _font(
      fontSize: AppFontSizes.body,
      fontWeight: FontWeight.w500,
    ),
  ),
);

abstract final class AppTheme {
  /// Flavor is accepted for future per-flavor theming. The base light/dark
  /// palettes are currently flavor-independent by design; per-flavor
  /// accents live in [AppColors.seedFor] (debug banner).
  static ThemeData light(Flavor flavor) => _light;

  /// See [light] — [flavor] reserved for future per-flavor dark theming.
  static ThemeData dark(Flavor flavor) => _dark;

  static final ThemeData _light = theme;

  static final ThemeData _dark = darkTheme;
  
  
}
