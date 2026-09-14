import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconXl,
              color: theme.colorScheme.outlineVariant,
            ),
            Gap.lg,
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (message != null) ...[
              Gap.sm,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              Gap.xl,
              AppButton.outlined(
                label: actionLabel!,
                onPressed: onAction,
                isExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
