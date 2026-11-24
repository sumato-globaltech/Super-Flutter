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
import 'package:super_flutter/features/support/presentation/support/bloc/support_bloc.dart';
import 'package:super_flutter/features/support/presentation/support/bloc/support_event.dart';
import 'package:super_flutter/features/support/presentation/support/bloc/support_state.dart';
import 'package:super_flutter/features/support/routes/support_route_names.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SupportBloc>()..add(const SupportStarted()),
      child: const _SupportView(),
    );
  }
}

class _SupportView extends StatelessWidget {
  const _SupportView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.supportTitle),
      body: SafeArea(
        child: BlocConsumer<SupportBloc, SupportState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == SupportStatus.failure &&
              curr.tickets != null,
          listener: (context, state) => context.showSnackBar(
            state.errorMessage ?? l10n.errorUnknown,
            isError: true,
          ),
          builder: (context, state) {
            final tickets = state.tickets;
            if (tickets == null) {
              if (state.status == SupportStatus.failure) {
                return AppErrorView(
                  message: state.errorMessage ?? l10n.errorUnknown,
                  retryLabel: l10n.tryAgain,
                  onRetry: () =>
                      context.read<SupportBloc>().add(const SupportStarted()),
                );
              }
              return const Center(child: DesignProgress());
            }
            // The next page, unless one is loading or the last one failed.
            // The bloc's own state is read: several asks can come in a frame.
            void loadMore() {
              final bloc = context.read<SupportBloc>();
              final now = bloc.state;
              if ((now.tickets?.hasMore ?? false) &&
                  !now.loadingMore &&
                  now.status == SupportStatus.success) {
                bloc.add(const SupportMoreRequested());
              }
            }

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<SupportBloc>()
                  ..add(const SupportStarted());
                await bloc.stream.firstWhere(
                  (state) => state.status != SupportStatus.loading,
                );
              },
              child: tickets.items.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyView(
                            title: l10n.supportEmpty,
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
                            metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                          loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                        itemCount:
                            tickets.items.length + (tickets.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == tickets.items.length) {
                            final failed =
                                state.status == SupportStatus.failure &&
                                !state.loadingMore;
                            if (!failed) {
                              // A list too short to scroll asks once its end is in view.
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) loadMore();
                              });
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Center(
                                child: failed
                                    ? TextButton(
                                        onPressed: () => context
                                            .read<SupportBloc>()
                                            .add(const SupportMoreRequested()),
                                        child: Text(l10n.tryAgain),
                                      )
                                    : const DesignProgress(),
                              ),
                            );
                          }
                          final ticket = tickets.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: DesignCard(
                              paddingChild: const EdgeInsets.fromLTRB(
                                14,
                                14,
                                14,
                                16,
                              ),
                              onTap: ticket.id == null
                                  ? null
                                  : () => context.push(
                                      SupportRouteNames.ticketDetailFor(
                                        ticket.id!,
                                      ),
                                    ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TitleDetailsCard(
                                    title: l10n.supportNumber,
                                    text: ticket.number ?? '--',
                                    isFirstItem: true,
                                    showNavigateIcon: true,
                                    iconData: PhosphorIconsRegular.barcode,
                                    accentColor: DesignColor.accentUin,
                                    isCopyable: true,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n.supportSubject,
                                    text: ticket.subject ?? '--',
                                    iconData: PhosphorIconsRegular.textAa,
                                    accentColor: DesignColor.accentEnergy,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n.supportCreatedAt,
                                    text: switch (ticket.createdAt) {
                                      final date? => DateFormat.yMMMd().format(
                                        date,
                                      ),
                                      null => '--',
                                    },
                                    iconData:
                                        PhosphorIconsRegular.calendarBlank,
                                    accentColor: DesignColor.accentType,
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
    );
  }
}
