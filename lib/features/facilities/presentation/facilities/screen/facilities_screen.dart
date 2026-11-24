import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/facilities/presentation/facilities/bloc/facilities_bloc.dart';
import 'package:super_flutter/features/facilities/presentation/facilities/bloc/facilities_event.dart';
import 'package:super_flutter/features/facilities/presentation/facilities/bloc/facilities_state.dart';
import 'package:super_flutter/features/facilities/routes/facilities_route_names.dart';

class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FacilitiesBloc>()..add(const FacilitiesStarted()),
      child: const _FacilitiesView(),
    );
  }
}

class _FacilitiesView extends StatelessWidget {
  const _FacilitiesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = NumberFormat('#,##0.##');
    return Scaffold(
      appBar: AppTopBar(
        title: l10n.facilitiesTitle,
        actions: [
          IconButton(
            tooltip: l10n.facilitiesFacilityStatsTitle,
            icon: const Icon(PhosphorIconsRegular.chartBar),
            onPressed: () => context.push(FacilitiesRouteNames.facilityStats),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: AppSpacing.sm),
              child: BlocBuilder<FacilitiesBloc, FacilitiesState>(
                buildWhen: (prev, curr) =>
                    prev.filter != curr.filter ||
                    prev.categories != curr.categories ||
                    prev.districts != curr.districts,
                builder: (context, state) => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        key: ValueKey(('category', state.categories.length)),
                        initialValue: state.filter.category,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.facilitiesType,
                        ),
                        items: [
                          DropdownMenuItem(
                            child: Text(l10n.facilitiesAllTypes),
                          ),
                          for (final option in state.categories)
                            DropdownMenuItem(
                              value: option.id,
                              child: Text(
                                option.name ?? '--',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            context.read<FacilitiesBloc>().add(
                              FacilitiesStarted(
                                filter: (
                                  category: value,
                                  district: state.filter.district,
                                ),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        key: ValueKey(('district', state.districts.length)),
                        initialValue: state.filter.district,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l10n.district),
                        items: [
                          DropdownMenuItem(
                            child: Text(l10n.facilitiesAllDistricts),
                          ),
                          for (final option in state.districts)
                            DropdownMenuItem(
                              value: option.id,
                              child: Text(
                                option.name ?? '--',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            context.read<FacilitiesBloc>().add(
                              FacilitiesStarted(
                                filter: (
                                  category: state.filter.category,
                                  district: value,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocConsumer<FacilitiesBloc, FacilitiesState>(
                listenWhen: (prev, curr) =>
                    prev.status != curr.status &&
                    curr.status == FacilitiesStatus.failure &&
                    curr.facilities != null,
                listener: (context, state) => context.showSnackBar(
                  state.errorMessage ?? l10n.errorUnknown,
                  isError: true,
                ),
                builder: (context, state) {
                  final facilities = state.facilities;
                  if (facilities == null) {
                    if (state.status == FacilitiesStatus.failure) {
                      return AppErrorView(
                        message: state.errorMessage ?? l10n.errorUnknown,
                        retryLabel: l10n.tryAgain,
                        onRetry: () => context.read<FacilitiesBloc>().add(
                          const FacilitiesStarted(),
                        ),
                      );
                    }
                    return const Center(child: DesignProgress());
                  }
                  // The next page, unless one is loading or the last one failed.
                  // The bloc's own state is read: several asks can come in a frame.
                  void loadMore() {
                    final bloc = context.read<FacilitiesBloc>();
                    final now = bloc.state;
                    if ((now.facilities?.hasMore ?? false) &&
                        !now.loadingMore &&
                        now.status == FacilitiesStatus.success) {
                      bloc.add(const FacilitiesMoreRequested());
                    }
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final bloc = context.read<FacilitiesBloc>()
                        ..add(const FacilitiesStarted());
                      await bloc.stream.firstWhere(
                        (state) => state.status != FacilitiesStatus.loading,
                      );
                    },
                    child: facilities.items.isEmpty
                        ? CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: AppEmptyView(
                                  title: l10n.facilitiesEmpty,
                                  icon: PhosphorIconsRegular.tray,
                                ),
                              ),
                            ],
                          )
                        : NotificationListener<ScrollUpdateNotification>(
                            // Past 80% of the list, the next page is asked for.
                            onNotification: (notification) {
                              final metrics = notification.metrics;
                              if (metrics.axis == Axis.vertical &&
                                  metrics.pixels >=
                                      metrics.maxScrollExtent * 0.8) {
                                loadMore();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: AppSpacing.pagePadding.copyWith(
                                bottom: 0,
                              ),
                              itemCount:
                                  facilities.items.length +
                                  (facilities.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == facilities.items.length) {
                                  final failed =
                                      state.status ==
                                          FacilitiesStatus.failure &&
                                      !state.loadingMore;
                                  if (!failed) {
                                    // A list too short to scroll asks once its end is in view.
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (context.mounted) loadMore();
                                        });
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Center(
                                      child: failed
                                          ? TextButton(
                                              onPressed: () => context
                                                  .read<FacilitiesBloc>()
                                                  .add(
                                                    const FacilitiesMoreRequested(),
                                                  ),
                                              child: Text(l10n.tryAgain),
                                            )
                                          : const DesignProgress(),
                                    ),
                                  );
                                }
                                final facility = facilities.items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: DesignCard(
                                    paddingChild: const EdgeInsets.fromLTRB(
                                      14,
                                      14,
                                      14,
                                      16,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TitleDetailsCard(
                                          title:
                                              facility.category?.name ?? '--',
                                          text: facility.name ?? '--',
                                          isFirstItem: true,
                                          iconData:
                                              PhosphorIconsRegular.warehouse,
                                          accentColor: DesignColor.accentName,
                                        ),
                                        TitleDetailsCard(
                                          title: l10n.facilitiesAddress,
                                          text: [
                                            ?facility.address,
                                            ?facility.district?.name,
                                          ].join(', '),
                                          iconData: PhosphorIconsRegular.mapPin,
                                          accentColor:
                                              DesignColor.accentLocation,
                                          onTap:
                                              facility.latitude == null ||
                                                  facility.longitude == null
                                              ? null
                                              : () =>
                                                    Utils.navigateToMapLocation(
                                                      '${facility.latitude}',
                                                      '${facility.longitude}',
                                                    ),
                                        ),
                                        TitleDetailsCard(
                                          title: l10n.facilitiesStatus,
                                          text:
                                              (facility.isOperational ?? false)
                                              ? l10n.facilitiesOperational
                                              : l10n.facilitiesNotOperational,
                                          iconData: PhosphorIconsRegular.flag,
                                          accentColor: DesignColor.accentEnergy,
                                        ),
                                        if (facility.capacityTpd != null ||
                                            facility.storageAreaSqm != null)
                                          TitleDetailsCard(
                                            title: l10n.facilitiesCapacity,
                                            text: [
                                              if (facility.capacityTpd
                                                  case final value?)
                                                l10n.facilitiesTonnesPerDay(
                                                  number.format(value),
                                                ),
                                              if (facility.storageAreaSqm
                                                  case final value?)
                                                l10n.facilitiesSqm(
                                                  number.format(value),
                                                ),
                                            ].join(' · '),
                                            iconData:
                                                PhosphorIconsRegular.ruler,
                                            accentColor: DesignColor.accentType,
                                          ),
                                        if ((facility.products ?? const [])
                                            .isNotEmpty)
                                          TitleDetailsCard(
                                            title: l10n.facilitiesProducts,
                                            text: facility.products!.join(', '),
                                            iconData:
                                                PhosphorIconsRegular.package,
                                            accentColor:
                                                DesignColor.accentPoints,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
