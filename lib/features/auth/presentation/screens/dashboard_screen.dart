import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter/core/di/injection.dart';
import 'package:starter/core/localization/app_localizations.dart';
import 'package:starter/core/ui/layouts/app_scaffold.dart';
import 'package:starter/core/ui/widgets/app_button.dart';
import 'package:starter/features/auth/presentation/bloc/logout_cubit.dart';
import 'package:starter/features/auth/presentation/bloc/logout_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LogoutCubit>(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.home,
      actions: [
        BlocBuilder<LogoutCubit, LogoutState>(
          builder: (context, state) {
            return IconButton(
              tooltip: l10n.signOut,
              icon: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_outlined),
              onPressed: state.isSubmitting
                  ? null
                  : () => context.read<LogoutCubit>().submit(),
            );
          },
        ),
      ],
      body: BlocBuilder<LogoutCubit, LogoutState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.home,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInToContinue,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton.outlined(
                  label: l10n.signOut,
                  icon: Icons.logout_outlined,
                  isExpanded: false,
                  isLoading: state.isSubmitting,
                  onPressed: state.isSubmitting
                      ? null
                      : () => context.read<LogoutCubit>().submit(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
