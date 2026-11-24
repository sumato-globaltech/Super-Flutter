import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_colors.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/features/production/presentation/production/bloc/production_bloc.dart';
import 'package:super_flutter/features/production/presentation/production/bloc/production_event.dart';
import 'package:super_flutter/features/production/presentation/production/bloc/production_state.dart';

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductionBloc>()..add(const ProductionStarted()),
      child: const _ProductionView(),
    );
  }
}

class _ProductionView extends StatelessWidget {
  const _ProductionView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final number = NumberFormat('#,##0.###');
    double tonnes(String? value) => double.tryParse(value ?? '') ?? 0;

    return Scaffold(
      appBar: AppTopBar(title: l10n.productionTitle),
      body: BlocConsumer<ProductionBloc, ProductionState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status &&
            curr.status == ProductionStatus.failure &&
            curr.productionInsights != null,
        listener: (context, state) => context.showSnackBar(
          state.errorMessage ?? l10n.errorUnknown,
          isError: true,
        ),
        builder: (context, state) {
          if (state.status == ProductionStatus.failure &&
              state.productionInsights == null) {
            return AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () =>
                  context.read<ProductionBloc>().add(const ProductionStarted()),
            );
          }
          final productionInsights = state.productionInsights;
          final months = productionInsights?.byMonth ?? const [];
          final crops = productionInsights?.byCrop ?? const [];
          final most = months.fold<double>(0, (most, month) {
            final value = tonnes(month.tonnes);
            return value > most ? value : most;
          });
          void filterBy(ProductionFilter filter) => context
              .read<ProductionBloc>()
              .add(ProductionStarted(filter: filter));

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<ProductionBloc>()
                ..add(const ProductionStarted());
              await bloc.stream.firstWhere(
                (state) => state.status != ProductionStatus.loading,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: Padding(
                  padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              key: ValueKey((
                                'month',
                                state.filter,
                                months.length,
                              )),
                              initialValue: state.filter.month,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.productionMonth,
                              ),
                              items: [
                                DropdownMenuItem(
                                  child: Text(l10n.productionAllMonths),
                                ),
                                for (final month in months)
                                  DropdownMenuItem(
                                    value: month.month,
                                    child: Text(month.name ?? '--'),
                                  ),
                              ],
                              onChanged: (month) => filterBy((
                                month: month,
                                crop: state.filter.crop,
                              )),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              key: ValueKey((
                                'crop',
                                state.filter,
                                state.crops.length,
                              )),
                              initialValue: state.filter.crop,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.productionCrop,
                              ),
                              items: [
                                DropdownMenuItem(
                                  child: Text(l10n.productionAllCrops),
                                ),
                                for (final crop in state.crops)
                                  DropdownMenuItem(
                                    value: crop.slug,
                                    child: Text(
                                      crop.name ?? '--',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (crop) => filterBy((
                                month: state.filter.month,
                                crop: crop,
                              )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DesignCard(
                        title: l10n.productionDetails,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TitleDetailsCard(
                                    title: l10n.productionFinancialYear,
                                    text: productionInsights == null
                                        ? ''
                                        : productionInsights.financialYear ??
                                              '--',
                                    isTextLoading: productionInsights == null,
                                    isFirstItem: true,
                                    iconData: PhosphorIconsRegular.textAa,
                                    accentColor: DesignColor.accentName,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TitleDetailsCard(
                                    title: l10n.productionTotalTonnes,
                                    text: productionInsights == null
                                        ? ''
                                        : number.format(
                                            tonnes(
                                              productionInsights.totalTonnes,
                                            ),
                                          ),
                                    isTextLoading: productionInsights == null,
                                    iconData: PhosphorIconsRegular.textAa,
                                    accentColor: DesignColor.accentEnergy,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (months.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        DesignCard(
                          title: l10n.productionByMonth,
                          paddingChild: const EdgeInsets.fromLTRB(
                            14,
                            14,
                            14,
                            16,
                          ),
                          child: Column(
                            children: [
                              for (final month in months)
                                Semantics(
                                  label:
                                      '${month.name}: '
                                      '${l10n.productionTonnes(number.format(tonnes(month.tonnes)))}',
                                  excludeSemantics: true,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 84,
                                          child: Text(
                                            month.name ?? '--',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: FractionallySizedBox(
                                              widthFactor: most == 0
                                                  ? 0
                                                  : tonnes(month.tonnes) / most,
                                              child: Container(
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color: theme.appColors.accent,
                                                  borderRadius:
                                                      const BorderRadius.horizontal(
                                                        right: Radius.circular(
                                                          4,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 80,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              number.format(
                                                tonnes(month.tonnes),
                                              ),
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    fontFeatures: const [
                                                      FontFeature.tabularFigures(),
                                                    ],
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (productionInsights != null) ...[
                        const SizedBox(height: 8),
                        DesignCard(
                          title: l10n.productionByCrop,
                          paddingChild: const EdgeInsets.fromLTRB(
                            14,
                            14,
                            14,
                            16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (crops.isEmpty)
                                Text(
                                  l10n.productionEmpty,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              for (final (index, crop) in crops.indexed)
                                TitleDetailsCard(
                                  title: crop.crop ?? '--',
                                  text: [
                                    l10n.productionTonnes(
                                      number.format(tonnes(crop.tonnes)),
                                    ),
                                    l10n.productionRecords(crop.records ?? 0),
                                    l10n.productionDistricts(
                                      crop.districts ?? 0,
                                    ),
                                  ].join(' · '),
                                  isFirstItem: index == 0,
                                  iconData: PhosphorIconsRegular.plant,
                                  accentColor: DesignColor.accentPoints,
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
            ),
          );
        },
      ),
    );
  }
}
