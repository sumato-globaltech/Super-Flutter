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
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';
import 'package:super_flutter/features/shipments/presentation/shipments/bloc/shipments_bloc.dart';
import 'package:super_flutter/features/shipments/presentation/shipments/bloc/shipments_event.dart';
import 'package:super_flutter/features/shipments/presentation/shipments/bloc/shipments_state.dart';
import 'package:super_flutter/features/shipments/routes/shipments_route_names.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShipmentsBloc>()
        ..add(
          ShipmentsStarted(
            party: ShipmentParty.of(context.read<AuthCubit>().state.access),
          ),
        ),
      child: const _ShipmentsView(),
    );
  }
}

class _ShipmentsView extends StatelessWidget {
  const _ShipmentsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: l10n.shipmentsTitle),
      floatingActionButton: BlocSelector<ShipmentsBloc, ShipmentsState, bool>(
        selector: (state) => state.party == ShipmentParty.farmer,
        builder: (context, isFarmer) => !isFarmer
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                heroTag: null,
                onPressed: () async {
                  final created = await context.push<bool>(
                    ShipmentsRouteNames.requestShipment,
                  );
                  if (created == true && context.mounted) {
                    context.read<ShipmentsBloc>().add(
                      const ShipmentsStarted(open: true),
                    );
                  }
                },
                icon: const Icon(PhosphorIconsRegular.plus),
                label: Text(l10n.shipmentsRequest),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: AppSpacing.sm),
              child: BlocSelector<ShipmentsBloc, ShipmentsState, bool>(
                selector: (state) => state.open,
                builder: (context, open) => SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.shipmentsActive),
                        icon: const Icon(PhosphorIconsRegular.truck),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.shipmentsHistory),
                        icon: const Icon(
                          PhosphorIconsRegular.clockCounterClockwise,
                        ),
                      ),
                    ],
                    selected: {open},
                    onSelectionChanged: (selection) => context
                        .read<ShipmentsBloc>()
                        .add(ShipmentsStarted(open: selection.first)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocConsumer<ShipmentsBloc, ShipmentsState>(
                listenWhen: (prev, curr) =>
                    prev.status != curr.status &&
                    curr.status == ShipmentsStatus.failure &&
                    curr.shipments != null,
                listener: (context, state) => context.showSnackBar(
                  state.errorMessage ?? l10n.errorUnknown,
                  isError: true,
                ),
                builder: (context, state) {
                  final shipments = state.shipments;
                  if (shipments == null) {
                    if (state.status == ShipmentsStatus.failure) {
                      return AppErrorView(
                        message: state.errorMessage ?? l10n.errorUnknown,
                        retryLabel: l10n.tryAgain,
                        onRetry: () => context.read<ShipmentsBloc>().add(
                          const ShipmentsStarted(),
                        ),
                      );
                    }
                    return const Center(child: DesignProgress());
                  }
                  // The next page, unless one is loading or the last one failed.
                  // The bloc's own state is read: several asks can come in a frame.
                  void loadMore() {
                    final bloc = context.read<ShipmentsBloc>();
                    final now = bloc.state;
                    if ((now.shipments?.hasMore ?? false) &&
                        !now.loadingMore &&
                        now.status == ShipmentsStatus.success) {
                      bloc.add(const ShipmentsMoreRequested());
                    }
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final bloc = context.read<ShipmentsBloc>()
                        ..add(const ShipmentsStarted());
                      await bloc.stream.firstWhere(
                        (state) => state.status != ShipmentsStatus.loading,
                      );
                    },
                    child: shipments.items.isEmpty
                        ? CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: AppEmptyView(
                                  title: state.open
                                      ? l10n.shipmentsActiveEmpty
                                      : l10n.shipmentsHistoryEmpty,
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
                                  metrics.pixels >=
                                      metrics.maxScrollExtent * 0.8) {
                                loadMore();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: AppSpacing.pagePadding.copyWith(
                                bottom: 0,
                              ),
                              itemCount:
                                  shipments.items.length +
                                  (shipments.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == shipments.items.length) {
                                  final failed =
                                      state.status == ShipmentsStatus.failure &&
                                      !state.loadingMore;
                                  if (!failed) {
                                    // A list too short to scroll asks once its end is in view.
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (context.mounted) loadMore();
                                        });
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Center(
                                      child: failed
                                          ? TextButton(
                                              onPressed: () => context
                                                  .read<ShipmentsBloc>()
                                                  .add(
                                                    const ShipmentsMoreRequested(),
                                                  ),
                                              child: Text(l10n.tryAgain),
                                            )
                                          : const DesignProgress(),
                                    ),
                                  );
                                }
                                final shipment = shipments.items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: DesignCard(
                                    paddingChild: const EdgeInsets.fromLTRB(
                                      14,
                                      14,
                                      14,
                                      16,
                                    ),
                                    onTap: shipment.id == null
                                        ? null
                                        : () => context.push(
                                            ShipmentsRouteNames.shipmentDetailFor(
                                              shipment.id!,
                                            ),
                                          ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TitleDetailsCard(
                                          title: l10n.shipmentsNumber,
                                          text: shipment.number ?? '--',
                                          isFirstItem: true,
                                          showNavigateIcon: true,
                                          iconData:
                                              PhosphorIconsRegular.barcode,
                                          accentColor: DesignColor.accentUin,
                                        ),
                                        TitleDetailsCard(
                                          title: l10n.shipmentsStatus,
                                          text: shipment.status?.label ?? '--',
                                          iconData: PhosphorIconsRegular.flag,
                                          accentColor: DesignColor.accentType,
                                        ),
                                        TitleDetailsCard(
                                          title:
                                              state.party ==
                                                  ShipmentParty.vendor
                                              ? l10n.shipmentsFarmer
                                              : l10n.shipmentsVendor,
                                          text:
                                              (state.party ==
                                                          ShipmentParty.vendor
                                                      ? shipment.farmer
                                                      : shipment.vendor)
                                                  ?.name ??
                                              '--',
                                          iconData:
                                              PhosphorIconsRegular.storefront,
                                          accentColor: DesignColor.accentName,
                                        ),
                                        TitleDetailsCard(
                                          title: l10n.shipmentsPickupOn,
                                          text: switch (DateTime.tryParse(
                                            shipment.pickup?.preferredOn ?? '',
                                          )) {
                                            final date? =>
                                              DateFormat.yMMMd().format(date),
                                            null => '--',
                                          },
                                          iconData: PhosphorIconsRegular
                                              .calendarBlank,
                                          accentColor: DesignColor.accentType,
                                        ),
                                        TitleDetailsCard(
                                          title: l10n.shipmentsItems,
                                          text: [
                                            for (final item
                                                in shipment.items ?? const [])
                                              '${item.crop?.name ?? '--'} · '
                                                  '${NumberFormat.decimalPattern().format(item.quantitySold ?? 0)} '
                                                  '${item.unit?.name ?? ''}',
                                          ].join('\n'),
                                          iconData:
                                              PhosphorIconsRegular.package,
                                          accentColor:
                                              DesignColor.accentLocation,
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
          ],
        ),
      ),
    );
  }
}
