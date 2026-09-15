import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter/core/localization/app_localizations.dart';
import 'package:starter/core/ui/layouts/app_scaffold.dart';
import 'package:starter/core/ui/widgets/app_button.dart';
import 'package:starter/features/auth/presentation/bloc/auth_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.home,
      actions: [
        IconButton(
          tooltip: l10n.signOut,
          icon: const Icon(Icons.logout_outlined),
          onPressed: () => context.read<AuthCubit>().logout(),
        ),
      ],
      body: Center(
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
              onPressed: () => context.read<AuthCubit>().logout(),
            ),
          ],
        ),
      ),
    );
  }
}
