import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'design_colors.dart';

const String appFontFamily = 'Inter';

abstract final class AppFontSizes {
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

abstract final class AppTextStyles {
  static const String fontFamily = appFontFamily;

  /// Every style in the theme goes through this so the family and baseline
  /// stay consistent.
  static TextStyle font({
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

  static TextTheme textThemeFor({required Color body, required Color title}) {
    return TextTheme(
      displayLarge: font(
        fontSize: AppFontSizes.displayLg,
        fontWeight: FontWeight.w700,
        color: title,
        height: 1.1,
        letterSpacing: -0.8,
      ),
      displayMedium: font(
        fontSize: AppFontSizes.displayMd,
        fontWeight: FontWeight.w700,
        color: title,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      headlineMedium: font(
        fontSize: AppFontSizes.titleLg,
        fontWeight: FontWeight.w700,
        color: title,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      titleLarge: font(
        fontSize: AppFontSizes.titleMd,
        fontWeight: FontWeight.w600,
        color: title,
        letterSpacing: -0.2,
      ),
      titleMedium: font(
        fontSize: AppFontSizes.titleSm,
        fontWeight: FontWeight.w600,
        color: title,
      ),
      titleSmall: font(
        fontSize: AppFontSizes.body,
        fontWeight: FontWeight.w600,
        color: title,
      ),
      bodyLarge: font(
        fontSize: AppFontSizes.body + 1,
        fontWeight: FontWeight.w500,
        color: body,
        height: 1.5,
      ),
      bodyMedium: font(
        fontSize: AppFontSizes.body,
        fontWeight: FontWeight.w500,
        color: body,
        height: 1.5,
      ),
      bodySmall: font(
        fontSize: AppFontSizes.bodySm,
        fontWeight: FontWeight.w500,
        color: body,
        height: 1.45,
      ),
      labelLarge: font(
        fontSize: AppFontSizes.button,
        fontWeight: FontWeight.w600,
        color: title,
        letterSpacing: 0.1,
      ),
      labelMedium: font(
        fontSize: AppFontSizes.caption,
        fontWeight: FontWeight.w600,
        color: body,
      ),
      labelSmall: font(
        fontSize: AppFontSizes.caption - 1,
        fontWeight: FontWeight.w600,
        color: body,
        letterSpacing: 0.2,
      ),
    );
  }

  static const monospace = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['Menlo', 'Courier New'],
  );
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
