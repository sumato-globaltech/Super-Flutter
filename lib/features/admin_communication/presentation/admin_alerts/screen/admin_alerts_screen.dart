import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:super_flutter/data/admin_communication/model/admin_alert_model.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_alerts/bloc/admin_alerts_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_alerts/bloc/admin_alerts_event.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_alerts/bloc/admin_alerts_state.dart';
import 'package:super_flutter/features/admin_communication/routes/admin_communication_route_names.dart';

class AdminAlertsScreen extends StatelessWidget {
  const AdminAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminAlertsBloc>()..add(const AdminAlertsStarted()),
      child: const _AdminAlertsView(),
    );
  }
}

class _AdminAlertsView extends StatelessWidget {
  const _AdminAlertsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.adminCommunicationAdminAlertsTitle),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final created = await context.push<bool>(
            AdminCommunicationRouteNames.addAlert,
          );
          if (created == true && context.mounted) {
            context.read<AdminAlertsBloc>().add(const AdminAlertsStarted());
          }
        },
        child: const Icon(PhosphorIconsRegular.plus),
      ),
      body: SafeArea(
        child: BlocConsumer<AdminAlertsBloc, AdminAlertsState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == AdminAlertsStatus.failure &&
              curr.adminAlerts != null,
          listener: (context, state) => context.showSnackBar(
            state.errorMessage ?? l10n.errorUnknown,
            isError: true,
          ),
          builder: (context, state) {
            final adminAlerts = state.adminAlerts;
            if (adminAlerts == null) {
              if (state.status == AdminAlertsStatus.failure) {
                return AppErrorView(
                  message: state.errorMessage ?? l10n.errorUnknown,
                  retryLabel: l10n.tryAgain,
                  onRetry: () => context.read<AdminAlertsBloc>().add(
                    const AdminAlertsStarted(),
                  ),
                );
              }
              return const Center(child: DesignProgress());
            }
            // The next page, unless one is loading or the last one failed.
            // The bloc's own state is read: several asks can come in a frame.
            void loadMore() {
              final bloc = context.read<AdminAlertsBloc>();
              final now = bloc.state;
              if ((now.adminAlerts?.hasMore ?? false) &&
                  !now.loadingMore &&
                  now.status == AdminAlertsStatus.success) {
                bloc.add(const AdminAlertsMoreRequested());
              }
            }

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<AdminAlertsBloc>()
                  ..add(const AdminAlertsStarted());
                await bloc.stream.firstWhere(
                  (state) => state.status != AdminAlertsStatus.loading,
                );
              },
              child: adminAlerts.items.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyView(
                            title: l10n.adminCommunicationAdminAlertsEmpty,
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
                            adminAlerts.items.length +
                            (adminAlerts.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == adminAlerts.items.length) {
                            final failed =
                                state.status == AdminAlertsStatus.failure &&
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
                                        onPressed: () =>
                                            context.read<AdminAlertsBloc>().add(
                                              const AdminAlertsMoreRequested(),
                                            ),
                                        child: Text(l10n.tryAgain),
                                      )
                                    : const DesignProgress(),
                              ),
                            );
                          }
                          final adminAlert = adminAlerts.items[index];
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
                                    title: adminAlert.category?.name ?? '--',
                                    text: adminAlert.title ?? '--',
                                    isFirstItem: true,
                                    iconData:
                                        PhosphorIconsRegular.identificationCard,
                                    accentColor: DesignColor.accentName,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n.adminStatus,
                                    text: [
                                      adminAlert.status?.label ?? '--',
                                      ?adminAlert.severity?.label,
                                      if (adminAlert.statewide ?? false)
                                        l10n.adminAlertStatewide
                                      else
                                        ?adminAlert.district?.name,
                                    ].join(' · '),
                                    iconData: PhosphorIconsRegular.flag,
                                    accentColor: DesignColor.accentEnergy,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n
                                        .adminCommunicationAdminAlertsStartsOn,
                                    text: adminAlert.startsOn ?? '--',
                                    iconData:
                                        PhosphorIconsRegular.calendarBlank,
                                    accentColor: DesignColor.accentType,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n
                                        .adminCommunicationAdminAlertsEndsOn,
                                    text: adminAlert.endsOn ?? '--',
                                    iconData:
                                        PhosphorIconsRegular.calendarBlank,
                                    accentColor: DesignColor.accentType,
                                  ),
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    children: [
                                      if (const {
                                        'draft',
                                        'active',
                                      }.contains(adminAlert.status?.value))
                                        TextButton.icon(
                                          onPressed: () async {
                                            final saved = await context.push<bool>(
                                              AdminCommunicationRouteNames.editAlertFor(
                                                adminAlert.id!,
                                              ),
                                              extra: adminAlert,
                                            );
                                            if (saved == true &&
                                                context.mounted) {
                                              context
                                                  .read<AdminAlertsBloc>()
                                                  .add(
                                                    const AdminAlertsStarted(),
                                                  );
                                            }
                                          },
                                          icon: const Icon(
                                            PhosphorIconsRegular.pencilSimple,
                                          ),
                                          label: Text(l10n.adminEdit),
                                        ),
                                      for (final action
                                          in switch (adminAlert.status?.value) {
                                            'draft' => const [
                                              AdminAlertAction.activate,
                                              AdminAlertAction.delete,
                                            ],
                                            'active' => const [
                                              AdminAlertAction.cancel,
                                            ],
                                            _ => const <AdminAlertAction>[],
                                          })
                                        TextButton.icon(
                                          style:
                                              action ==
                                                  AdminAlertAction.activate
                                              ? null
                                              : TextButton.styleFrom(
                                                  foregroundColor: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                          onPressed: () => _confirm(
                                            context,
                                            l10n,
                                            adminAlert,
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

  IconData _icon(AdminAlertAction action) => switch (action) {
    AdminAlertAction.activate => PhosphorIconsRegular.megaphone,
    AdminAlertAction.cancel => PhosphorIconsRegular.xCircle,
    AdminAlertAction.delete => PhosphorIconsRegular.trash,
  };

  String _label(AppLocalizations l10n, AdminAlertAction action) =>
      switch (action) {
        AdminAlertAction.activate => l10n.adminActivate,
        AdminAlertAction.cancel => l10n.adminAlertCancel,
        AdminAlertAction.delete => l10n.delete,
      };

  Future<void> _confirm(
    BuildContext context,
    AppLocalizations l10n,
    AdminAlertModel alert,
    AdminAlertAction action,
  ) async {
    final bloc = context.read<AdminAlertsBloc>();
    final done = await ConfirmSheet.confirm(
      context,
      title: '${_label(l10n, action)}?',
      description: [
        alert.title ?? '--',
        ?switch (action) {
          AdminAlertAction.cancel => l10n.adminAlertCancelWarning,
          AdminAlertAction.delete => l10n.adminDeleteWarning,
          _ => null,
        },
      ].join('\n'),
      icon: Icon(_icon(action), size: 48),
      confirmText: _label(l10n, action),
      confirmColor: switch (action) {
        AdminAlertAction.cancel ||
        AdminAlertAction.delete => Theme.of(context).colorScheme.error,
        _ => null,
      },
      onConfirm: () {
        final completer = Completer<void>();
        bloc.add(
          AdminAlertActionSubmitted(
            alert: alert.id!,
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
