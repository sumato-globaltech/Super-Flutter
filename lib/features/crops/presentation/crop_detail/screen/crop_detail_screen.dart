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
import 'package:super_flutter/data/crops/model/crop_advisory_model.dart';
import 'package:super_flutter/data/crops/model/crop_calendar_model.dart';
import 'package:super_flutter/data/crops/model/crop_fertilizers_model.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/market/model/market_price_model.dart';

import '../bloc/crop_detail_bloc.dart';
import '../bloc/crop_detail_event.dart';
import '../bloc/crop_detail_state.dart';

class CropDetailScreen extends StatelessWidget {
  final String cropSlug;

  const CropDetailScreen({super.key, required this.cropSlug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CropDetailBloc>()..add(CropDetailStarted(cropSlug)),
      child: const _CropDetailView(),
    );
  }
}

class _CropDetailView extends StatelessWidget {
  const _CropDetailView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<CropDetailBloc, CropDetailState>(
      builder: (context, state) {
        final crop = state.crop ?? state.advisory?.crop;
        final title = crop?.name ?? l10n.cropDetails;
        final bloc = context.read<CropDetailBloc>();

        return Scaffold(
          appBar: AppTopBar(title: title),
          body: switch (state.status) {
            CropDetailStatus.initial ||
            CropDetailStatus.loading => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: DesignProgress(),
              ),
            ),
            CropDetailStatus.failure => AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => bloc.add(CropDetailStarted(state.slug)),
            ),
            CropDetailStatus.success => RefreshIndicator(
              onRefresh: () async {
                bloc.add(const CropDetailRefreshed());
              },
              child: DefaultTabController(
                length: 5,
                initialIndex: state.selectedTab,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: _OverviewHeaderCard(crop: crop),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarHeaderDelegate(
                        TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: theme
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                          indicatorColor: theme.colorScheme.primary,
                          tabs: [
                            Tab(text: l10n.cropAdvisory),
                            Tab(text: l10n.cropFertilizers),
                            Tab(text: l10n.cropCalendar),
                            Tab(text: l10n.cropVarieties),
                            Tab(text: l10n.cropPrices),
                          ],
                          onTap: (index) {
                            bloc.add(CropDetailTabChanged(index));
                          },
                        ),
                        theme.colorScheme.surface,
                      ),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      _AdvisoryTabView(advisory: state.advisory),
                      _FertilizersTabView(
                        fertilizers:
                            state.fertilizers ??
                            (state.advisory?.fertilizers != null
                                ? CropFertilizersModel(
                                    fertilizers: state.advisory!.fertilizers!,
                                  )
                                : null),
                      ),
                      _CalendarTabView(
                        advisory: state.advisory,
                        calendar: state.calendar,
                      ),
                      _VarietiesTabView(
                        varieties:
                            crop?.varieties ??
                            state.advisory?.varieties ??
                            const [],
                      ),
                      _PricesTabView(
                        prices: state.prices,
                        loadingMore: state.loadingMorePrices,
                        hasMore: state.pricesHasMore,
                        onLoadMore: () {
                          bloc.add(const CropDetailPricesMoreRequested());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          },
        );
      },
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarHeaderDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarHeaderDelegate oldDelegate) => false;
}

class _OverviewHeaderCard extends StatelessWidget {
  final CropModel? crop;

  const _OverviewHeaderCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (crop == null) return const SizedBox.shrink();

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: DesignColor.accentPoints.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  PhosphorIconsRegular.plant,
                  color: DesignColor.accentPoints,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop!.name ?? '-',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (crop!.scientificName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        crop!.scientificName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                    if (crop!.localName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.localName}: ${crop!.localName!}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (crop!.type?.name != null)
                Chip(
                  label: Text(crop!.type!.name!),
                  avatar: const Icon(PhosphorIconsRegular.tag, size: 14),
                ),
              if (crop!.durationDays != null)
                Chip(
                  label: Text(l10n.cropDurationDays(crop!.durationDays!)),
                  avatar: const Icon(PhosphorIconsRegular.clock, size: 14),
                ),
              if (crop!.defaultUnit?.name != null)
                Chip(
                  label: Text(crop!.defaultUnit!.name!),
                  avatar: const Icon(PhosphorIconsRegular.scales, size: 14),
                ),
            ],
          ),
          if (crop!.summary != null && crop!.summary!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              crop!.summary!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdvisoryTabView extends StatelessWidget {
  final CropAdvisoryModel? advisory;

  const _AdvisoryTabView({required this.advisory});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (advisory == null) {
      return AppEmptyView(
        title: l10n.noAdvisoryAvailable,
        message: l10n.noAdvisorySubtitle,
      );
    }

    final profile = advisory!.profile;
    final climate = profile?.climate;
    final soil = profile?.soil;
    final sowing = profile?.sowing;
    final practices = profile?.fieldPractices;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (advisory!.month != null || advisory!.windows != null)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TitleDetailsCard(
                      title: l10n.advisorySeason,
                      text: advisory!.month?.name ?? '-',
                      isFirstItem: true,
                      iconData: PhosphorIconsRegular.calendarCheck,
                      accentColor: DesignColor.accentPoints,
                    ),
                  ],
                ),
                TitleDetailsCard(
                  title: l10n.sowingWindow,
                  text: advisory?.windows?.sowing ?? '--',
                  iconData: PhosphorIconsRegular.plant,
                  accentColor: DesignColor.accentPoints,
                ),
                if (advisory!.windows?.harvest != null)
                  TitleDetailsCard(
                    title: l10n.harvestWindow,
                    text: advisory!.windows!.harvest!,
                    iconData: PhosphorIconsRegular.scissors,
                    accentColor: DesignColor.accentEnergy,
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (climate != null)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleDetailsCard(
                  title: l10n.temperatureRange,
                  text:
                      '${climate.tempMinC ?? '-'}°C - ${climate.tempMaxC ?? '-'}°C',
                  isFirstItem: true,
                  iconData: PhosphorIconsRegular.thermometer,
                  accentColor: DesignColor.accentEnergy,
                ),
                TitleDetailsCard(
                  title: l10n.rainfallRequirement,
                  text:
                      '${climate.rainMinMm ?? '-'} mm - ${climate.rainMaxMm ?? '-'} mm',
                  iconData: PhosphorIconsRegular.cloudRain,
                  accentColor: DesignColor.accentName,
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (soil != null)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (soil.types.isNotEmpty)
                  TitleDetailsCard(
                    title: l10n.soilTypes,
                    text: soil.types.join(', '),
                    isFirstItem: true,
                    iconData: PhosphorIconsRegular.mountains,
                    accentColor: DesignColor.accentLocation,
                  ),
                TitleDetailsCard(
                  title: l10n.soilPh,
                  text: '${soil.phMin ?? '-'} - ${soil.phMax ?? '-'}',
                  iconData: PhosphorIconsRegular.drop,
                  accentColor: DesignColor.accentName,
                ),
                if (soil.drainage != null)
                  TitleDetailsCard(
                    title: l10n.soilDrainage,
                    text: soil.drainage!,
                    iconData: PhosphorIconsRegular.waves,
                    accentColor: DesignColor.accentType,
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (sowing != null)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sowing.method != null)
                  TitleDetailsCard(
                    title: l10n.sowingMethod,
                    text: sowing.method!,
                    isFirstItem: true,
                    iconData: PhosphorIconsRegular.plant,
                    accentColor: DesignColor.accentPoints,
                  ),
                if (sowing.seedRateKgHa != null)
                  TitleDetailsCard(
                    title: l10n.seedRate,
                    text: '${sowing.seedRateKgHa} kg/ha',
                    iconData: PhosphorIconsRegular.scales,
                    accentColor: DesignColor.accentUin,
                  ),
                if (sowing.spacing != null)
                  TitleDetailsCard(
                    title: l10n.plantSpacing,
                    text: sowing.spacing!,
                    iconData: PhosphorIconsRegular.arrowsHorizontal,
                    accentColor: DesignColor.accentName,
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (practices != null)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (practices.landPreparation != null)
                  TitleDetailsCard(
                    title: l10n.landPreparation,
                    text: practices.landPreparation!,
                    isFirstItem: true,
                    isReadMore: true,
                    iconData: PhosphorIconsRegular.tractor,
                    accentColor: DesignColor.golden,
                  ),
                if (practices.weedManagement != null)
                  TitleDetailsCard(
                    title: l10n.weedManagement,
                    text: practices.weedManagement!,
                    isReadMore: true,
                    iconData: PhosphorIconsRegular.shieldCheck,
                    accentColor: DesignColor.accentPoints,
                  ),
              ],
            ),
          ),
        if (advisory!.practices != null && advisory!.practices!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          ...advisory!.practices!.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: DesignCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.label ?? l10n.advisoryPractice,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...p.steps.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.xs,
                          top: 2,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(s)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FertilizersTabView extends StatelessWidget {
  final CropFertilizersModel? fertilizers;

  const _FertilizersTabView({required this.fertilizers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (fertilizers == null || fertilizers!.fertilizers.isEmpty) {
      return AppEmptyView(
        title: l10n.noFertilizersAvailable,
        message: l10n.noFertilizersSubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: fertilizers!.fertilizers.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final group = fertilizers!.fertilizers[index];
        return DesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.label ?? l10n.fertilizerGroup,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...group.items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TitleDetailsCard(
                    title: item.fertilizer ?? '-',
                    text: [
                      if (item.composition != null) 'Comp: ${item.composition}',
                      if (item.dosage != null) 'Dosage: ${item.dosage}',
                      if (item.stage != null) 'Stage: ${item.stage}',
                    ].join(' · '),
                    isFirstItem: idx == 0,
                    iconData: PhosphorIconsRegular.flask,
                    accentColor: DesignColor.accentName,
                    isReadMore: item.notes != null && item.notes!.isNotEmpty,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarTabView extends StatelessWidget {
  final CropAdvisoryModel? advisory;
  final CropCalendarModel? calendar;

  const _CalendarTabView({required this.advisory, required this.calendar});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final windows = calendar?.windows ?? advisory?.windows;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (windows != null)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (windows.sowing != null)
                  TitleDetailsCard(
                    title: l10n.sowingWindow,
                    text: windows.sowing!,
                    isFirstItem: true,
                    iconData: PhosphorIconsRegular.plant,
                    accentColor: DesignColor.accentPoints,
                  ),
                if (windows.harvest != null)
                  TitleDetailsCard(
                    title: l10n.harvestWindow,
                    text: windows.harvest!,
                    iconData: PhosphorIconsRegular.scissors,
                    accentColor: DesignColor.golden,
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        DesignCard(
          child: TitleDetailsCard(
            title: l10n.cropCalendarSchedule,
            text: l10n.cropCalendarActiveMessage,
            isFirstItem: true,
            iconData: PhosphorIconsRegular.calendar,
            accentColor: DesignColor.accentUin,
          ),
        ),
      ],
    );
  }
}

class _VarietiesTabView extends StatelessWidget {
  final List<dynamic> varieties;

  const _VarietiesTabView({required this.varieties});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (varieties.isEmpty) {
      return AppEmptyView(
        title: l10n.noVarietiesFound,
        message: l10n.noVarietiesSubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: varieties.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = varieties[index];
        final name = item is CropVarietyModel
            ? item.name
            : (item is Map ? item['name']?.toString() : null);
        final duration = item is CropVarietyModel
            ? item.durationDays
            : (item is Map ? item['duration_days'] : null);
        final yieldPerHa = item is CropVarietyModel
            ? item.yieldPerHa
            : (item is Map ? item['yield_per_ha'] : null);

        return DesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleDetailsCard(
                title: l10n.varietyName,
                text: name ?? '-',
                isFirstItem: true,
                iconData: PhosphorIconsRegular.plant,
                accentColor: DesignColor.accentPoints,
              ),
              if (duration != null)
                TitleDetailsCard(
                  title: l10n.duration,
                  text: l10n.cropDurationDays(int.parse('$duration')),
                  iconData: PhosphorIconsRegular.clock,
                  accentColor: DesignColor.accentName,
                ),
              if (yieldPerHa != null)
                TitleDetailsCard(
                  title: l10n.expectedYield,
                  text: '$yieldPerHa',
                  iconData: PhosphorIconsRegular.scales,
                  accentColor: DesignColor.golden,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PricesTabView extends StatelessWidget {
  final List<MarketPriceModel> prices;
  final bool loadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _PricesTabView({
    required this.prices,
    required this.loadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (prices.isEmpty) {
      return AppEmptyView(
        title: l10n.noPricesReported,
        message: l10n.noPricesReportedSubtitle,
      );
    }

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 300 && hasMore && !loadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: prices.length + (loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= prices.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: DesignProgress(),
              ),
            );
          }
          final price = prices[index];
          final marketName = price.market?.name ?? l10n.market;
          final unitName = price.unit?.name ?? '';
          final modal = price.modalPrice != null
              ? '₹${price.modalPrice} ${unitName.isNotEmpty ? '/ $unitName' : ''}'
              : '-';

          return DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleDetailsCard(
                  title: marketName,
                  text: modal,
                  isFirstItem: true,
                  iconData: PhosphorIconsRegular.storefront,
                  accentColor: DesignColor.accentPoints,
                ),
                if (price.priceDate != null)
                  TitleDetailsCard(
                    title: l10n.reportingDate,
                    text: price.priceDate!,
                    iconData: PhosphorIconsRegular.calendar,
                    accentColor: DesignColor.accentName,
                  ),
                if (price.minPrice != null && price.maxPrice != null)
                  TitleDetailsCard(
                    title: l10n.priceRange,
                    text: '₹${price.minPrice} - ₹${price.maxPrice}',
                    iconData: PhosphorIconsRegular.arrowsHorizontal,
                    accentColor: DesignColor.accentEnergy,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
