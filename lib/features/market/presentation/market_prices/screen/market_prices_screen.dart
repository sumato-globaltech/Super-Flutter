import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/data/market/model/market_model.dart';

import '../bloc/market_prices_bloc.dart';
import '../bloc/market_prices_event.dart';
import '../bloc/market_prices_state.dart';

class MarketPricesScreen extends StatelessWidget {
  const MarketPricesScreen({
    required this.marketId,
    this.market,
    super.key,
  });

  final String marketId;
  final MarketModel? market;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MarketPricesBloc>()
        ..add(MarketPricesStarted(marketId: marketId)),
      child: _MarketPricesView(marketId: marketId, market: market),
    );
  }
}

class _MarketPricesView extends StatelessWidget {
  const _MarketPricesView({
    required this.marketId,
    this.market,
  });

  final String marketId;
  final MarketModel? market;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = market?.name ?? l10n.marketPriceHistoryTitle;

    return Scaffold(
      appBar: AppTopBar(title: title),
      body: BlocBuilder<MarketPricesBloc, MarketPricesState>(
        builder: (context, state) {
          final bloc = context.read<MarketPricesBloc>();
          return switch (state.status) {
            MarketPricesStatus.initial ||
            MarketPricesStatus.loading when state.items.isEmpty =>
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: DesignProgress(),
                ),
              ),
            MarketPricesStatus.failure when state.items.isEmpty => AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => bloc.add(MarketPricesStarted(marketId: marketId)),
            ),
            _ => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MarketPricesState state) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<MarketPricesBloc>();

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(MarketPricesStarted(marketId: marketId));
        await bloc.stream.firstWhere(
          (s) =>
              s.status != MarketPricesStatus.loading &&
              s.status != MarketPricesStatus.initial,
        );
      },
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (state.hasMore &&
              !state.loadingMore &&
              metrics.pixels > metrics.maxScrollExtent * 0.8) {
            bloc.add(const MarketPricesMoreRequested());
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Market Info Card (if market details available)
            if (market != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DesignCard(
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TitleDetailsCard(
                                    title: l10n.marketFieldDistrict,
                                    text: market!.district?.name ?? '--',
                                    isFirstItem: true,
                                    iconData: PhosphorIconsRegular.mapPin,
                                    accentColor: DesignColor.accentLocation,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TitleDetailsCard(
                                    title: l10n.marketFieldType,
                                    text: market!.type?.label ?? '--',
                                    iconData: PhosphorIconsRegular.tag,
                                    accentColor: DesignColor.accentType,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TitleDetailsCard(
                                    title: l10n.marketFieldAddress,
                                    text: market!.address?.isNotEmpty == true
                                        ? market!.address!
                                        : '--',
                                    isReadMore: true,
                                    iconData: PhosphorIconsRegular.buildings,
                                    accentColor: DesignColor.accentName,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TitleDetailsCard(
                                    title: l10n.marketFieldLocation,
                                    text: market!.latitude != null &&
                                            market!.longitude != null
                                        ? '${market!.latitude!.toStringAsFixed(4)}, ${market!.longitude!.toStringAsFixed(4)}'
                                        : '--',
                                    iconData: PhosphorIconsRegular.navigationArrow,
                                    accentColor: DesignColor.accentLocation,
                                    onTap: market!.latitude != null &&
                                            market!.longitude != null
                                        ? () => Utils.navigateToMapLocation(
                                              '${market!.latitude!}',
                                              '${market!.longitude!}',
                                            )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TitleDetailsCard(
                                    title: l10n.marketFieldFacilities,
                                    text: market!.facilities != null &&
                                            market!.facilities!.isNotEmpty
                                        ? market!.facilities!.join(', ')
                                        : '--',
                                    iconData: PhosphorIconsRegular.checkCircle,
                                    accentColor: DesignColor.accentPoints,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

            // Price History List
            if (state.items.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: AppEmptyView(
                    title: l10n.marketPriceHistoryEmpty,
                    message: l10n.marketPriceHistoryEmptyMessage,
                    icon: PhosphorIconsRegular.currencyInr,
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

                      final price = state.items[index];
                      final dateFormatted = price.priceDate != null
                          ? DateFormat.yMMMd().format(
                              DateTime.tryParse(price.priceDate!)?.toLocal() ??
                                  DateTime.now(),
                            )
                          : '-';

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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TitleDetailsCard(
                                title: dateFormatted,
                                text: price.crop?.name ?? '-',
                                isFirstItem: true,
                                iconData: PhosphorIconsRegular.plant,
                                accentColor: DesignColor.accentEnergy,
                              ),
                              TitleDetailsCard(
                                title: l10n.marketPricePerUnit(
                                  '${price.modalPrice ?? '-'}',
                                  price.unit?.code ?? 'unit',
                                ),
                                text: l10n.marketPriceRange(
                                  '${price.minPrice ?? '-'}',
                                  '${price.maxPrice ?? '-'}',
                                ),
                                iconData: PhosphorIconsRegular.currencyInr,
                                accentColor: DesignColor.accentPoints,
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
}
