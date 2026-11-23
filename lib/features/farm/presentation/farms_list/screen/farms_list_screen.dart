import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
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
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/features/farm/routes/farm_route_names.dart';

import '../bloc/farms_bloc.dart';
import '../bloc/farms_event.dart';
import '../bloc/farms_state.dart';

class FarmsListScreen extends StatelessWidget {
  const FarmsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FarmsBloc>()..add(const FarmsStarted()),
      child: const _FarmsListView(),
    );
  }
}

class _FarmsListView extends StatelessWidget {
  const _FarmsListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppTopBar(title: l10n.farms),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await context.push<bool>(FarmRouteNames.addFarm);
          if (created == true && context.mounted) {
            context.read<FarmsBloc>().add(const FarmsRefreshed());
          }
        },
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: BlocBuilder<FarmsBloc, FarmsState>(
              builder: (context, state) {
                return SegmentedButton<String>(
                  segments: [
                    ButtonSegment<String>(
                      value: 'active',
                      label: Text(l10n.activeFarms),
                      icon: const Icon(PhosphorIconsRegular.checkCircle),
                    ),
                    ButtonSegment<String>(
                      value: 'archived',
                      label: Text(l10n.archivedFarms),
                      icon: const Icon(PhosphorIconsRegular.archive),
                    ),
                  ],
                  selected: {state.statusFilter},
                  onSelectionChanged: (selected) {
                    context.read<FarmsBloc>().add(
                      FarmsStatusFilterChanged(selected.first),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<FarmsBloc, FarmsState>(
              builder: (context, state) {
                final bloc = context.read<FarmsBloc>();
                return switch (state.status) {
                  FarmsListStatus.initial || FarmsListStatus.loading
                      when state.items.isEmpty =>
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: DesignProgress(),
                      ),
                    ),
                  FarmsListStatus.failure when state.items.isEmpty =>
                    AppErrorView(
                      message: state.errorMessage ?? l10n.errorUnknown,
                      retryLabel: l10n.tryAgain,
                      onRetry: () => bloc.add(const FarmsStarted()),
                    ),
                  _ when state.items.isEmpty => AppEmptyView(
                    title: state.statusFilter == 'active'
                        ? l10n.noFarmsFound
                        : l10n.noArchivedFarmsFound,
                    message: l10n.addFarmPrompt,
                  ),
                  _ => RefreshIndicator(
                    onRefresh: () async {
                      bloc.add(const FarmsRefreshed());
                    },
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.extentAfter < 300) {
                          bloc.add(const FarmsMoreRequested());
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount:
                            state.items.length + (state.loadingMore ? 1 : 0),
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          if (index >= state.items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: DesignProgress(),
                              ),
                            );
                          }
                          final farm = state.items[index];
                          return _FarmCard(
                            farm: farm,
                            onTap: () async {
                              if (farm.id != null) {
                                await context.push(
                                  FarmRouteNames.farmDetailFor(farm.id!),
                                );
                                if (context.mounted) {
                                  bloc.add(const FarmsRefreshed());
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  final FarmModel farm;
  final VoidCallback onTap;

  const _FarmCard({required this.farm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return DesignCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DesignColor.accentPoints.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              PhosphorIconsRegular.plant,
              color: DesignColor.accentPoints,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        farm.name ?? '-',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
                if (farm.district?.name != null || farm.village != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIconsRegular.mapPin,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            if (farm.village != null) farm.village,
                            if (farm.district?.name != null)
                              farm.district!.name,
                          ].join(', '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (farm.areaHa != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignColor.accentName.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              PhosphorIconsRegular.compass,
                              size: 12,
                              color: DesignColor.accentName,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${farm.areaHa} ha',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: DesignColor.accentName,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (farm.code != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          farm.code!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    if (!farm.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignColor.golden.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.archived,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: DesignColor.golden,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
