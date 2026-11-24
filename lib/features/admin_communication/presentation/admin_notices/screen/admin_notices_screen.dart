import 'dart:async';

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
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/data/admin_communication/model/admin_notice_model.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_notices/bloc/admin_notices_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_notices/bloc/admin_notices_event.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_notices/bloc/admin_notices_state.dart';
import 'package:super_flutter/features/admin_communication/routes/admin_communication_route_names.dart';

class AdminNoticesScreen extends StatelessWidget {
  const AdminNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AdminNoticesBloc>()..add(const AdminNoticesStarted()),
      child: const _AdminNoticesView(),
    );
  }
}

class _AdminNoticesView extends StatelessWidget {
  const _AdminNoticesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.adminCommunicationAdminNoticesTitle),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final created = await context.push<bool>(
            AdminCommunicationRouteNames.addNotice,
          );
          if (created == true && context.mounted) {
            context.read<AdminNoticesBloc>().add(const AdminNoticesStarted());
          }
        },
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: SafeArea(
        child: BlocConsumer<AdminNoticesBloc, AdminNoticesState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == AdminNoticesStatus.failure &&
              curr.adminNotices != null,
          listener: (context, state) => context.showSnackBar(
            state.errorMessage ?? l10n.errorUnknown,
            isError: true,
          ),
          builder: (context, state) {
            final adminNotices = state.adminNotices;
            if (adminNotices == null) {
              if (state.status == AdminNoticesStatus.failure) {
                return AppErrorView(
                  message: state.errorMessage ?? l10n.errorUnknown,
                  retryLabel: l10n.tryAgain,
                  onRetry: () => context.read<AdminNoticesBloc>().add(
                    const AdminNoticesStarted(),
                  ),
                );
              }
              return const Center(child: DesignProgress());
            }
            // The next page, unless one is loading or the last one failed.
            // The bloc's own state is read: several asks can come in a frame.
            void loadMore() {
              final bloc = context.read<AdminNoticesBloc>();
              final now = bloc.state;
              if ((now.adminNotices?.hasMore ?? false) &&
                  !now.loadingMore &&
                  now.status == AdminNoticesStatus.success) {
                bloc.add(const AdminNoticesMoreRequested());
              }
            }

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<AdminNoticesBloc>()
                  ..add(const AdminNoticesStarted());
                await bloc.stream.firstWhere(
                  (state) => state.status != AdminNoticesStatus.loading,
                );
              },
              child: adminNotices.items.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyView(
                            title: l10n.adminCommunicationAdminNoticesEmpty,
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
                        padding: AppSpacing.pagePadding.copyWith(bottom: 88),
                        itemCount:
                            adminNotices.items.length +
                            (adminNotices.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == adminNotices.items.length) {
                            final failed =
                                state.status == AdminNoticesStatus.failure &&
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
                                            .read<AdminNoticesBloc>()
                                            .add(
                                              const AdminNoticesMoreRequested(),
                                            ),
                                        child: Text(l10n.tryAgain),
                                      )
                                    : const DesignProgress(),
                              ),
                            );
                          }
                          final adminNotice = adminNotices.items[index];
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TitleDetailsCard(
                                    title: adminNotice.category?.name ?? '--',
                                    text: adminNotice.title ?? '--',
                                    isFirstItem: true,
                                    iconData:
                                        PhosphorIconsRegular.identificationCard,
                                    accentColor: DesignColor.accentName,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n.adminStatus,
                                    text: [
                                      adminNotice.status?.label ?? '--',
                                      ?adminNotice.priority?.label,
                                    ].join(' · '),
                                    iconData: PhosphorIconsRegular.flag,
                                    accentColor: DesignColor.accentEnergy,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n
                                        .adminCommunicationAdminNoticesPublishedAt,
                                    text: switch (adminNotice.publishedAt) {
                                      final date? => DateFormat.yMMMd().format(
                                        date.toLocal(),
                                      ),
                                      null => '--',
                                    },
                                    iconData:
                                        PhosphorIconsRegular.calendarBlank,
                                    accentColor: DesignColor.accentType,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n
                                        .adminCommunicationAdminNoticesExpiresAt,
                                    text: switch (adminNotice.expiresAt) {
                                      final date? => DateFormat.yMMMd().format(
                                        date.toLocal(),
                                      ),
                                      null => '--',
                                    },
                                    iconData:
                                        PhosphorIconsRegular.calendarBlank,
                                    accentColor: DesignColor.accentType,
                                  ),
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    children: [
                                      if (const {
                                        'draft',
                                        'published',
                                      }.contains(adminNotice.status?.value))
                                        TextButton.icon(
                                          onPressed: () async {
                                            final saved = await context.push<bool>(
                                              AdminCommunicationRouteNames.editNoticeFor(
                                                adminNotice.id!,
                                              ),
                                              extra: adminNotice,
                                            );
                                            if (saved == true &&
                                                context.mounted) {
                                              context
                                                  .read<AdminNoticesBloc>()
                                                  .add(
                                                    const AdminNoticesStarted(),
                                                  );
                                            }
                                          },
                                          icon: const Icon(
                                            PhosphorIconsRegular.pencilSimple,
                                          ),
                                          label: Text(l10n.adminEdit),
                                        ),
                                      for (final action in switch (adminNotice
                                          .status
                                          ?.value) {
                                        'draft' => const [
                                          AdminNoticeAction.publish,
                                          AdminNoticeAction.delete,
                                        ],
                                        'published' => const [
                                          AdminNoticeAction.archive,
                                        ],
                                        'archived' => const [
                                          AdminNoticeAction.restore,
                                        ],
                                        _ => const <AdminNoticeAction>[],
                                      })
                                        TextButton.icon(
                                          style:
                                              action == AdminNoticeAction.delete
                                              ? TextButton.styleFrom(
                                                  foregroundColor: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                )
                                              : null,
                                          onPressed: () => _confirm(
                                            context,
                                            l10n,
                                            adminNotice,
                                            action,
                                          ),
                                          icon: Icon(_icon(action)),
                                          label: Text(_label(l10n, action)),
                                        ),
                                    ],
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

  IconData _icon(AdminNoticeAction action) => switch (action) {
    AdminNoticeAction.publish => PhosphorIconsRegular.megaphone,
    AdminNoticeAction.archive => PhosphorIconsRegular.archive,
    AdminNoticeAction.restore => PhosphorIconsRegular.arrowUUpLeft,
    AdminNoticeAction.delete => PhosphorIconsRegular.trash,
  };

  String _label(AppLocalizations l10n, AdminNoticeAction action) =>
      switch (action) {
        AdminNoticeAction.publish => l10n.adminPublish,
        AdminNoticeAction.archive => l10n.adminArchive,
        AdminNoticeAction.restore => l10n.adminRestore,
        AdminNoticeAction.delete => l10n.delete,
      };

  Future<void> _confirm(
    BuildContext context,
    AppLocalizations l10n,
    AdminNoticeModel notice,
    AdminNoticeAction action,
  ) async {
    final bloc = context.read<AdminNoticesBloc>();
    final done = await ConfirmSheet.confirm(
      context,
      title: '${_label(l10n, action)}?',
      description: [
        notice.title ?? '--',
        ?switch (action) {
          AdminNoticeAction.delete => l10n.adminDeleteWarning,
          _ => null,
        },
      ].join('\n'),
      icon: Icon(_icon(action), size: 48),
      confirmText: _label(l10n, action),
      confirmColor: switch (action) {
        AdminNoticeAction.delete => Theme.of(context).colorScheme.error,
        _ => null,
      },
      onConfirm: () {
        final completer = Completer<void>();
        bloc.add(
          AdminNoticeActionSubmitted(
            notice: notice.id!,
            action: action,
            completer: completer,
          ),
        );
        return completer.future;
      },
    );
    if (done && context.mounted) context.showSnackBar(l10n.adminDone);
  }
}
