import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_bloc.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_event.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_state.dart';

class SchemeDetailScreen extends StatelessWidget {
  const SchemeDetailScreen({super.key, required this.scheme});

  final String scheme;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SchemeDetailBloc>()..add(SchemeDetailStarted(scheme: scheme)),
      child: _SchemeDetailView(scheme: scheme),
    );
  }
}

class _SchemeDetailView extends StatelessWidget {
  const _SchemeDetailView({required this.scheme});

  final String scheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.schemesSchemeDetailTitle),
      body: BlocBuilder<SchemeDetailBloc, SchemeDetailState>(
        builder: (context, state) {
          if (state.status == SchemeDetailStatus.failure &&
              state.schemeDetails == null) {
            return AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => context.read<SchemeDetailBloc>().add(
                SchemeDetailStarted(scheme: scheme),
              ),
            );
          }
          final schemeDetails = state.schemeDetails;
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DesignCard(
                      title: l10n.schemesSchemeDetailDetails,
                      paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailCode,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.code ?? '--',
                                  isTextLoading: schemeDetails == null,
                                  isFirstItem: true,
                                  iconData: PhosphorIconsRegular.barcode,
                                  accentColor: DesignColor.accentUin,
                                  isCopyable: true,
                                ),
                              ),
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailIsOpen,
                                  text: schemeDetails == null
                                      ? ''
                                      : switch (schemeDetails.isOpen) {
                                          true => l10n.valueYes,
                                          false => l10n.valueNo,
                                          null => '--',
                                        },
                                  isTextLoading: schemeDetails == null,
                                  isFirstItem: true,
                                  isCrossAxisAlignmentStart: false,
                                  iconData: PhosphorIconsRegular.checkCircle,
                                  accentColor: DesignColor.accentPoints,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailStartsOn,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.startsOn ?? '--',
                                  isTextLoading: schemeDetails == null,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailEndsOn,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.endsOn ?? '--',
                                  isTextLoading: schemeDetails == null,
                                  isCrossAxisAlignmentStart: false,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailSubsidyAmount,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.subsidyAmount ?? '--',
                                  isTextLoading: schemeDetails == null,
                                  iconData: PhosphorIconsRegular.currencyInr,
                                  accentColor: DesignColor.accentPoints,
                                ),
                              ),
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailFundingSource,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.fundingSource ?? '--',
                                  isTextLoading: schemeDetails == null,
                                  isCrossAxisAlignmentStart: false,
                                  iconData: PhosphorIconsRegular.textAa,
                                  accentColor: DesignColor.accentLocation,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailFinancialYear,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.financialYear ?? '--',
                                  isTextLoading: schemeDetails == null,
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
                                  title: l10n.schemesSchemeDetailDescription,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.description ?? '--',
                                  isTextLoading: schemeDetails == null,
                                  iconData: PhosphorIconsRegular.note,
                                  accentColor: DesignColor.accentEnergy,
                                  isReadMore: true,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailEligibility,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.eligibility ?? '--',
                                  isTextLoading: schemeDetails == null,
                                  iconData: PhosphorIconsRegular.textAa,
                                  accentColor: DesignColor.accentPoints,
                                ),
                              ),
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n
                                      .schemesSchemeDetailApplicationProcess,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.applicationProcess ??
                                            '--',
                                  isTextLoading: schemeDetails == null,
                                  isCrossAxisAlignmentStart: false,
                                  iconData: PhosphorIconsRegular.textAa,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
