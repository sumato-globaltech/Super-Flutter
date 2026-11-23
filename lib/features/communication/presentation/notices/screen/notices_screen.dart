import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
import 'package:super_flutter/features/communication/routes/communication_route_names.dart';

import '../bloc/notices_bloc.dart';
import '../bloc/notices_event.dart';
import '../bloc/notices_state.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NoticesBloc>()..add(const NoticesStarted()),
      child: const _NoticesView(),
    );
  }
}

class _NoticesView extends StatelessWidget {
  const _NoticesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.noticesTitle),
      body: BlocBuilder<NoticesBloc, NoticesState>(
        builder: (context, state) {
          final bloc = context.read<NoticesBloc>();
          return switch (state.status) {
            NoticesStatus.initial ||
            NoticesStatus.loading when state.items.isEmpty =>
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: DesignProgress(),
                ),
              ),
            NoticesStatus.failure when state.items.isEmpty => AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => bloc.add(const NoticesStarted()),
            ),
            NoticesStatus.loaded when state.items.isEmpty => RefreshIndicator(
              onRefresh: () async {
                bloc.add(const NoticesStarted());
                await bloc.stream.firstWhere(
                  (s) =>
                      s.status != NoticesStatus.loading &&
                      s.status != NoticesStatus.initial,
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 320,
                  child: AppEmptyView(
                    title: l10n.noticesEmpty,
                    message: l10n.noticesEmptyMessage,
                    icon: PhosphorIconsRegular.megaphone,
                  ),
                ),
              ),
            ),
            _ => _buildList(context, state),
          };
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, NoticesState state) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<NoticesBloc>();
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (state.hasMore &&
            !state.loadingMore &&
            metrics.pixels > metrics.maxScrollExtent * 0.8) {
          bloc.add(const NoticesMoreRequested());
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          bloc.add(const NoticesStarted());
          await bloc.stream.firstWhere(
            (s) =>
                s.status != NoticesStatus.loading &&
                s.status != NoticesStatus.initial,
          );
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding.copyWith(bottom: 0),
          itemCount: state.items.length + (state.hasMore || state.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              // Footer: loading more or retry.
              if (state.loadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: DesignProgress()),
                );
              }
              if (state.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: TextButton(
                      onPressed: () => bloc.add(const NoticesMoreRequested()),
                      child: Text(l10n.tryAgain),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            final notice = state.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DesignCard(
                onTap: () => context.push(
                  CommunicationRouteNames.noticeDetail(notice.id!),
                ),
                paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: TitleDetailsCard(
                  title: [
                    notice.category?.name,
                    switch (notice.publishedAt) {
                      final date? =>
                        DateFormat.yMMMd().format(date.toLocal()),
                      null => null,
                    },
                  ].whereType<String>().join(' · '),
                  text: notice.title ?? '-',
                  isFirstItem: true,
                  showNavigateIcon: true,
                  iconData: PhosphorIconsRegular.megaphone,
                  accentColor: notice.priority?.value == 'high'
                      ? DesignColor.orange
                      : DesignColor.accentName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
