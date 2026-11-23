import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
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
import 'package:super_flutter/features/auth/routes/auth_route_names.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/market/routes/market_route_names.dart';

import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select(
      (AuthCubit cubit) => cubit.state.isAuthenticated,
    );
    return BlocProvider(
      create: (_) => getIt<MarketBloc>()
        ..add(MarketStarted(isAuthenticated: isAuthenticated)),
      child: const _MarketView(),
    );
  }
}

class _MarketView extends StatelessWidget {
  const _MarketView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAuthenticated = context.select(
      (AuthCubit cubit) => cubit.state.isAuthenticated,
    );

    return Scaffold(
      appBar: AppTopBar(title: l10n.market),
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) {
          final bloc = context.read<MarketBloc>();
          return switch (state.status) {
            MarketStatus.initial ||
            MarketStatus.loading when state.items.isEmpty =>
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: DesignProgress(),
                ),
              ),
            MarketStatus.failure when state.items.isEmpty => AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => bloc.add(
                MarketStarted(isAuthenticated: isAuthenticated),
              ),
            ),
            _ => _buildContent(context, state, isAuthenticated),
          };
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MarketState state,
    bool isAuthenticated,
  ) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<MarketBloc>();
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(MarketStarted(isAuthenticated: isAuthenticated));
        await bloc.stream.firstWhere(
          (s) =>
              s.status != MarketStatus.loading &&
              s.status != MarketStatus.initial,
        );
      },
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (state.hasMore &&
              !state.loadingMore &&
              metrics.pixels > metrics.maxScrollExtent * 0.8) {
            bloc.add(const MarketMoreRequested());
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary Overview Card
                    if (state.summary != null &&
                        (state.summary!.crops?.isNotEmpty ?? false)) ...[
                      DesignCard(
                        title: l10n.marketSummaryTitle,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: TitleDetailsCard(
                                    title: '',
                                    text: l10n.marketReportingToday(
                                      state.summary!.marketsReportingToday ?? 0,
                                    ),
                                    isFirstItem: true,
                                    iconData: PhosphorIconsRegular.chartLineUp,
                                    accentColor: DesignColor.accentEnergy,
                                  ),
                                ),
                                Flexible(
                                  child: TitleDetailsCard(
                                    title: '',
                                    text: l10n.marketCropsTracked(
                                      state.summary!.cropsTracked ?? 0,
                                    ),
                                    isFirstItem: true,
                                    isCrossAxisAlignmentStart: false,
                                    iconData: PhosphorIconsRegular.plant,
                                    accentColor: DesignColor.accentPoints,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Mini horizontal scroll of top crop prices
                            SizedBox(
                              height: 64,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.summary!.crops!.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  final cropSummary =
                                      state.summary!.crops![idx];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cropSummary.crop?.name ?? '-',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${cropSummary.medianPrice ?? '-'} / ${state.summary!.priceUnit ?? 'qtl'}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: DesignColor.accentName,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Filter tabs: All vs Favourites
                    SegmentedButton<MarketFilter>(
                      segments: [
                        ButtonSegment(
                          value: MarketFilter.all,
                          label: Text(l10n.marketFilterAll),
                          icon: const Icon(PhosphorIconsRegular.storefront),
                        ),
                        ButtonSegment(
                          value: MarketFilter.favourites,
                          label: Text(l10n.marketFilterFavourites),
                          icon: const Icon(PhosphorIconsRegular.star),
                        ),
                      ],
                      selected: {state.filter},
                      onSelectionChanged: (set) {
                        final selected = set.first;
                        if (selected == MarketFilter.favourites &&
                            !isAuthenticated) {
                          _showSignInPrompt(context, l10n);
                          return;
                        }
                        bloc.add(MarketFilterChanged(selected));
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Market Cards List
            if (state.items.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: AppEmptyView(
                    title: state.filter == MarketFilter.favourites
                        ? l10n.marketFavouritesEmpty
                        : l10n.marketEmpty,
                    message: state.filter == MarketFilter.favourites
                        ? l10n.marketFavouritesEmptyMessage
                        : l10n.marketEmptyMessage,
                    icon: state.filter == MarketFilter.favourites
                        ? PhosphorIconsRegular.star
                        : PhosphorIconsRegular.storefront,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: AppSpacing.pagePadding.copyWith(top: 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= state.items.length) {
                        if (state.loadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: DesignProgress()),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final market = state.items[index];
                      final isFav = state.favouriteIds.contains(market.id) ||
                          market.isFavourite;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: DesignCard(
                          onTap: () => context.push(
                            MarketRouteNames.priceHistory(market.id!),
                            extra: market,
                          ),
                          actions: [
                            IconButton(
                              icon: Icon(
                                isFav
                                    ? PhosphorIconsFill.star
                                    : PhosphorIconsRegular.star,
                                color: isFav
                                    ? DesignColor.golden
                                    : theme.colorScheme.outline,
                                size: 20,
                              ),
                              onPressed: () {
                                if (!isAuthenticated) {
                                  _showSignInPrompt(context, l10n);
                                  return;
                                }
                                bloc.add(MarketFavouriteToggled(market));
                              },
                            ),
                          ],
                          paddingChild: const EdgeInsets.fromLTRB(
                            14,
                            14,
                            14,
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TitleDetailsCard(
                                title: [
                                  market.district?.name,
                                  market.type?.label,
                                  if (market.distanceKm != null)
                                    '${market.distanceKm} km',
                                ].whereType<String>().join(' · '),
                                text: market.name ?? '-',
                                isFirstItem: true,
                                showNavigateIcon: true,
                                iconData: PhosphorIconsRegular.storefront,
                                accentColor: DesignColor.accentName,
                              ),
                              if (market.address != null &&
                                  market.address!.isNotEmpty)
                                TitleDetailsCard(
                                  title: l10n.marketFieldAddress,
                                  text: market.address!,
                                  isReadMore: true,
                                  iconData: PhosphorIconsRegular.mapPin,
                                  accentColor: DesignColor.accentLocation,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: state.items.length +
                        (state.hasMore || state.loadingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSignInPrompt(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await ConfirmSheet.confirm(
      context,
      title: l10n.marketFilterFavourites,
      description: l10n.marketSignInForFavourites,
      confirmText: l10n.signIn,
      icon: const Icon(PhosphorIconsRegular.signIn),
    );
    if (confirmed && context.mounted) {
      context.push(AuthRouteNames.login);
    }
  }
}
