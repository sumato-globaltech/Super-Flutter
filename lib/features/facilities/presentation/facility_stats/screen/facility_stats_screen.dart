import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/features/facilities/presentation/facility_stats/bloc/facility_stats_bloc.dart';
import 'package:super_flutter/features/facilities/presentation/facility_stats/bloc/facility_stats_event.dart';
import 'package:super_flutter/features/facilities/presentation/facility_stats/bloc/facility_stats_state.dart';

class FacilityStatsScreen extends StatelessWidget {
  const FacilityStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<FacilityStatsBloc>()..add(const FacilityStatsStarted()),
      child: const _FacilityStatsView(),
    );
  }
}

class _FacilityStatsView extends StatelessWidget {
  const _FacilityStatsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = NumberFormat('#,##0.##');
    return Scaffold(
      appBar: AppTopBar(title: l10n.facilitiesFacilityStatsTitle),
      body: BlocBuilder<FacilityStatsBloc, FacilityStatsState>(
        builder: (context, state) {
          if (state.status == FacilityStatsStatus.failure &&
              state.facilityStats == null) {
            return AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => context.read<FacilityStatsBloc>().add(
                const FacilityStatsStarted(),
              ),
            );
          }
          final facilityStats = state.facilityStats;
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DesignCard(
                      title: l10n.facilitiesFacilityStatsDetails,
                      paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.facilitiesFacilityStatsTotal,
                                  text: facilityStats == null
                                      ? ''
                                      : facilityStats.total?.toString() ?? '--',
                                  isTextLoading: facilityStats == null,
                                  isFirstItem: true,
                                  iconData: PhosphorIconsRegular.currencyInr,
                                  accentColor: DesignColor.accentPoints,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title:
                                      l10n.facilitiesFacilityStatsOperational,
                                  text: facilityStats == null
                                      ? ''
                                      : facilityStats.operational?.toString() ??
                                            '--',
                                  isTextLoading: facilityStats == null,
                                  iconData: PhosphorIconsRegular.hash,
                                  accentColor: DesignColor.accentEnergy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    for (final (title, icon, rows) in [
                      (
                        l10n.facilitiesByType,
                        PhosphorIconsRegular.warehouse,
                        facilityStats?.byCategory,
                      ),
                      (
                        l10n.facilitiesByDistrict,
                        PhosphorIconsRegular.mapPin,
                        facilityStats?.byDistrict,
                      ),
                    ])
                      if ((rows ?? const []).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        DesignCard(
                          title: title,
                          paddingChild: const EdgeInsets.fromLTRB(
                            14,
                            14,
                            14,
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final (index, row) in rows!.indexed)
                                TitleDetailsCard(
                                  title: row.name ?? '--',
                                  text: [
                                    l10n.facilitiesWorking(
                                      row.operational ?? 0,
                                      row.total ?? 0,
                                    ),
                                    if ((row.capacityTpd ?? 0) > 0)
                                      l10n.facilitiesTonnesPerDay(
                                        number.format(row.capacityTpd),
                                      ),
                                    if ((row.storageAreaSqm ?? 0) > 0)
                                      l10n.facilitiesSqm(
                                        number.format(row.storageAreaSqm),
                                      ),
                                  ].join(' · '),
                                  isFirstItem: index == 0,
                                  iconData: icon,
                                  accentColor: DesignColor.accentType,
                                ),
                            ],
                          ),
                        ),
                      ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
