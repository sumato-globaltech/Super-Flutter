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
import 'package:super_flutter/features/help_desk/presentation/queue_summary/bloc/queue_summary_bloc.dart';
import 'package:super_flutter/features/help_desk/presentation/queue_summary/bloc/queue_summary_event.dart';
import 'package:super_flutter/features/help_desk/presentation/queue_summary/bloc/queue_summary_state.dart';

class QueueSummaryScreen extends StatelessWidget {
  const QueueSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<QueueSummaryBloc>()..add(const QueueSummaryStarted()),
      child: const _QueueSummaryView(),
    );
  }
}

class _QueueSummaryView extends StatelessWidget {
  const _QueueSummaryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.helpDeskQueueSummaryTitle),
      body: BlocBuilder<QueueSummaryBloc, QueueSummaryState>(
        builder: (context, state) {
          if (state.status == QueueSummaryStatus.failure &&
              state.queueSummary == null) {
            return AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => context.read<QueueSummaryBloc>().add(
                const QueueSummaryStarted(),
              ),
            );
          }
          final queueSummary = state.queueSummary;
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DesignCard(
                      title: l10n.helpDeskQueueSummaryDetails,
                      paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.helpDeskQueueSummaryOpen,
                                  text: queueSummary == null
                                      ? ''
                                      : queueSummary.open?.toString() ?? '--',
                                  isTextLoading: queueSummary == null,
                                  isFirstItem: true,
                                  iconData: PhosphorIconsRegular.hash,
                                  accentColor: DesignColor.accentName,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title:
                                      l10n.helpDeskQueueSummaryOverdueFollowUps,
                                  text: queueSummary == null
                                      ? ''
                                      : queueSummary.overdueFollowUps
                                                ?.toString() ??
                                            '--',
                                  isTextLoading: queueSummary == null,
                                  iconData: PhosphorIconsRegular.hash,
                                  accentColor: DesignColor.accentEnergy,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.helpDeskQueueSummaryResolvedToday,
                                  text: queueSummary == null
                                      ? ''
                                      : queueSummary.resolvedToday
                                                ?.toString() ??
                                            '--',
                                  isTextLoading: queueSummary == null,
                                  iconData: PhosphorIconsRegular.hash,
                                  accentColor: DesignColor.accentPoints,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.helpDeskQueueSummaryUnassigned,
                                  text: queueSummary == null
                                      ? ''
                                      : queueSummary.unassigned?.toString() ??
                                            '--',
                                  isTextLoading: queueSummary == null,
                                  iconData: PhosphorIconsRegular.hash,
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
