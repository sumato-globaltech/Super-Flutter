import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/app/access/app_features.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
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
import 'package:super_flutter/features/schemes/presentation/schemes/bloc/schemes_bloc.dart';
import 'package:super_flutter/features/schemes/presentation/schemes/bloc/schemes_event.dart';
import 'package:super_flutter/features/schemes/presentation/schemes/bloc/schemes_state.dart';
import 'package:super_flutter/features/schemes/routes/schemes_route_names.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final access = context.read<AuthCubit>().state.access;
        return getIt<SchemesBloc>()..add(
          SchemesStarted(
            officer:
                access.role != Roles.farmer &&
                access.can(Permissions.schemesView),
          ),
        );
      },
      child: const _SchemesView(),
    );
  }
}

class _SchemesView extends StatelessWidget {
  const _SchemesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(
        title: l10n.schemesTitle,
        actions: [
          if (context.select(
            (AuthCubit cubit) => appFeatures.canOpen(
              SchemesRouteNames.myApplications,
              cubit.state.access,
            ),
          ))
            TextButton.icon(
              onPressed: () => context.push(SchemesRouteNames.myApplications),
              icon: const Icon(PhosphorIconsRegular.files),
              label: Text(l10n.schemesMyApplications),
            ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<SchemesBloc, SchemesState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == SchemesStatus.failure &&
              curr.schemes != null,
          listener: (context, state) => context.showSnackBar(
            state.errorMessage ?? l10n.errorUnknown,
            isError: true,
          ),
          builder: (context, state) {
            final schemes = state.schemes;
            if (schemes == null) {
              if (state.status == SchemesStatus.failure) {
                return AppErrorView(
                  message: state.errorMessage ?? l10n.errorUnknown,
                  retryLabel: l10n.tryAgain,
                  onRetry: () =>
                      context.read<SchemesBloc>().add(const SchemesStarted()),
                );
              }
              return const Center(child: DesignProgress());
            }
            // The next page, unless one is loading or the last one failed.
            // The bloc's own state is read: several asks can come in a frame.
            void loadMore() {
              final bloc = context.read<SchemesBloc>();
              final now = bloc.state;
              if ((now.schemes?.hasMore ?? false) &&
                  !now.loadingMore &&
                  now.status == SchemesStatus.success) {
                bloc.add(const SchemesMoreRequested());
              }
            }

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<SchemesBloc>()
                  ..add(const SchemesStarted());
                await bloc.stream.firstWhere(
                  (state) => state.status != SchemesStatus.loading,
                );
              },
              child: schemes.items.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyView(
                            title: l10n.schemesEmpty,
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
                            schemes.items.length + (schemes.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == schemes.items.length) {
                            final failed =
                                state.status == SchemesStatus.failure &&
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
                                            .read<SchemesBloc>()
                                            .add(const SchemesMoreRequested()),
                                        child: Text(l10n.tryAgain),
                                      )
                                    : const DesignProgress(),
                              ),
                            );
                          }
                          final scheme = schemes.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: DesignCard(
                              paddingChild: const EdgeInsets.fromLTRB(
                                14,
                                14,
                                14,
                                16,
                              ),
                              onTap: scheme.id == null
                                  ? null
                                  : () => context.push(
                                      SchemesRouteNames.schemeDetailFor(
                                        scheme.id!,
                                      ),
                                    ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TitleDetailsCard(
                                    title: l10n.schemesName,
                                    text: scheme.name ?? '--',
                                    isFirstItem: true,
                                    showNavigateIcon: true,
                                    iconData:
                                        PhosphorIconsRegular.identificationCard,
                                    accentColor: DesignColor.accentName,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n.schemesCode,
                                    text: scheme.code ?? '--',
                                    iconData: PhosphorIconsRegular.barcode,
                                    accentColor: DesignColor.accentUin,
                                    isCopyable: true,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n.schemesIsOpen,
                                    text: switch (scheme.isOpen) {
                                      true => l10n.valueYes,
                                      false => l10n.valueNo,
                                      null => '--',
                                    },
                                    iconData: PhosphorIconsRegular.checkCircle,
                                    accentColor: DesignColor.accentPoints,
                                  ),
                                  TitleDetailsCard(
                                    title: l10n.schemesEndsOn,
                                    text: scheme.endsOn ?? '--',
                                    iconData:
                                        PhosphorIconsRegular.calendarBlank,
                                    accentColor: DesignColor.accentType,
                                  ),
                                  if (state.officer)
                                    TitleDetailsCard(
                                      title: l10n.schemesApplicationsCount,
                                      text: '${scheme.applicationsCount ?? 0}',
                                      iconData: PhosphorIconsRegular.users,
                                      accentColor: DesignColor.accentPoints,
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
