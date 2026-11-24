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
import 'package:super_flutter/data/crops/model/crop_recommendation_model.dart';
import 'package:super_flutter/features/crops/routes/crops_route_names.dart';

import '../bloc/crop_recommendations_bloc.dart';
import '../bloc/crop_recommendations_event.dart';
import '../bloc/crop_recommendations_state.dart';

class CropRecommendationsScreen extends StatelessWidget {
  const CropRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CropRecommendationsBloc>(),
      child: const _CropRecommendationsView(),
    );
  }
}

class _CropRecommendationsView extends StatefulWidget {
  const _CropRecommendationsView();

  @override
  State<_CropRecommendationsView> createState() =>
      _CropRecommendationsViewState();
}

class _CropRecommendationsViewState extends State<_CropRecommendationsView> {
  final TextEditingController _areaController =
      TextEditingController(text: '1.0');

  @override
  void initState() {
    super.initState();
    context.read<CropRecommendationsBloc>().add(
          const RecommendationsStarted(),
        );
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppTopBar(title: l10n.cropRecommendations),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsRegular.slidersHorizontal,
                      color: DesignColor.golden,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        l10n.recommendationParameters,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<CropRecommendationsBloc, CropRecommendationsState>(
                  buildWhen: (prev, curr) =>
                      prev.optionsStatus != curr.optionsStatus ||
                      prev.districts != curr.districts ||
                      prev.crops != curr.crops ||
                      prev.months != curr.months ||
                      prev.districtId != curr.districtId ||
                      prev.cropSlug != curr.cropSlug ||
                      prev.sowingMonth != curr.sowingMonth,
                  builder: (context, state) {
                    if (state.optionsStatus == RecommendationsStatus.failure) {
                      return AppErrorView(
                        message: state.optionsError ?? l10n.errorUnknown,
                        retryLabel: l10n.tryAgain,
                        onRetry: () => context
                            .read<CropRecommendationsBloc>()
                            .add(const RecommendationsStarted()),
                      );
                    }
                    final loading =
                        state.optionsStatus != RecommendationsStatus.success;
                    if (loading && state.months.isEmpty) {
                      return const Center(child: DesignProgress());
                    }
                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey((state.districts, state.districtId)),
                          initialValue: state.districts
                                  .any((d) => d.id == state.districtId)
                              ? state.districtId
                              : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.district,
                            prefixIcon: const Icon(PhosphorIconsRegular.mapPin),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            for (final district in state.districts)
                              DropdownMenuItem(
                                value: district.id,
                                child: Text(district.name ?? '--'),
                              ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              context.read<CropRecommendationsBloc>().add(
                                    RecommendationsDistrictChanged(val),
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          key: ValueKey((state.crops, state.cropSlug)),
                          initialValue: state.cropSlug,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.productionCrop,
                            prefixIcon: const Icon(PhosphorIconsRegular.plant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: '',
                              child: Text(l10n.productionAllCrops),
                            ),
                            for (final crop in state.crops)
                              if (crop.slug?.isNotEmpty ?? false)
                                DropdownMenuItem(
                                  value: crop.slug,
                                  child: Text(crop.name ?? '--'),
                                ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              context.read<CropRecommendationsBloc>().add(
                                    RecommendationsCropChanged(val),
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<int>(
                          key: ValueKey((state.months, state.sowingMonth)),
                          initialValue: state.months
                                  .any((m) => m.number == state.sowingMonth)
                              ? state.sowingMonth
                              : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.sowingMonth,
                            prefixIcon: const Icon(PhosphorIconsRegular.calendar),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            for (final month in state.months)
                              DropdownMenuItem(
                                value: month.number,
                                child: Text(month.name ?? '--'),
                              ),
                          ],
                          onChanged: loading
                              ? null
                              : (val) {
                                  if (val != null) {
                                    context
                                        .read<CropRecommendationsBloc>()
                                        .add(RecommendationsMonthChanged(val));
                                  }
                                },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _areaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.areaHectares,
                    prefixIcon: const Icon(PhosphorIconsRegular.compass),
                    suffixText: 'ha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) {
                    final area = double.tryParse(val) ?? 1.0;
                    context.read<CropRecommendationsBloc>().add(
                          RecommendationsAreaChanged(area),
                        );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<CropRecommendationsBloc, CropRecommendationsState>(
                  builder: (context, state) {
                    final isLoading =
                        state.status == RecommendationsStatus.loading;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: DesignProgress(),
                              )
                            : const Icon(PhosphorIconsRegular.sparkle),
                        label: Text(l10n.getRecommendations),
                        onPressed: isLoading ||
                                state.optionsStatus !=
                                    RecommendationsStatus.success
                            ? null
                            : () {
                                context.read<CropRecommendationsBloc>().add(
                                      const RecommendationsSubmitted(),
                                    );
                              },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<CropRecommendationsBloc, CropRecommendationsState>(
            builder: (context, state) {
              return switch (state.status) {
                RecommendationsStatus.initial => const SizedBox.shrink(),
                RecommendationsStatus.loading => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: DesignProgress(),
                    ),
                  ),
                RecommendationsStatus.failure => AppErrorView(
                    message: state.errorMessage ?? l10n.errorUnknown,
                    retryLabel: l10n.tryAgain,
                    onRetry: () {
                      context.read<CropRecommendationsBloc>().add(
                            const RecommendationsSubmitted(),
                          );
                    },
                  ),
                RecommendationsStatus.success =>
                  state.result?.results.isEmpty ?? true
                      ? AppEmptyView(
                          title: l10n.noRecommendationsFound,
                          message: l10n.tryDifferentMonthOrDistrict,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.recommendedCropsList,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...state.result!.results.map(
                              (item) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: _RecommendationCard(item: item),
                              ),
                            ),
                          ],
                        ),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final CropRecommendationItemModel item;

  const _RecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final crop = item.crop;

    return DesignCard(
      onTap: () {
        if (crop?.slug != null && crop!.slug!.isNotEmpty) {
          context.push(CropsRouteNames.cropDetailFor(crop.slug!));
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DesignColor.golden.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${item.rank ?? 1}',
              style: const TextStyle(
                color: DesignColor.golden,
                fontWeight: FontWeight.bold,
              ),
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
                        crop?.name ?? '-',
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
                if (crop?.localName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    crop!.localName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.suitabilityScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignColor.accentPoints
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.suitabilityScore}% ${l10n.suitability}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: DesignColor.accentPoints,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (item.sowingWindow != null)
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
                          item.sowingWindow!,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ...item.notes.map((n) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                n.replaceAll('_', ' '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
