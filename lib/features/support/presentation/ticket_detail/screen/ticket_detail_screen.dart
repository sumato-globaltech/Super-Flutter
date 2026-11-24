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
import 'package:super_flutter/features/support/presentation/ticket_detail/bloc/ticket_detail_bloc.dart';
import 'package:super_flutter/features/support/presentation/ticket_detail/bloc/ticket_detail_event.dart';
import 'package:super_flutter/features/support/presentation/ticket_detail/bloc/ticket_detail_state.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final String ticket;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<TicketDetailBloc>()..add(TicketDetailStarted(ticket: ticket)),
      child: _TicketDetailView(ticket: ticket),
    );
  }
}

class _TicketDetailView extends StatelessWidget {
  const _TicketDetailView({required this.ticket});

  final String ticket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.supportTicketDetailTitle),
      body: BlocBuilder<TicketDetailBloc, TicketDetailState>(
        builder: (context, state) {
          if (state.status == TicketDetailStatus.failure &&
              state.ticketDetails == null) {
            return AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => context.read<TicketDetailBloc>().add(
                TicketDetailStarted(ticket: ticket),
              ),
            );
          }
          final ticketDetails = state.ticketDetails;
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DesignCard(
                      title: l10n.supportTicketDetailDetails,
                      paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.supportTicketDetailNumber,
                                  text: ticketDetails == null
                                      ? ''
                                      : ticketDetails.number ?? '--',
                                  isTextLoading: ticketDetails == null,
                                  isFirstItem: true,
                                  iconData: PhosphorIconsRegular.barcode,
                                  accentColor: DesignColor.accentUin,
                                  isCopyable: true,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.supportTicketDetailSubject,
                                  text: ticketDetails == null
                                      ? ''
                                      : ticketDetails.subject ?? '--',
                                  isTextLoading: ticketDetails == null,
                                  iconData: PhosphorIconsRegular.textAa,
                                  accentColor: DesignColor.accentEnergy,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.supportTicketDetailQuestion,
                                  text: ticketDetails == null
                                      ? ''
                                      : ticketDetails.question ?? '--',
                                  isTextLoading: ticketDetails == null,
                                  iconData: PhosphorIconsRegular.textAa,
                                  accentColor: DesignColor.accentPoints,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.supportTicketDetailOutcome,
                                  text: ticketDetails == null
                                      ? ''
                                      : ticketDetails.outcome ?? '--',
                                  isTextLoading: ticketDetails == null,
                                  iconData: PhosphorIconsRegular.textAa,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.supportTicketDetailCreatedAt,
                                  text: ticketDetails == null
                                      ? ''
                                      : switch (ticketDetails.createdAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: ticketDetails == null,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.supportTicketDetailResolvedAt,
                                  text: ticketDetails == null
                                      ? ''
                                      : switch (ticketDetails.resolvedAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: ticketDetails == null,
                                  iconData: PhosphorIconsRegular.calendarBlank,
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
