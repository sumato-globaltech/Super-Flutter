import 'package:flutter/material.dart';

import '../../../app/config/flavor.dart';
import 'design_colors.dart';

/// Light palette. Values are fixed rather than seed-generated so both themes
/// render exactly as designed; the flavor seed below only tints the debug
/// banner.
abstract final class AppColors {
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

  static const productionSeed = Color(0xFF2563EB);
  static const stagingSeed = Color(0xFFB45309);
  static const developmentSeed = Color(0xFF15803D);

  /// Only used to colour the flavor banner — the themes themselves are fixed.
  static Color seedFor(Flavor flavor) => switch (flavor) {
    Flavor.production => productionSeed,
    Flavor.staging => stagingSeed,
    Flavor.development => developmentSeed,
  };
}

/// Dark palette, tracking the iOS system colours.
abstract final class AppDarkColors {
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

abstract final class AppGradients {
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

abstract final class AppShadows {
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

/// Colours the Material [ColorScheme] has no slot for. Read them through
/// `Theme.of(context).appColors`.
@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
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

  static const AppColorsExt light = AppColorsExt(
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

  static const AppColorsExt dark = AppColorsExt(
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
  AppColorsExt get appColors => extension<AppColorsExt>() ?? AppColorsExt.light;
}

extension AppColorsX on ColorScheme {
  bool get _isDark => brightness == Brightness.dark;

  Color get success => _isDark ? AppDarkColors.success : AppColors.success;

  Color get warning =>
      _isDark ? AppDarkColors.warning : AppColorsExt.light.warning;

  Color get info => AppDarkColors.accent;

  Color get skeleton => _isDark ? AppDarkColors.surfaceFrame : AppColors.field;
}
