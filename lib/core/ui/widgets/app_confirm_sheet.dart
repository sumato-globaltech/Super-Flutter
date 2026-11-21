import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_spacing.dart';

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

class AppConfirmSheet<T> extends StatefulWidget {
  const AppConfirmSheet({
    required this.title,
    this.message,
    this.icon,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    this.isDismissible = true,
    this.onConfirm,
    this.actions = const [],
    this.child,
    super.key,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool isDestructive;
  final bool isDismissible;
  final Future<void> Function()? onConfirm;
  final List<SheetAction<T>> actions;
  final Widget? child;

  bool get _draggable => isDismissible && onConfirm == null;

  static Future<T?> show<T>(BuildContext context, AppConfirmSheet<T> sheet) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: sheet._draggable,
      isDismissible: sheet.isDismissible,
      enableDrag: sheet._draggable,
      builder: (_) => sheet,
    );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    IconData? icon,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    Future<void> Function()? onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await show<bool>(
      context,
      AppConfirmSheet<bool>(
        title: title,
        message: message,
        icon: icon,
        confirmLabel: confirmLabel ?? l10n.confirm,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
      ),
    );
    return confirmed ?? false;
  }

  static Future<T?> choose<T>(
    BuildContext context, {
    required String title,
    required List<SheetAction<T>> actions,
    String? message,
    IconData? icon,
  }) {
    return show<T>(
      context,
      AppConfirmSheet<T>(
        title: title,
        message: message,
        icon: icon,
        actions: actions,
      ),
    );
  }

  @override
  State<AppConfirmSheet<T>> createState() => _AppConfirmSheetState<T>();
}

class _AppConfirmSheetState<T> extends State<AppConfirmSheet<T>> {
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    assert(
      widget.confirmLabel == null || true is T,
      'Confirm and cancel pop a bool; use AppConfirmSheet<bool>.',
    );
  }

  Future<void> _confirm() async {
    final navigator = Navigator.of(context);
    final onConfirm = widget.onConfirm;
    if (onConfirm == null) {
      navigator.pop(true);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await onConfirm();
      if (mounted) navigator.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error is AppException ? error.message : l10n.errorUnknown;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = widget.isDestructive ? colors.error : colors.primary;
    final confirmLabel = widget.confirmLabel;

    return PopScope(
      canPop: widget.isDismissible && !_busy,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            widget._draggable ? 0 : AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.icon != null) ...[
                Center(
                  child: Container(
                    width: AppDimensions.avatarMd + AppSpacing.sm,
                    height: AppDimensions.avatarMd + AppSpacing.sm,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: AppDimensions.iconLg - AppSpacing.xs,
                      color: accent,
                    ),
                  ),
                ),
                Gap.lg,
              ],
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              if (widget.message case final message?
                  when message.isNotEmpty) ...[
                Gap.sm,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.appColors.textSecondary,
                  ),
                ),
              ],
              if (widget.child case final child?) ...[Gap.lg, child],
              if (widget.actions.isNotEmpty) ...[
                Gap.md,
                for (final action in widget.actions)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                    selected: action.selected,
                    textColor: action.isDestructive ? colors.error : null,
                    iconColor: action.isDestructive ? colors.error : null,
                    leading: action.icon == null ? null : Icon(action.icon),
                    title: Text(action.label),
                    trailing: action.selected
                        ? Icon(Icons.check, color: colors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(action.value),
                  ),
              ],
              if (_error case final error?) ...[
                Gap.md,
                Semantics(
                  liveRegion: true,
                  child: Text(
                    error,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              ],
              if (confirmLabel != null) ...[
                Gap.xl,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(widget.cancelLabel ?? l10n.cancel),
                      ),
                    ),
                    Gap.md,
                    Expanded(
                      child: FilledButton(
                        style: widget.isDestructive
                            ? FilledButton.styleFrom(
                                backgroundColor: colors.error,
                                foregroundColor: colors.onError,
                              )
                            : null,
                        onPressed: _busy ? null : _confirm,
                        child: _busy
                            ? SizedBox.square(
                                dimension: AppDimensions.iconSm,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: widget.isDestructive
                                      ? colors.onError
                                      : colors.onPrimary,
                                ),
                              )
                            : Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
