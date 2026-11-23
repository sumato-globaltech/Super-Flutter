import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';

import '../bloc/notice_detail_bloc.dart';
import '../bloc/notice_detail_event.dart';
import '../bloc/notice_detail_state.dart';

class NoticeDetailScreen extends StatelessWidget {
  const NoticeDetailScreen({required this.noticeId, super.key});

  final String noticeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<NoticeDetailBloc>()
            ..add(NoticeDetailStarted(noticeId: noticeId)),
      child: _NoticeDetailView(noticeId: noticeId),
    );
  }
}

class _NoticeDetailView extends StatelessWidget {
  const _NoticeDetailView({required this.noticeId});

  final String noticeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.noticeDetailTitle),
      body: BlocBuilder<NoticeDetailBloc, NoticeDetailState>(
        builder: (context, state) {
          return switch (state.status) {
            NoticeDetailStatus.initial ||
            NoticeDetailStatus.loading => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: DesignProgress(),
              ),
            ),
            NoticeDetailStatus.failure => AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => context.read<NoticeDetailBloc>().add(
                NoticeDetailStarted(noticeId: noticeId),
              ),
            ),
            NoticeDetailStatus.loaded => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NoticeDetailState state) {
    final l10n = AppLocalizations.of(context);
    final notice = state.notice!;
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding.copyWith(bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DesignCard(
                paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TitleDetailsCard(
                      title: l10n.noticeDetailFieldTitle,
                      text: notice.title ?? '-',
                      isFirstItem: true,
                      iconData: PhosphorIconsRegular.textT,
                      accentColor: DesignColor.accentName,
                    ),
                    TitleDetailsCard(
                      title: l10n.noticeDetailFieldCategory,
                      text: notice.category?.name ?? '-',
                      iconData: PhosphorIconsRegular.tag,
                      accentColor: DesignColor.accentType,
                    ),
                    TitleDetailsCard(
                      title: l10n.noticeDetailFieldPriority,
                      text: notice.priority?.label ?? '-',
                      iconData: PhosphorIconsRegular.flag,
                      accentColor: notice.priority?.value == 'high'
                          ? DesignColor.orange
                          : DesignColor.accentEnergy,
                    ),
                    TitleDetailsCard(
                      title: l10n.noticeDetailFieldPublishedAt,
                      text: switch (notice.publishedAt) {
                        final date? => DateFormat.yMMMd().format(date.toLocal()),
                        null => '--',
                      },
                      iconData: PhosphorIconsRegular.calendar,
                      accentColor: DesignColor.accentPoints,
                    ),
                    TitleDetailsCard(
                      title: l10n.noticeDetailFieldExpiresAt,
                      text: switch (notice.expiresAt) {
                        final date? => DateFormat.yMMMd().format(date.toLocal()),
                        null => '--',
                      },
                      iconData: PhosphorIconsRegular.calendarX,
                      accentColor: DesignColor.accentLocation,
                    ),
                  ],
                ),
              ),
              if (notice.body != null && notice.body!.isNotEmpty) ...[
                const SizedBox(height: 12),
                DesignCard(
                  paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TitleDetailsCard(
                        title: l10n.noticeDetailFieldBody,
                        text: '',
                        isFirstItem: true,
                        iconData: PhosphorIconsRegular.article,
                        accentColor: DesignColor.accentName,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        notice.body!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
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
  }
}
