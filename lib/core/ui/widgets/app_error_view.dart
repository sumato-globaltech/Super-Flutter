import 'package:flutter/material.dart';
import 'package:starter/core/error/app_exception.dart';
import 'package:starter/core/error/exceptions/cache_exception.dart';
import 'package:starter/core/error/exceptions/unauthorized_exception.dart';
import 'package:starter/core/error/exceptions/unknown_exception.dart';
import 'package:starter/core/error/exceptions/validation_exception.dart';
import 'package:starter/core/network/network_exception_mapper.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    this.icon = Icons.error_outline,
    this.title,
    this.onRetry,
    this.retryLabel = 'Try again',
    super.key,
  });

  factory AppErrorView.fromException(
    Object error, {
    VoidCallback? onRetry,
    Key? key,
  }) {
    final exception = error is AppException
        ? error
        : UnknownException('$error');
    final (icon, title) = switch (exception) {
      NoInternetException() => (Icons.wifi_off_outlined, 'No connection'),
      RequestTimeoutException() =>
        (Icons.schedule_outlined, 'This is taking a while'),
      ServerException() => (Icons.cloud_off_outlined, 'Server unavailable'),
      UnauthorizedException() => (Icons.lock_outline, 'Session expired'),
      NotFoundException() => (Icons.search_off_outlined, 'Not found'),
      CacheException() => (Icons.storage_outlined, 'Storage problem'),
      ValidationException() => (Icons.rule_outlined, 'Check your details'),
      RequestCancelledException() => (Icons.cancel_outlined, 'Cancelled'),
      BadRequestException() ||
      NetworkException() ||
      _ => (Icons.error_outline, 'Something went wrong'),
    };

    return AppErrorView(
      message: exception.message,
      icon: icon,
      title: title,
      onRetry: onRetry,
      key: key,
    );
  }

  final String message;
  final IconData icon;
  final String? title;
  final VoidCallback? onRetry;
  final String retryLabel;

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
              color: theme.colorScheme.outline,
            ),
            Gap.lg,
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              Gap.sm,
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              Gap.xl,
              AppButton.outlined(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh,
                isExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
