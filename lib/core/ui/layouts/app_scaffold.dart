import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.appBar,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.padding,
    this.constrainWidth = true,
    this.maxContentWidth = AppDimensions.maxContentWidth,
    this.dismissKeyboardOnTap = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    super.key,
  });

  final Widget body;

  final String? title;

  final PreferredSizeWidget? appBar;

  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;

  final EdgeInsetsGeometry? padding;

  final bool constrainWidth;
  final double maxContentWidth;
  final bool dismissKeyboardOnTap;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (constrainWidth) {
      content = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: content,
        ),
      );
    }

    if (dismissKeyboardOnTap) {
      content = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: context.hideKeyboard,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar:
          appBar ??
          (title == null
              ? null
              : AppBar(title: Text(title!), actions: actions)),
      body: SafeArea(child: content),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
    );
  }
}

class AppFormScaffold extends StatelessWidget {
  const AppFormScaffold({required this.child, this.title, super.key});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      constrainWidth: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxFormWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
