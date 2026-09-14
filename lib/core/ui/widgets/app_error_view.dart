// import 'package:flutter/material.dart';
//
// import '../../../core/error/failure.dart';
// import '../theme/app_dimensions.dart';
// import '../theme/app_spacing.dart';
// import 'app_button.dart';
//
// class AppErrorView extends StatelessWidget {
//   const AppErrorView({
//     required this.message,
//     this.icon = Icons.error_outline,
//     this.title,
//     this.onRetry,
//     this.retryLabel = 'Try again',
//     super.key,
//   });
//
//   factory AppErrorView.fromFailure(
//     Failure failure, {
//     VoidCallback? onRetry,
//     Key? key,
//   }) {
//     final (icon, title) = switch (failure) {
//       NetworkFailure() => (Icons.wifi_off_outlined, 'No connection'),
//       TimeoutFailure() => (Icons.schedule_outlined, 'This is taking a while'),
//       ServerFailure() => (Icons.cloud_off_outlined, 'Server unavailable'),
//       AuthFailure() => (Icons.lock_outline, 'Session expired'),
//       NotFoundFailure() => (Icons.search_off_outlined, 'Not found'),
//       CacheFailure() => (Icons.storage_outlined, 'Storage problem'),
//       ValidationFailure() => (Icons.rule_outlined, 'Check your details'),
//       CancelledFailure() => (Icons.cancel_outlined, 'Cancelled'),
//       BadRequestFailure() ||
//       UnknownFailure() => (Icons.error_outline, 'Something went wrong'),
//     };
//
//     return AppErrorView(
//       message: failure.message,
//       icon: icon,
//       title: title,
//       onRetry: onRetry,
//       key: key,
//     );
//   }
//
//   final String message;
//   final IconData icon;
//   final String? title;
//   final VoidCallback? onRetry;
//   final String retryLabel;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(AppSpacing.xl),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: AppDimensions.iconXl,
//               color: theme.colorScheme.outline,
//             ),
//             Gap.lg,
//             if (title != null) ...[
//               Text(
//                 title!,
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.titleMedium,
//               ),
//               Gap.sm,
//             ],
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium,
//             ),
//             if (onRetry != null) ...[
//               Gap.xl,
//               AppButton.outlined(
//                 label: retryLabel,
//                 onPressed: onRetry,
//                 icon: Icons.refresh,
//                 isExpanded: false,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
