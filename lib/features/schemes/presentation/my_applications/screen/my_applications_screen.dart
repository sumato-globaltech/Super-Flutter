import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/schemes/presentation/my_applications/bloc/my_applications_bloc.dart';
import 'package:super_flutter/features/schemes/presentation/my_applications/bloc/my_applications_event.dart';
import 'package:super_flutter/features/schemes/presentation/my_applications/bloc/my_applications_state.dart';
import 'package:super_flutter/features/schemes/routes/schemes_route_names.dart';

const _uploadTypes = ['pdf', 'jpg', 'jpeg', 'png'];
const _maxUploadBytes = 5 * 1024 * 1024;
const _openForUploads = {'submitted', 'under_review'};

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<MyApplicationsBloc>()..add(const MyApplicationsStarted()),
      child: const _MyApplicationsView(),
    );
  }
}

class _MyApplicationsView extends StatelessWidget {
  const _MyApplicationsView();

  Future<void> _upload(
    BuildContext context,
    AppLocalizations l10n, {
    required String application,
    required String document,
  }) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _uploadTypes,
    );
    final path = files.isEmpty ? null : files.first.path;
    if (path == null || !context.mounted) return;
    if (File(path).lengthSync() > _maxUploadBytes) {
      context.showSnackBar(l10n.schemesFileTooLarge, isError: true);
      return;
    }
    final bloc = context.read<MyApplicationsBloc>();
    await ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: l10n.schemesUploadTitle(document),
        description: path.split(Platform.pathSeparator).last,
        confirmText: l10n.schemesUpload,
        onPressed: () async {
          final completer = Completer<void>();
          bloc.add(
            ApplicationDocumentUploaded(
              application: application,
              name: document,
              path: path,
              completer: completer,
            ),
          );
          await completer.future;
          if (context.mounted) {
            Navigator.of(context).pop();
            context.showSnackBar(l10n.schemesUploaded);
          }
        },
      ),
    );
  }

  void _withdraw(
    BuildContext context,
    AppLocalizations l10n,
    String application,
  ) {
    final bloc = context.read<MyApplicationsBloc>();
    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: l10n.schemesWithdrawTitle,
        description: l10n.schemesWithdrawMessage,
        confirmText: l10n.schemesWithdraw,
        confirmColor: Theme.of(context).colorScheme.error,
        onPressed: () async {
          final completer = Completer<void>();
          bloc.add(
            ApplicationWithdrawn(
              application: application,
              completer: completer,
            ),
          );
          await completer.future;
          if (context.mounted) {
            Navigator.of(context).pop();
            context.showSnackBar(l10n.schemesWithdrawn);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat.yMMMd();
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    String rupees(String? amount) =>
        amount == null ? '--' : money.format(double.tryParse(amount) ?? 0);

    return Scaffold(
      appBar: AppTopBar(title: l10n.schemesMyApplicationsTitle),
      body: BlocBuilder<MyApplicationsBloc, MyApplicationsState>(
        builder: (context, state) {
          final applications = state.applications;
          if (applications == null) {
            if (state.status == MyApplicationsStatus.failure) {
              return AppErrorView(
                message: state.errorMessage ?? l10n.errorUnknown,
                retryLabel: l10n.tryAgain,
                onRetry: () => context.read<MyApplicationsBloc>().add(
                  const MyApplicationsStarted(),
                ),
              );
            }
            return const Center(child: DesignProgress());
          }
          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<MyApplicationsBloc>()
                ..add(const MyApplicationsStarted());
              await bloc.stream.firstWhere(
                (s) => s.status != MyApplicationsStatus.loading,
              );
            },
            child: applications.items.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppEmptyView(
                          title: l10n.schemesNoApplications,
                          message: l10n.schemesNoApplicationsMessage,
                          icon: PhosphorIconsRegular.files,
                        ),
                      ),
                    ],
                  )
                : NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      final metrics = notification.metrics;
                      if (metrics.pixels >= metrics.maxScrollExtent * 0.8 &&
                          applications.hasMore &&
                          !state.loadingMore) {
                        context.read<MyApplicationsBloc>().add(
                          const MyApplicationsMoreRequested(),
                        );
                      }
                      return false;
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.pagePadding,
                      itemCount: applications.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final application = applications.items[index];
                        final id = application.id;
                        final canUpload = _openForUploads.contains(
                          application.status?.value,
                        );
                        return DesignCard(
                          title: application.scheme?.name ?? '--',
                          paddingChild: const EdgeInsets.fromLTRB(
                            14,
                            14,
                            14,
                            16,
                          ),
                          onTap: application.scheme?.id == null
                              ? null
                              : () => context.push(
                                  SchemesRouteNames.schemeDetailFor(
                                    application.scheme!.id!,
                                  ),
                                ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TitleDetailsCard(
                                title: l10n.schemesStatus,
                                text: application.status?.label ?? '--',
                                isFirstItem: true,
                                iconData: PhosphorIconsRegular.flag,
                                accentColor: DesignColor.accentType,
                              ),
                              TitleDetailsCard(
                                title: l10n.schemesAppliedOn,
                                text: switch (application.appliedAt) {
                                  final at? => date.format(at.toLocal()),
                                  null => '--',
                                },
                                iconData: PhosphorIconsRegular.calendarBlank,
                                accentColor: DesignColor.accentType,
                              ),
                              if (application.decisionNote case final note?)
                                TitleDetailsCard(
                                  title: l10n.schemesDecisionNote,
                                  text: note,
                                  isReadMore: true,
                                  iconData: PhosphorIconsRegular.chatText,
                                  accentColor: DesignColor.accentEnergy,
                                ),
                              if (application.amountApproved != null)
                                TitleDetailsCard(
                                  title: l10n.schemesAmountApproved,
                                  text: rupees(application.amountApproved),
                                  iconData: PhosphorIconsRegular.currencyInr,
                                  accentColor: DesignColor.accentPoints,
                                ),
                              if (application.amountDisbursed != null)
                                TitleDetailsCard(
                                  title: l10n.schemesAmountDisbursed,
                                  text: [
                                    rupees(application.amountDisbursed),
                                    if (DateTime.tryParse(
                                          application.disbursedOn ?? '',
                                        )
                                        case final on?)
                                      date.format(on),
                                  ].join(' · '),
                                  iconData: PhosphorIconsRegular.wallet,
                                  accentColor: DesignColor.accentPoints,
                                ),
                              for (final document
                                  in application.documents ?? const [])
                                TitleDetailsCard(
                                  title: document.name ?? '--',
                                  text: [
                                    if (document.uploaded ?? false)
                                      document.status?.label ?? '--'
                                    else
                                      l10n.schemesNotUploaded,
                                    ?document.remarks,
                                  ].join(' · '),
                                  iconData: (document.uploaded ?? false)
                                      ? PhosphorIconsRegular.fileCheck
                                      : PhosphorIconsRegular.fileArrowUp,
                                  accentColor: DesignColor.accentUin,
                                  showNavigateIcon: document.url != null,
                                  onTap: document.url == null
                                      ? null
                                      : () => Utils.launchUrl2(
                                          url: document.url!,
                                        ),
                                ),
                              if (id != null) ...[
                                if (canUpload)
                                  Wrap(
                                    spacing: AppSpacing.sm,
                                    children: [
                                      for (final document
                                          in application.documents ??
                                              const [])
                                        if (document.name != null &&
                                            document.status?.value !=
                                                'verified')
                                          TextButton.icon(
                                            onPressed: () => _upload(
                                              context,
                                              l10n,
                                              application: id,
                                              document: document.name!,
                                            ),
                                            icon: const Icon(
                                              PhosphorIconsRegular.uploadSimple,
                                            ),
                                            label: Text(
                                              '${(document.uploaded ?? false) ? l10n.schemesReplace : l10n.schemesUpload} '
                                              '${document.name}',
                                            ),
                                          ),
                                    ],
                                  ),
                                if (application.canWithdraw ?? false)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                      onPressed: () =>
                                          _withdraw(context, l10n, id),
                                      icon: const Icon(
                                        PhosphorIconsRegular.arrowUUpLeft,
                                      ),
                                      label: Text(l10n.schemesWithdraw),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}
