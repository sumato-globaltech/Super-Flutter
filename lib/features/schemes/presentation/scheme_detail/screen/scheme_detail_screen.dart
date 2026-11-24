import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/app/access/app_features.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/schemes/routes/schemes_route_names.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_bloc.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_event.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_state.dart';

class SchemeDetailScreen extends StatelessWidget {
  const SchemeDetailScreen({super.key, required this.scheme});

  final String scheme;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SchemeDetailBloc>()
        ..add(
          SchemeDetailStarted(
            scheme: scheme,
            farmer: appFeatures.canOpen(
              SchemesRouteNames.myApplications,
              context.read<AuthCubit>().state.access,
            ),
          ),
        ),
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
      appBar: AppTopBar(
        title: context.select(
          (SchemeDetailBloc bloc) =>
              bloc.state.schemeDetails?.name ?? l10n.schemesSchemeDetailTitle,
        ),
      ),
      bottomNavigationBar: BlocBuilder<SchemeDetailBloc, SchemeDetailState>(
        buildWhen: (prev, curr) =>
            prev.application != curr.application ||
            prev.canApply != curr.canApply,
        builder: (context, state) {
          final application = state.application;
          if (!state.canApply && application == null) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: application != null
                  ? OutlinedButton.icon(
                      onPressed: () =>
                          context.push(SchemesRouteNames.myApplications),
                      icon: const Icon(PhosphorIconsRegular.files),
                      label: Text(
                        '${l10n.schemesYourApplication}: '
                        '${application.status?.label ?? '--'}',
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () => _apply(context, l10n),
                      icon: const Icon(PhosphorIconsRegular.paperPlaneTilt),
                      label: Text(l10n.schemesApply),
                    ),
            ),
          );
        },
      ),
      body: BlocBuilder<SchemeDetailBloc, SchemeDetailState>(
        builder: (context, state) {
          if (state.status == SchemeDetailStatus.failure &&
              state.schemeDetails == null) {
            return AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => context.read<SchemeDetailBloc>().add(
                SchemeDetailStarted(scheme: scheme, farmer: state.farmer),
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
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.schemesSchemeDetailEligibility,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.eligibility ?? '--',
                                  isTextLoading: schemeDetails == null,
                                  iconData: PhosphorIconsRegular.checkSquare,
                                  accentColor: DesignColor.accentType,
                                  isReadMore: true,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n
                                      .schemesSchemeDetailApplicationProcess,
                                  text: schemeDetails == null
                                      ? ''
                                      : schemeDetails.applicationProcess ??
                                            '--',
                                  isTextLoading: schemeDetails == null,
                                  iconData: PhosphorIconsRegular.listNumbers,
                                  accentColor: DesignColor.accentType,
                                  isReadMore: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if ((schemeDetails?.requiredDocuments ?? const [])
                        .isNotEmpty) ...[
                      const SizedBox(height: 8),
                      DesignCard(
                        title: l10n.schemesRequiredDocuments,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (index, name)
                                in schemeDetails!.requiredDocuments!.indexed)
                              TitleDetailsCard(
                                title: '${index + 1}',
                                text: name,
                                isFirstItem: index == 0,
                                iconData: PhosphorIconsRegular.fileText,
                                accentColor: DesignColor.accentUin,
                              ),
                          ],
                        ),
                      ),
                    ],
                    if ((schemeDetails?.documents ?? const []).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      DesignCard(
                        title: l10n.schemesFiles,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (index, file)
                                in schemeDetails!.documents!.indexed)
                              TitleDetailsCard(
                                title: l10n.schemesFile,
                                text: file.name ?? '--',
                                isFirstItem: index == 0,
                                showNavigateIcon: file.url != null,
                                iconData: PhosphorIconsRegular.downloadSimple,
                                accentColor: DesignColor.accentLocation,
                                onTap: file.url == null
                                    ? null
                                    : () => Utils.launchUrl2(url: file.url!),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if ((schemeDetails?.districts ?? const []).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      DesignCard(
                        title: l10n.schemesDistricts,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: TitleDetailsCard(
                          title: schemeDetails!.scope?.label ?? '',
                          text: [
                            for (final district in schemeDetails.districts!)
                              district.name ?? '--',
                          ].join(', '),
                          isFirstItem: true,
                          iconData: PhosphorIconsRegular.mapPin,
                          accentColor: DesignColor.accentLocation,
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

  void _apply(BuildContext context, AppLocalizations l10n) {
    final bloc = context.read<SchemeDetailBloc>();
    final required = bloc.state.schemeDetails?.requiredDocuments ?? const [];
    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: l10n.schemesApplyTitle,
        description: required.isEmpty
            ? l10n.schemesApplyMessage
            : l10n.schemesApplyMessageDocuments(required.join(', ')),
        confirmText: l10n.schemesApply,
        onPressed: () async {
          final completer = Completer<void>();
          bloc.add(SchemeApplied(scheme: scheme, completer: completer));
          await completer.future;
          if (context.mounted) {
            Navigator.of(context).pop();
            context.showSnackBar(l10n.schemesApplied);
          }
        },
      ),
    );
  }
}
