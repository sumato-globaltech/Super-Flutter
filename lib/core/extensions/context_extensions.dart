import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textStyles => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get viewInsetsBottom => MediaQuery.viewInsetsOf(this).bottom;

  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);

  bool get isPhone => screenWidth < AppConstants.tabletBreakpoint;

  bool get isTablet =>
      screenWidth >= AppConstants.tabletBreakpoint &&
      screenWidth < AppConstants.desktopBreakpoint;

  bool get isDesktop => screenWidth >= AppConstants.desktopBreakpoint;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.errorContainer : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void hideKeyboard() => FocusScope.of(this).unfocus();
}
