import 'package:flutter/widgets.dart';

/// The radius, spacing and control-size scale the theme is built from.
/// [AppDimensions] below aliases onto it so widget-level decoration lands on
/// the same scale as the component themes.
abstract final class AppSizes {
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

abstract final class AppDimensions {
  static const radiusXs = 4.0;
  static const radiusSm = AppSizes.radiusSm;
  static const radiusMd = AppSizes.radius;
  static const radiusLg = AppSizes.radiusLg;
  static const radiusXl = AppSizes.radiusXl;
  static const radiusFull = AppSizes.radiusPill;

  static const borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));

  static const buttonHeight = AppSizes.buttonHeight;
  static const buttonHeightSmall = AppSizes.buttonHeightSm;
  static const inputHeight = 56.0;
  static const minTouchTarget = 48.0;

  static const iconXs = 14.0;
  static const iconSm = 18.0;
  static const iconMd = 24.0;
  static const iconLg = 32.0;
  static const iconXl = 48.0;

  static const thumbnailSize = 56.0;
  static const avatarSm = 32.0;
  static const avatarMd = 48.0;
  static const avatarLg = 88.0;
  static const heroAspectRatio = 4 / 3;

  static const maxContentWidth = 720.0;
  static const maxFormWidth = 420.0;
  static const dividerThickness = 1.0;
  static const cardElevation = 0.0;
}
