import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { filled, tonal, outlined, text, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.isCompact = false,
    super.key,
  });

  const AppButton.outlined({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = true,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         variant: AppButtonVariant.outlined,
         icon: icon,
         isLoading: isLoading,
         isExpanded: isExpanded,
         key: key,
       );

  const AppButton.text({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         variant: AppButtonVariant.text,
         icon: icon,
         isExpanded: false,
         key: key,
       );

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  final bool isLoading;

  final bool isExpanded;

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveOnPressed = isLoading ? null : onPressed;

    final child = isLoading
        ? const _ButtonSpinner()
        : _ButtonContent(label: label, icon: icon);

    final minimumSize = Size(
      isExpanded ? double.infinity : 0,
      isCompact ? AppDimensions.buttonHeightSmall : AppDimensions.buttonHeight,
    );

    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(minimumSize: minimumSize),
        child: child,
      ),
      AppButtonVariant.tonal => FilledButton.tonal(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(minimumSize: minimumSize),
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(minimumSize: minimumSize),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(minimumSize: minimumSize),
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          minimumSize: minimumSize,
          backgroundColor: colors.errorContainer,
          foregroundColor: colors.onErrorContainer,
        ),
        child: child,
      ),
    };

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: label,
      child: button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSm),
        Gap.sm,
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: AppDimensions.iconSm,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
