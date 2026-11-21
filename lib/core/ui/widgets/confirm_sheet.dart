import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/constants/assets_names.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'progress_circle.dart';

class ConfirmSheet extends StatefulWidget {
  const ConfirmSheet({
    super.key,
    this.isDismissible = true,
    required this.title,
    required this.description,
    this.confirmText,
    this.confirmColor,
    this.onPressed,
    this.isLoading = false,
    this.assetPath,
    this.icon,
    this.actions = const [],
    this.child,
  });

  final bool isDismissible;
  final String title;
  final String description;
  final String? confirmText;
  final Color? confirmColor;
  final Future<void> Function()? onPressed;
  final bool isLoading;
  final String? assetPath;
  final Widget? icon;
  final List<SheetAction> actions;
  final Widget? child;

  /// Opens [sheet] the way every ConfirmSheet is shown: full height allowed,
  /// transparent so the close button floats above the rounded sheet.
  static Future<T?> show<T>(BuildContext context, ConfirmSheet sheet) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: sheet.isDismissible,
      enableDrag: sheet.isDismissible && sheet.onPressed == null,
      builder: (_) => sheet,
    );
  }

  /// Asks a yes/no question. [onConfirm] runs with the button spinning; the
  /// sheet closes with true once it completes, and stays open with the error
  /// when it throws.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String description = '',
    Widget? icon,
    String? confirmText,
    Color? confirmColor,
    Future<void> Function()? onConfirm,
  }) async {
    final confirmed = await show<bool>(
      context,
      ConfirmSheet(
        title: title,
        description: description,
        icon: icon,
        confirmText: confirmText,
        confirmColor: confirmColor,
        onPressed: () async {
          await onConfirm?.call();
          if (context.mounted) Navigator.of(context).pop(true);
        },
      ),
    );
    return confirmed ?? false;
  }

  /// Lets the user pick one of [actions]; returns its value.
  static Future<T?> choose<T>(
    BuildContext context, {
    required String title,
    required List<SheetAction<T>> actions,
    String description = '',
    Widget? icon,
  }) {
    return show<T>(
      context,
      ConfirmSheet(
        title: title,
        description: description,
        icon: icon,
        actions: actions,
      ),
    );
  }

  @override
  State<ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<ConfirmSheet> {
  bool isloading = false;
  String? _error;

  bool get _busy => isloading || widget.isLoading;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      isloading = true;
      _error = null;
    });
    try {
      await widget.onPressed!();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AppException
              ? error.message
              : l10n.errorUnknown,
        );
      }
    } finally {
      if (mounted) setState(() => isloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canClose = widget.isDismissible && !_busy;
    return PopScope(
      canPop: canClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            enabled: canClose,
            label: MaterialLocalizations.of(context).closeButtonTooltip,
            child: GestureDetector(
              onTap: canClose ? () => Navigator.of(context).maybePop() : null,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.appColors.cardWrapper,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Icon(
                  Icons.close,
                  color: canClose
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ),
          ),
          12.height,
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXl),
              ),
              color: theme.colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null ||
                    (widget.actions.isEmpty && widget.child == null)) ...[
                  const SizedBox(height: 20),
                  widget.icon ??
                      Image.asset(
                        widget.assetPath ?? AssetsName.appLogo,
                        height: 80,
                      ),
                  const SizedBox(height: 10),
                ],
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      12,
                      12,
                      12 + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: Column(
                      children: [
                        if (widget.title.isNotEmpty) ...[
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium,
                          ),
                          10.height,
                        ],
                        if (widget.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            widget.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                        if (widget.actions.isNotEmpty) ...[
                          10.height,
                          ...widget.actions.map((action) {
                            final color = action.isDestructive
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface;
                            return InkWell(
                              onTap: () =>
                                  Navigator.of(context).pop(action.value),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    if (action.icon != null) ...[
                                      Icon(action.icon, color: color, size: 22),
                                      12.width,
                                    ],
                                    Expanded(
                                      child: Text(
                                        action.label,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(color: color),
                                      ),
                                    ),
                                    if (action.selected)
                                      Icon(
                                        Icons.check,
                                        color: theme.appColors.accent,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                        if (widget.child != null) widget.child!,
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        if (widget.onPressed != null) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: AbsorbPointer(
                              absorbing: _busy,
                              child: ElevatedButton(
                                style: widget.confirmColor == null
                                    ? null
                                    : ElevatedButton.styleFrom(
                                        backgroundColor: widget.confirmColor,
                                        foregroundColor:
                                            theme.colorScheme.onError,
                                      ),
                                onPressed: _submit,
                                child: _busy
                                    ? DesignProgress(
                                        color: theme.colorScheme.onSecondary,
                                      )
                                    : Text(widget.confirmText ?? l10n.done),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SheetAction<T> {
  const SheetAction({
    required this.value,
    required this.label,
    this.icon,
    this.selected = false,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool selected;
  final bool isDestructive;
}
