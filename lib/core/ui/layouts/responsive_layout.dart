import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../theme/app_dimensions.dart';

enum ScreenSize { phone, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.phone,
    this.tablet,
    this.desktop,
    super.key,
  });

  final WidgetBuilder phone;

  final WidgetBuilder? tablet;

  final WidgetBuilder? desktop;

  static ScreenSize sizeOf(double width) {
    if (width >= AppConstants.desktopBreakpoint) return ScreenSize.desktop;
    if (width >= AppConstants.tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.phone;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (sizeOf(constraints.maxWidth)) {
          ScreenSize.desktop => (desktop ?? tablet ?? phone)(context),
          ScreenSize.tablet => (tablet ?? phone)(context),
          ScreenSize.phone => phone(context),
        };
      },
    );
  }
}

class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    required this.child,
    this.maxWidth = AppDimensions.maxContentWidth,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
