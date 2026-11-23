import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/app/config/app_config.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/ui_gallery/routes/ui_gallery_route_names.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const DashboardStarted()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        actions: [
          if (!getIt<AppConfig>().isProduction)
            IconButton(
              tooltip: l10n.uiGallery,
              icon: const Icon(PhosphorIconsRegular.squaresFour),
              onPressed: () => context.push(UiGalleryRouteNames.root),
            ),
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.isSubmitting) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              // The value says whether every device is signed out.
              return PopupMenuButton<bool>(
                tooltip: l10n.signOut,
                icon: const Icon(Icons.logout_outlined),
                itemBuilder: (_) => [
                  PopupMenuItem(value: false, child: Text(l10n.signOut)),
                  PopupMenuItem(
                    value: true,
                    child: Text(l10n.signOutAllDevices),
                  ),
                ],
                onSelected: (allDevices) async {
                  final bloc = context.read<DashboardBloc>();
                  final confirmed = await ConfirmSheet.confirm(
                    context,
                    title: allDevices
                        ? l10n.signOutAllConfirmTitle
                        : l10n.signOutConfirmTitle,
                    description: allDevices
                        ? l10n.signOutAllConfirmMessage
                        : l10n.signOutConfirmMessage,
                    confirmText: allDevices
                        ? l10n.signOutAllDevices
                        : l10n.signOut,
                    icon: const Icon(Icons.logout_outlined),
                  );
                  if (confirmed) {
                    bloc.add(DashboardSignOutRequested(allDevices: allDevices));
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (prev, curr) =>
            prev.homeStatus != curr.homeStatus ||
            prev.banners != curr.banners ||
            prev.alerts != curr.alerts ||
            prev.notices != curr.notices,
        builder: (context, state) {
          final bloc = context.read<DashboardBloc>();
          final theme = Theme.of(context);
          if (!state.hasContent) {
            switch (state.homeStatus) {
              case DashboardHomeStatus.initial || DashboardHomeStatus.loading:
                return const Center(child: DesignProgress());
              case DashboardHomeStatus.failure:
                return AppErrorView(
                  message: state.errorMessage ?? l10n.errorUnknown,
                  retryLabel: l10n.tryAgain,
                  onRetry: () => bloc.add(const DashboardStarted()),
                );
              case DashboardHomeStatus.success:
                break;
            }
          }
          return RefreshIndicator(
            onRefresh: () async {
              bloc.add(const DashboardStarted());
              await bloc.stream.firstWhere(
                (s) => s.homeStatus != DashboardHomeStatus.loading,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: Padding(
                  padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!state.hasContent)
                        SizedBox(
                          height: 400,
                          child: AppEmptyView(
                            title: l10n.homeNothingNew,
                            message: l10n.homeNothingNewMessage,
                            icon: PhosphorIconsRegular.sun,
                          ),
                        ),
                      if (state.banners.isNotEmpty) ...[
                        SizedBox(
                          height: 160,
                          child: CarouselView(
                            itemExtent: MediaQuery.sizeOf(context).width * 0.86,
                            shrinkExtent: 200,
                            itemSnapping: true,
                            padding: const EdgeInsets.only(right: 8),
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onTap: (index) {
                              final link = state.banners[index].linkUrl;
                              if (link != null && link.isNotEmpty) {
                                Utils.launchUrl2(url: link);
                              }
                            },
                            children: [
                              for (final banner in state.banners)
                                Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (banner.imageUrl case final image?)
                                      CachedNetworkImage(
                                        imageUrl: image,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, _, _) =>
                                            const SizedBox.shrink(),
                                      ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          24,
                                          12,
                                          10,
                                        ),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black54,
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          banner.title ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (state.alerts.isNotEmpty) ...[
                        Text(
                          l10n.homeAlerts,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        for (final alert in state.alerts) ...[
                          DesignCard(
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
                                  title: [
                                    alert.severity?.label,
                                    (alert.statewide ?? false)
                                        ? l10n.homeStatewide
                                        : alert.district?.name,
                                  ].whereType<String>().join(' · '),
                                  text: alert.title ?? '-',
                                  isFirstItem: true,
                                  iconData: switch (alert.severity?.value) {
                                    'emergency' => PhosphorIconsRegular.siren,
                                    'warning' => PhosphorIconsRegular.warning,
                                    'watch' => PhosphorIconsRegular.eye,
                                    _ => PhosphorIconsRegular.info,
                                  },
                                  accentColor: switch (alert.severity?.value) {
                                    'emergency' => theme.colorScheme.error,
                                    'warning' => DesignColor.orange,
                                    'watch' => DesignColor.golden,
                                    _ => DesignColor.skyBlue,
                                  },
                                ),
                                if (alert.description case final description?
                                    when description.isNotEmpty)
                                  TitleDetailsCard(
                                    title: alert.category?.name ?? '',
                                    text: description,
                                    isReadMore: true,
                                    iconData: PhosphorIconsRegular.note,
                                    accentColor: DesignColor.accentEnergy,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 4),
                      ],
                      if (state.notices.isNotEmpty) ...[
                        Text(
                          l10n.homeNotices,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DesignCard(
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
                              for (final (index, notice)
                                  in state.notices.indexed)
                                TitleDetailsCard(
                                  title: [
                                    notice.category?.name,
                                    switch (notice.publishedAt) {
                                      final date? => DateFormat.yMMMd().format(
                                        date.toLocal(),
                                      ),
                                      null => null,
                                    },
                                  ].whereType<String>().join(' · '),
                                  text: notice.title ?? '-',
                                  isFirstItem: index == 0,
                                  iconData: PhosphorIconsRegular.megaphone,
                                  accentColor: notice.priority?.value == 'high'
                                      ? DesignColor.orange
                                      : DesignColor.accentName,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
