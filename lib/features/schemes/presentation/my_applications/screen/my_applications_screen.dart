import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/features/schemes/presentation/my_applications/bloc/my_applications_bloc.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyApplicationsBloc(),
      child: const _MyApplicationsView(),
    );
  }
}

class _MyApplicationsView extends StatelessWidget {
  const _MyApplicationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.schemesMyApplicationsTitle),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.pagePadding.copyWith(bottom: 0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}
