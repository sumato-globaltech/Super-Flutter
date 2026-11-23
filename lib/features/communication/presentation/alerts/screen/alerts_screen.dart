import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';

import '../bloc/alerts_bloc.dart';
import '../bloc/alerts_event.dart';
import '../bloc/alerts_state.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AlertsBloc>()..add(const AlertsStarted()),
      child: const _AlertsView(),
    );
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.alertsTitle),
      body: BlocBuilder<AlertsBloc, AlertsState>(
        builder: (context, state) {
          final bloc = context.read<AlertsBloc>();
          return switch (state.status) {
            AlertsStatus.initial ||
            AlertsStatus.loading when state.items.isEmpty =>
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: DesignProgress(),
                ),
              ),
            AlertsStatus.failure when state.items.isEmpty => AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => bloc.add(const AlertsStarted()),
            ),
            AlertsStatus.loaded when state.items.isEmpty => RefreshIndicator(
              onRefresh: () async {
                bloc.add(const AlertsStarted());
                await bloc.stream.firstWhere(
                  (s) =>
                      s.status != AlertsStatus.loading &&
                      s.status != AlertsStatus.initial,
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 320,
                  child: AppEmptyView(
                    title: l10n.alertsEmpty,
                    message: l10n.alertsEmptyMessage,
                    icon: PhosphorIconsRegular.warning,
                  ),
                ),
              ),
            ),
            _ => _buildList(context, state),
          };
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, AlertsState state) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<AlertsBloc>();
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (state.hasMore &&
            !state.loadingMore &&
            metrics.pixels > metrics.maxScrollExtent * 0.8) {
          bloc.add(const AlertsMoreRequested());
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          bloc.add(const AlertsStarted());
          await bloc.stream.firstWhere(
            (s) =>
                s.status != AlertsStatus.loading &&
                s.status != AlertsStatus.initial,
          );
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding.copyWith(bottom: 0),
          itemCount: state.items.length + (state.hasMore || state.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              // Footer: loading more or retry.
              if (state.loadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: DesignProgress()),
                );
              }
              if (state.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: TextButton(
                      onPressed: () => bloc.add(const AlertsMoreRequested()),
                      child: Text(l10n.tryAgain),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            final alert = state.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DesignCard(
                paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TitleDetailsCard(
                      title: [
                        alert.severity?.label,
                        (alert.statewide ?? false)
                            ? l10n.homeStatewide
                            : alert.district?.name,
                      ].whereType<String>().join(' · '),
                      text: alert.title ?? '-',
                      isFirstItem: true,
                      iconData: switch (alert.severity?.value) {
                        'emergency' => PhosphorIconsRegular.siren,
                        'warning' => PhosphorIconsRegular.warning,
                        'watch' => PhosphorIconsRegular.eye,
                        _ => PhosphorIconsRegular.info,
                      },
                      accentColor: switch (alert.severity?.value) {
                        'emergency' => Theme.of(context).colorScheme.error,
                        'warning' => DesignColor.orange,
                        'watch' => DesignColor.golden,
                        _ => DesignColor.skyBlue,
                      },
                    ),
                    if (alert.description case final description?
                        when description.isNotEmpty)
                      TitleDetailsCard(
                        title: alert.category?.name ?? '',
                        text: description,
                        isReadMore: true,
                        iconData: PhosphorIconsRegular.note,
                        accentColor: DesignColor.accentEnergy,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
