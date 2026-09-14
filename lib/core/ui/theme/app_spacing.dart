import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const none = 0.0;
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  static const pagePadding = EdgeInsets.all(lg);

  static const listPadding = EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  static const cardPadding = EdgeInsets.all(md);
}

abstract final class Gap {
  static const xxs = SizedBox(height: AppSpacing.xxs, width: AppSpacing.xxs);
  static const xs = SizedBox(height: AppSpacing.xs, width: AppSpacing.xs);
  static const sm = SizedBox(height: AppSpacing.sm, width: AppSpacing.sm);
  static const md = SizedBox(height: AppSpacing.md, width: AppSpacing.md);
  static const lg = SizedBox(height: AppSpacing.lg, width: AppSpacing.lg);
  static const xl = SizedBox(height: AppSpacing.xl, width: AppSpacing.xl);
  static const xxl = SizedBox(height: AppSpacing.xxl, width: AppSpacing.xxl);
}
