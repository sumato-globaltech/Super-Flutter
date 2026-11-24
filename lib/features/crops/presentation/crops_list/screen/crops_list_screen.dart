import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/features/crops/routes/crops_route_names.dart';

import '../bloc/crops_list_bloc.dart';
import '../bloc/crops_list_event.dart';
import '../bloc/crops_list_state.dart';

class CropsListScreen extends StatelessWidget {
  const CropsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CropsListBloc>()..add(const CropsListStarted()),
      child: const _CropsListView(),
    );
  }
}

class _CropsListView extends StatefulWidget {
  const _CropsListView();

  @override
  State<_CropsListView> createState() => _CropsListViewState();
}

class _CropsListViewState extends State<_CropsListView> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _cropTypes = [
    'food-grains',
    'oilseeds',
    'pulses',
    'commercial',
    'spices',
    'horticulture',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppTopBar(title: l10n.crops),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchCrops,
                prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(PhosphorIconsRegular.xCircle),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CropsListBloc>().add(
                            const CropsListSearchChanged(''),
                          );
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                context.read<CropsListBloc>().add(CropsListSearchChanged(val));
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: BlocBuilder<CropsListBloc, CropsListState>(
              builder: (context, state) {
                return Row(
                  children: [
                    FilterChip(
                      selected: state.selectedType == null,
                      label: Text(
                        l10n.all,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      onSelected: (_) {
                        context.read<CropsListBloc>().add(
                          const CropsListTypeSelected(null),
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ..._cropTypes.map((type) {
                      final isSelected = state.selectedType == type;
                      final label = type
                          .replaceAll('-', ' ')
                          .replaceFirst(type[0], type[0].toUpperCase());
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(label),
                          onSelected: (_) {
                            context.read<CropsListBloc>().add(
                              CropsListTypeSelected(isSelected ? null : type),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: DesignCard(
              onTap: () => context.push(CropsRouteNames.recommendations),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DesignColor.accentPoints.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.sparkle,
                      color: DesignColor.accentPoints,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.cropRecommendations,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.cropRecommendationsSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    PhosphorIconsRegular.caretRight,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<CropsListBloc, CropsListState>(
              builder: (context, state) {
                final bloc = context.read<CropsListBloc>();
                return switch (state.status) {
                  CropsListStatus.initial || CropsListStatus.loading
                      when state.items.isEmpty =>
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: DesignProgress(),
                      ),
                    ),
                  CropsListStatus.failure when state.items.isEmpty =>
                    AppErrorView(
                      message: state.errorMessage ?? l10n.errorUnknown,
                      retryLabel: l10n.tryAgain,
                      onRetry: () => bloc.add(const CropsListStarted()),
                    ),
                  _ when state.items.isEmpty => AppEmptyView(
                    title: l10n.noCropsFound,
                    message: l10n.tryAdjustingFilters,
                  ),
                  _ => RefreshIndicator(
                    onRefresh: () async {
                      bloc.add(const CropsListRefreshed());
                    },
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.extentAfter < 300) {
                          bloc.add(const CropsListMoreRequested());
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
                          final crop = state.items[index];
                          return _CropCard(
                            crop: crop,
                            onTap: () {
                              if (crop.slug != null && crop.slug!.isNotEmpty) {
                                context.push(
                                  CropsRouteNames.cropDetailFor(crop.slug!),
                                );
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

class _CropCard extends StatelessWidget {
  final CropModel crop;
  final VoidCallback onTap;

  const _CropCard({required this.crop, required this.onTap});

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
              color: DesignColor.accentPoints.withValues(alpha: 0.12),
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
                        crop.name ?? '-',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
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
                if (crop.scientificName != null &&
                    crop.scientificName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    crop.scientificName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ] else if (crop.localName != null &&
                    crop.localName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    crop.localName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (crop.type?.name != null)
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
                          crop.type!.name!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (crop.durationDays != null)
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
                              PhosphorIconsRegular.clock,
                              size: 12,
                              color: DesignColor.accentName,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.cropDurationDays(crop.durationDays!),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: DesignColor.accentName,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
