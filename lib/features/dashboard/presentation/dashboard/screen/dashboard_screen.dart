import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/app/config/app_config.dart';
import 'package:super_flutter/core/constants/constants.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/features/communication/routes/communication_route_names.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/app/access/app_features.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/ai_sparkle.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/hide_on_scroll.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/farming_assistant/routes/farming_assistant_route_names.dart';
import 'package:super_flutter/features/crop_detector/routes/crop_detector_route_names.dart';
import 'package:super_flutter/features/market/routes/market_route_names.dart';
import 'package:super_flutter/features/schemes/routes/schemes_route_names.dart';
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
      child: const HideOnScroll(child: _DashboardView()),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAsk = context.select(
      (AuthCubit cubit) => appFeatures.canOpen(
        FarmingAssistantRouteNames.root,
        cubit.state.access,
      ),
    );
    return Scaffold(
      floatingActionButton: canAsk
          ? HideOnScrollButton(
              child: FloatingActionButton(
                heroTag: null,
                tooltip: l10n.farmingAssistantTitle,
                onPressed: () => context.push(FarmingAssistantRouteNames.root),
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
                child: const AiSparkle(size: 56, animate: true),
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(Constants.appName),
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
          final registry = appFeatures;
          final access = context.select(
            (AuthCubit cubit) => cubit.state.access,
          );
          final actions = registry.quickActions(
            access,
            home: DashboardRouteNames.dashboard,
          );
          final tabPaths = registry.tabPaths.toSet();
          const accents = [
            DesignColor.accentName,
            DesignColor.accentEnergy,
            DesignColor.accentPoints,
            DesignColor.accentUin,
            DesignColor.accentType,
            DesignColor.accentLocation,
          ];
          final promos = [
            (
              path: FarmingAssistantRouteNames.root,
              title: l10n.homePromoAssistantTitle,
              subtitle: l10n.homePromoAssistantSubtitle,
              cta: l10n.homePromoAssistantCta,
              icon: PhosphorIconsFill.sparkle,
              colors: const [Color(0xFF5B3FD9), Color(0xFF9B6BFF)],
            ),
            (
              path: CropDetectorRouteNames.root,
              title: l10n.homePromoDetectorTitle,
              subtitle: l10n.homePromoDetectorSubtitle,
              cta: l10n.homePromoDetectorCta,
              icon: PhosphorIconsFill.scan,
              colors: const [Color(0xFF006D37), Color(0xFF20C2B3)],
            ),
            (
              path: SchemesRouteNames.root,
              title: l10n.homePromoSchemesTitle,
              subtitle: l10n.homePromoSchemesSubtitle,
              cta: l10n.homePromoSchemesCta,
              icon: PhosphorIconsFill.scroll,
              colors: const [Color(0xFFE2620B), Color(0xFFFFB547)],
            ),
            (
              path: MarketRouteNames.market,
              title: l10n.homePromoMarketTitle,
              subtitle: l10n.homePromoMarketSubtitle,
              cta: l10n.homePromoMarketCta,
              icon: PhosphorIconsFill.chartLineUp,
              colors: const [Color(0xFF0B3D91), Color(0xFF2D8DD6)],
            ),
          ].where((p) => registry.canOpen(p.path, access)).toList();
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
                      if (promos.isNotEmpty) ...[
                        SizedBox(
                          height: 160,
                          child: CarouselView(
                            itemExtent: MediaQuery.sizeOf(context).width * 0.86,
                            shrinkExtent: 200,
                            itemSnapping: true,
                            padding: const EdgeInsets.only(right: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onTap: (index) {
                              final path = promos[index].path;
                              tabPaths.contains(path)
                                  ? context.go(path)
                                  : context.push(path);
                            },
                            children: [
                              for (final promo in promos)
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: promo.colors,
                                    ),
                                  ),
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth:
                                        MediaQuery.sizeOf(context).width *
                                            0.86 -
                                        8,
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width *
                                            0.86 -
                                        8,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: -30,
                                          top: -30,
                                          child: Container(
                                            width: 140,
                                            height: 140,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(
                                                alpha: 0.12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 40,
                                          bottom: -50,
                                          child: Container(
                                            width: 110,
                                            height: 110,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(
                                                alpha: 0.08,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 18,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: Container(
                                              width: 64,
                                              height: 64,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.35),
                                                ),
                                              ),
                                              child: Icon(
                                                promo.icon,
                                                size: 32,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            18,
                                            14,
                                            100,
                                            14,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                promo.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Flexible(
                                                child: Text(
                                                  promo.subtitle,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.85,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      promo.cta,
                                                      style: theme
                                                          .textTheme
                                                          .labelMedium
                                                          ?.copyWith(
                                                            color: promo
                                                                .colors
                                                                .first,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      PhosphorIconsBold
                                                          .arrowRight,
                                                      size: 14,
                                                      color: promo.colors.first,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (actions.isNotEmpty) ...[
                        Text(
                          l10n.homeQuickActions,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 0.85,
                          children: [
                            for (final (index, feature) in actions.indexed)
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                // A tab behind More is a branch of the shell.
                                onTap: () => tabPaths.contains(feature.path)
                                    ? context.go(feature.path)
                                    : context.push(feature.path),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: accents[index % accents.length]
                                            .withValues(
                                              alpha:
                                                  theme.brightness ==
                                                      Brightness.dark
                                                  ? 0.22
                                                  : 0.12,
                                            ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        feature.icon,
                                        color: accents[index % accents.length],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Flexible(
                                      child: Text(
                                        feature.title(l10n),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.labelMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (!state.hasContent)
                        switch (state.homeStatus) {
                          DashboardHomeStatus.initial ||
                          DashboardHomeStatus.loading => const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: DesignProgress()),
                          ),
                          DashboardHomeStatus.failure => SizedBox(
                            height: 320,
                            child: AppErrorView(
                              message: state.errorMessage ?? l10n.errorUnknown,
                              retryLabel: l10n.tryAgain,
                              onRetry: () => bloc.add(const DashboardStarted()),
                            ),
                          ),
                          DashboardHomeStatus.success => SizedBox(
                            height: 320,
                            child: AppEmptyView(
                              title: l10n.homeNothingNew,
                              message: l10n.homeNothingNewMessage,
                              icon: PhosphorIconsRegular.sun,
                            ),
                          ),
                        },
                      if (state.alerts.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.homeAlerts,
                              style: theme.textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push(CommunicationRouteNames.alerts),
                              child: Text(l10n.homeViewAllAlerts),
                            ),
                          ],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.homeNotices,
                              style: theme.textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push(CommunicationRouteNames.notices),
                              child: Text(l10n.homeViewAllNotices),
                            ),
                          ],
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
                                GestureDetector(
                                  onTap: () => context.push(
                                    CommunicationRouteNames.noticeDetail(
                                      notice.id!,
                                    ),
                                  ),
                                  child: TitleDetailsCard(
                                    title: [
                                      notice.category?.name,
                                      switch (notice.publishedAt) {
                                        final date? =>
                                          DateFormat.yMMMd().format(
                                            date.toLocal(),
                                          ),
                                        null => null,
                                      },
                                    ].whereType<String>().join(' · '),
                                    text: notice.title ?? '-',
                                    isFirstItem: index == 0,
                                    showNavigateIcon: true,
                                    iconData: PhosphorIconsRegular.megaphone,
                                    accentColor:
                                        notice.priority?.value == 'high'
                                        ? DesignColor.orange
                                        : DesignColor.accentName,
                                  ),
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
