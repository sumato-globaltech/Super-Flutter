import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/data/shipments/model/assignment_options_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_detail/bloc/shipment_detail_bloc.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_detail/bloc/shipment_detail_event.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_detail/bloc/shipment_detail_state.dart';

class ShipmentDetailScreen extends StatelessWidget {
  const ShipmentDetailScreen({super.key, required this.shipment});

  final String shipment;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShipmentDetailBloc>()
        ..add(
          ShipmentDetailStarted(
            shipment: shipment,
            party: ShipmentParty.of(context.read<AuthCubit>().state.access),
          ),
        ),
      child: _ShipmentDetailView(shipment: shipment),
    );
  }
}

class _ShipmentDetailView extends StatelessWidget {
  const _ShipmentDetailView({required this.shipment});

  final String shipment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quantity = NumberFormat.decimalPattern();
    return Scaffold(
      appBar: AppTopBar(title: l10n.shipmentsShipmentDetailTitle),
      bottomNavigationBar:
          BlocSelector<ShipmentDetailBloc, ShipmentDetailState, List<String>>(
            selector: (state) => [
              for (final action in state.shipmentDetails?.actions ?? const [])
                if (action is String) action,
            ],
            builder: (context, actions) {
              final error = Theme.of(context).colorScheme.error;
              final buttons = <Widget?>[
                for (final action in actions)
                  switch (action) {
                    'accept' => FilledButton.icon(
                      onPressed: () =>
                          _assignSheet(context, l10n, ShipmentAction.accept),
                      icon: const Icon(PhosphorIconsRegular.checkCircle),
                      label: Text(l10n.shipmentsAccept),
                    ),
                    'reject' => OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: error),
                      onPressed: () => _reasonSheet(
                        context,
                        l10n,
                        action: ShipmentAction.reject,
                        title: l10n.shipmentsRejectTitle,
                        message: l10n.shipmentsRejectMessage,
                        confirm: l10n.shipmentsReject,
                        done: l10n.shipmentsRejected,
                      ),
                      icon: const Icon(PhosphorIconsRegular.xCircle),
                      label: Text(l10n.shipmentsReject),
                    ),
                    'cancel' => OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: error),
                      onPressed: () => _reasonSheet(
                        context,
                        l10n,
                        action: ShipmentAction.cancel,
                        title: l10n.shipmentsCancelTitle,
                        message: l10n.shipmentsCancelMessage,
                        confirm: l10n.shipmentsCancel,
                        done: l10n.shipmentsCancelled,
                      ),
                      icon: const Icon(PhosphorIconsRegular.xCircle),
                      label: Text(l10n.shipmentsCancel),
                    ),
                    'reassign' => OutlinedButton.icon(
                      onPressed: () =>
                          _assignSheet(context, l10n, ShipmentAction.reassign),
                      icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
                      label: Text(l10n.shipmentsReassign),
                    ),
                    'receive' => FilledButton.icon(
                      onPressed: () => _quantitiesSheet(
                        context,
                        l10n,
                        action: ShipmentAction.receive,
                        title: l10n.shipmentsReceiveTitle,
                        message: l10n.shipmentsReceiveMessage,
                        confirm: l10n.shipmentsReceive,
                        done: l10n.shipmentsReceived,
                        prefill: (item) =>
                            item.quantityPicked ?? item.quantitySold,
                      ),
                      icon: const Icon(PhosphorIconsRegular.package),
                      label: Text(l10n.shipmentsReceive),
                    ),
                    'reweigh' => OutlinedButton.icon(
                      onPressed: () => _reweighSheet(context, l10n),
                      icon: const Icon(PhosphorIconsRegular.scales),
                      label: Text(l10n.shipmentsReweigh),
                    ),
                    'record_picked' => OutlinedButton.icon(
                      onPressed: () => _quantitiesSheet(
                        context,
                        l10n,
                        action: ShipmentAction.recordPicked,
                        title: l10n.shipmentsRecordPickedTitle,
                        message: l10n.shipmentsRecordPickedMessage,
                        confirm: l10n.shipmentsSave,
                        done: l10n.shipmentsPickedSaved,
                        prefill: (item) =>
                            item.quantityPicked ?? item.quantitySold,
                      ),
                      icon: const Icon(PhosphorIconsRegular.scales),
                      label: Text(l10n.shipmentsRecordPicked),
                    ),
                    'pickup' => FilledButton.icon(
                      onPressed: () => _quantitiesSheet(
                        context,
                        l10n,
                        action: ShipmentAction.pickup,
                        title: l10n.shipmentsPickupTitle,
                        message: l10n.shipmentsPickupMessage,
                        confirm: l10n.shipmentsConfirmPickup,
                        done: l10n.shipmentsPickedUp,
                        prefill: (item) =>
                            item.quantityPicked ?? item.quantitySold,
                      ),
                      icon: const Icon(PhosphorIconsRegular.truck),
                      label: Text(l10n.shipmentsConfirmPickup),
                    ),
                    'reach' => FilledButton.icon(
                      onPressed: () => ConfirmSheet.show<void>(
                        context,
                        ConfirmSheet(
                          title: l10n.shipmentsReachTitle,
                          description: l10n.shipmentsReachMessage,
                          confirmText: l10n.shipmentsMarkReached,
                          onPressed: () => _send(
                            context,
                            l10n.shipmentsReachedDone,
                            (completer) => ShipmentActionSubmitted(
                              shipment: shipment,
                              action: ShipmentAction.reach,
                              completer: completer,
                            ),
                          ),
                        ),
                      ),
                      icon: const Icon(PhosphorIconsRegular.flagCheckered),
                      label: Text(l10n.shipmentsMarkReached),
                    ),
                    _ => null,
                  },
              ].whereType<Widget>().toList();
              if (buttons.isEmpty) return const SizedBox.shrink();
              return SafeArea(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Row(
                    children: [
                      for (final (index, button) in buttons.indexed) ...[
                        if (index > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(child: button),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      body: BlocBuilder<ShipmentDetailBloc, ShipmentDetailState>(
        builder: (context, state) {
          if (state.status == ShipmentDetailStatus.failure &&
              state.shipmentDetails == null) {
            return AppErrorView(
              message: state.errorMessage ?? l10n.errorUnknown,
              retryLabel: l10n.tryAgain,
              onRetry: () => context.read<ShipmentDetailBloc>().add(
                ShipmentDetailStarted(shipment: shipment, party: state.party),
              ),
            );
          }
          final shipmentDetails = state.shipmentDetails;
          final status = shipmentDetails?.status;
          final vendor = shipmentDetails?.vendor;
          final pickup = shipmentDetails?.pickup;
          final vehicle = shipmentDetails?.vehicle;
          final driver = shipmentDetails?.driver;
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: AppSpacing.pagePadding.copyWith(bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DesignCard(
                      title: l10n.shipmentsShipmentDetailDetails,
                      paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.shipmentsShipmentDetailNumber,
                                  text: shipmentDetails == null
                                      ? ''
                                      : shipmentDetails.number ?? '--',
                                  isTextLoading: shipmentDetails == null,
                                  isFirstItem: true,
                                  iconData: PhosphorIconsRegular.barcode,
                                  accentColor: DesignColor.accentUin,
                                  isCopyable: true,
                                ),
                              ),
                              Flexible(
                                child: TitleDetailsCard(
                                  title:
                                      l10n.shipmentsShipmentDetailRequestedAt,
                                  text: shipmentDetails == null
                                      ? ''
                                      : switch (shipmentDetails.requestedAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: shipmentDetails == null,
                                  isFirstItem: true,
                                  isCrossAxisAlignmentStart: false,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.shipmentsShipmentDetailAcceptedAt,
                                  text: shipmentDetails == null
                                      ? ''
                                      : switch (shipmentDetails.acceptedAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: shipmentDetails == null,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.shipmentsShipmentDetailPickedUpAt,
                                  text: shipmentDetails == null
                                      ? ''
                                      : switch (shipmentDetails.pickedUpAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: shipmentDetails == null,
                                  isCrossAxisAlignmentStart: false,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.shipmentsShipmentDetailReachedAt,
                                  text: shipmentDetails == null
                                      ? ''
                                      : switch (shipmentDetails.reachedAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: shipmentDetails == null,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.shipmentsShipmentDetailReceivedAt,
                                  text: shipmentDetails == null
                                      ? ''
                                      : switch (shipmentDetails.receivedAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: shipmentDetails == null,
                                  isCrossAxisAlignmentStart: false,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TitleDetailsCard(
                                  title: l10n.shipmentsShipmentDetailRejectedAt,
                                  text: shipmentDetails == null
                                      ? ''
                                      : switch (shipmentDetails.rejectedAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: shipmentDetails == null,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                              Flexible(
                                child: TitleDetailsCard(
                                  title:
                                      l10n.shipmentsShipmentDetailCancelledAt,
                                  text: shipmentDetails == null
                                      ? ''
                                      : switch (shipmentDetails.cancelledAt) {
                                          final date? =>
                                            DateFormat.yMMMd().format(date),
                                          null => '--',
                                        },
                                  isTextLoading: shipmentDetails == null,
                                  isCrossAxisAlignmentStart: false,
                                  iconData: PhosphorIconsRegular.calendarBlank,
                                  accentColor: DesignColor.accentType,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title:
                                      l10n.shipmentsShipmentDetailRejectReason,
                                  text: shipmentDetails == null
                                      ? ''
                                      : shipmentDetails.rejectReason ?? '--',
                                  isTextLoading: shipmentDetails == null,
                                  iconData: PhosphorIconsRegular.note,
                                  accentColor: DesignColor.accentEnergy,
                                  isReadMore: true,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title:
                                      l10n.shipmentsShipmentDetailCancelReason,
                                  text: shipmentDetails == null
                                      ? ''
                                      : shipmentDetails.cancelReason ?? '--',
                                  isTextLoading: shipmentDetails == null,
                                  iconData: PhosphorIconsRegular.note,
                                  accentColor: DesignColor.accentEnergy,
                                  isReadMore: true,
                                ),
                              ),
                            ],
                          ),
                          if (state.party != ShipmentParty.farmer)
                            TitleDetailsCard(
                              title: l10n.shipmentsFarmer,
                              text: shipmentDetails == null
                                  ? ''
                                  : shipmentDetails.farmer?.name ?? '--',
                              isTextLoading: shipmentDetails == null,
                              iconData: PhosphorIconsRegular.user,
                              accentColor: DesignColor.accentName,
                            ),
                          TitleDetailsCard(
                            title: l10n.shipmentsStatus,
                            text: shipmentDetails == null
                                ? ''
                                : status?.label ?? '--',
                            isTextLoading: shipmentDetails == null,
                            iconData: PhosphorIconsRegular.flag,
                            accentColor: DesignColor.accentType,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TitleDetailsCard(
                                  title: l10n.shipmentsShipmentDetailNotes,
                                  text: shipmentDetails == null
                                      ? ''
                                      : shipmentDetails.notes ?? '--',
                                  isTextLoading: shipmentDetails == null,
                                  iconData: PhosphorIconsRegular.note,
                                  accentColor: DesignColor.accentEnergy,
                                  isReadMore: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (shipmentDetails == null ||
                        (shipmentDetails.items ?? const []).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      DesignCard(
                        title: l10n.shipmentsItems,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (shipmentDetails == null)
                              const TitleDetailsCard(
                                title: '',
                                text: '',
                                isTextLoading: true,
                                isFirstItem: true,
                              ),
                            for (final (index, item)
                                in (shipmentDetails?.items ?? const []).indexed)
                              TitleDetailsCard(
                                title: item.crop?.name ?? '--',
                                text: [
                                  '${quantity.format(item.quantitySold ?? 0)} ${item.unit?.name ?? ''}',
                                  if (item.quantityPicked != null)
                                    '${l10n.shipmentsPicked}: ${quantity.format(item.quantityPicked)}',
                                  if (item.quantityReceived != null)
                                    '${l10n.shipmentsReceived}: ${quantity.format(item.quantityReceived)}',
                                ].join(' · '),
                                isFirstItem: index == 0,
                                iconData: PhosphorIconsRegular.package,
                                accentColor: DesignColor.accentLocation,
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (shipmentDetails == null ||
                        shipmentDetails.vendor != null) ...[
                      const SizedBox(height: 8),
                      DesignCard(
                        title: l10n.shipmentsShipmentDetailVendor,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TitleDetailsCard(
                                    title:
                                        l10n.shipmentsShipmentDetailVendorName,
                                    text: vendor == null
                                        ? ''
                                        : vendor.name ?? '--',
                                    isTextLoading: vendor == null,
                                    isFirstItem: true,
                                    iconData: PhosphorIconsRegular.storefront,
                                    accentColor: DesignColor.accentName,
                                  ),
                                ),
                                Flexible(
                                  child: TitleDetailsCard(
                                    title:
                                        l10n.shipmentsShipmentDetailVendorCode,
                                    text: vendor == null
                                        ? ''
                                        : vendor.code ?? '--',
                                    isTextLoading: vendor == null,
                                    isFirstItem: true,
                                    isCrossAxisAlignmentStart: false,
                                    iconData: PhosphorIconsRegular.barcode,
                                    accentColor: DesignColor.accentUin,
                                    isCopyable: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (shipmentDetails == null ||
                        shipmentDetails.pickup != null) ...[
                      const SizedBox(height: 8),
                      DesignCard(
                        title: l10n.shipmentsShipmentDetailPickup,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TitleDetailsCard(
                                    title: l10n
                                        .shipmentsShipmentDetailPickupAddress,
                                    text: pickup == null
                                        ? ''
                                        : pickup.address ?? '--',
                                    isTextLoading: pickup == null,
                                    isFirstItem: true,
                                    iconData: PhosphorIconsRegular.mapPin,
                                    accentColor: DesignColor.accentLocation,
                                    isReadMore: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TitleDetailsCard(
                                    title: l10n
                                        .shipmentsShipmentDetailPickupPreferredOn,
                                    text: pickup == null
                                        ? ''
                                        : pickup.preferredOn ?? '--',
                                    isTextLoading: pickup == null,
                                    iconData:
                                        PhosphorIconsRegular.calendarBlank,
                                    accentColor: DesignColor.accentType,
                                  ),
                                ),
                                Flexible(
                                  child: TitleDetailsCard(
                                    title:
                                        l10n.shipmentsShipmentDetailPickupLate,
                                    text: pickup == null
                                        ? ''
                                        : switch (pickup.late) {
                                            true => l10n.valueYes,
                                            false => l10n.valueNo,
                                            null => '--',
                                          },
                                    isTextLoading: pickup == null,
                                    isCrossAxisAlignmentStart: false,
                                    iconData: PhosphorIconsRegular.checkCircle,
                                    accentColor: DesignColor.accentPoints,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (shipmentDetails == null ||
                        shipmentDetails.vehicle != null) ...[
                      const SizedBox(height: 8),
                      DesignCard(
                        title: l10n.shipmentsShipmentDetailVehicle,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TitleDetailsCard(
                                    title: l10n.shipmentsVehicleType,
                                    text: vehicle == null
                                        ? ''
                                        : vehicle.type?.label ?? '--',
                                    isTextLoading: vehicle == null,
                                    isFirstItem: true,
                                    iconData: PhosphorIconsRegular.truck,
                                    accentColor: DesignColor.accentType,
                                  ),
                                ),
                                Flexible(
                                  child: TitleDetailsCard(
                                    title: l10n
                                        .shipmentsShipmentDetailVehicleRegistrationNumber,
                                    text: vehicle == null
                                        ? ''
                                        : vehicle.registrationNumber ?? '--',
                                    isTextLoading: vehicle == null,
                                    isFirstItem: true,
                                    isCrossAxisAlignmentStart: false,
                                    iconData: PhosphorIconsRegular.barcode,
                                    accentColor: DesignColor.accentUin,
                                    isCopyable: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (shipmentDetails == null ||
                        shipmentDetails.driver != null) ...[
                      const SizedBox(height: 8),
                      DesignCard(
                        title: l10n.shipmentsShipmentDetailDriver,
                        paddingChild: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TitleDetailsCard(
                                    title:
                                        l10n.shipmentsShipmentDetailDriverName,
                                    text: driver == null
                                        ? ''
                                        : driver.name ?? '--',
                                    isTextLoading: driver == null,
                                    isFirstItem: true,
                                    iconData:
                                        PhosphorIconsRegular.identificationCard,
                                    accentColor: DesignColor.accentName,
                                  ),
                                ),
                                Flexible(
                                  child: TitleDetailsCard(
                                    title:
                                        l10n.shipmentsShipmentDetailDriverCode,
                                    text: driver == null
                                        ? ''
                                        : driver.code ?? '--',
                                    isTextLoading: driver == null,
                                    isFirstItem: true,
                                    isCrossAxisAlignmentStart: false,
                                    iconData: PhosphorIconsRegular.barcode,
                                    accentColor: DesignColor.accentUin,
                                    isCopyable: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TitleDetailsCard(
                                    title:
                                        l10n.shipmentsShipmentDetailDriverPhone,
                                    text: driver == null
                                        ? ''
                                        : driver.phone ?? '--',
                                    isTextLoading: driver == null,
                                    isCrossAxisAlignmentStart: false,
                                    iconData: PhosphorIconsRegular.phone,
                                    accentColor: DesignColor.accentUin,
                                    onTap: driver?.phone == null
                                        ? null
                                        : () => Utils.launchUrl2(
                                            url: 'tel:${driver?.phone}',
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _send(
    BuildContext context,
    String done,
    ShipmentActionSubmitted Function(Completer<void> completer) event,
  ) async {
    final completer = Completer<void>();
    context.read<ShipmentDetailBloc>().add(event(completer));
    await completer.future;
    if (context.mounted) {
      Navigator.of(context).pop();
      context.showSnackBar(done);
    }
  }

  void _reasonSheet(
    BuildContext context,
    AppLocalizations l10n, {
    required ShipmentAction action,
    required String title,
    required String message,
    required String confirm,
    required String done,
  }) {
    final formKey = GlobalKey<FormState>();
    final reasonCtrl = TextEditingController();
    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: title,
        description: message,
        confirmText: confirm,
        confirmColor: Theme.of(context).colorScheme.error,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonCtrl,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: '${l10n.shipmentsReason} *',
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? l10n.fieldRequired(l10n.shipmentsReason)
                  : null,
            ),
          ),
        ),
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          await _send(
            context,
            done,
            (completer) => ShipmentActionSubmitted(
              shipment: shipment,
              action: action,
              reason: reasonCtrl.text.trim(),
              completer: completer,
            ),
          );
        },
      ),
    );
  }

  Future<void> _assignSheet(
    BuildContext context,
    AppLocalizations l10n,
    ShipmentAction action,
  ) async {
    final bloc = context.read<ShipmentDetailBloc>();
    final loaded = Completer<AssignmentOptionsModel?>();
    bloc.add(
      ShipmentAssignmentOptionsRequested(shipment: shipment, completer: loaded),
    );
    AssignmentOptionsModel? options;
    try {
      options = await loaded.future;
    } on AppException catch (e) {
      if (context.mounted) context.showSnackBar(e.message, isError: true);
      return;
    }
    if (!context.mounted || options == null) return;
    final current = bloc.state.shipmentDetails;
    final formKey = GlobalKey<FormState>();
    String? vehicleId = action == ShipmentAction.reassign
        ? current?.vehicle?.id
        : null;
    String? driverId = action == ShipmentAction.reassign
        ? current?.driver?.id
        : null;
    final vehicles = options.vehicles ?? const [];
    final drivers = options.drivers ?? const [];
    if (!vehicles.any((v) => v.id == vehicleId)) vehicleId = null;
    if (!drivers.any((d) => d.id == driverId)) driverId = null;
    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: action == ShipmentAction.accept
            ? l10n.shipmentsAcceptTitle
            : l10n.shipmentsReassignTitle,
        description: l10n.shipmentsAssignMessage,
        confirmText: action == ShipmentAction.accept
            ? l10n.shipmentsAccept
            : l10n.shipmentsReassign,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: vehicleId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '${l10n.shipmentsShipmentDetailVehicle} *',
                    prefixIcon: const Icon(PhosphorIconsRegular.truck),
                  ),
                  items: [
                    for (final vehicle in vehicles)
                      DropdownMenuItem(
                        value: vehicle.id,
                        child: Text(
                          [
                            vehicle.registrationNumber ?? '--',
                            ?vehicle.type?.label,
                            if (vehicle.onTrip ?? false) l10n.shipmentsOnTrip,
                          ].join(' · '),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => vehicleId = value,
                  validator: (value) => value == null
                      ? l10n.fieldRequired(l10n.shipmentsShipmentDetailVehicle)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: driverId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '${l10n.shipmentsShipmentDetailDriver} *',
                    prefixIcon: const Icon(PhosphorIconsRegular.steeringWheel),
                  ),
                  items: [
                    for (final driver in drivers)
                      DropdownMenuItem(
                        value: driver.id,
                        child: Text(
                          [driver.name ?? '--', ?driver.code].join(' · '),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => driverId = value,
                  validator: (value) => value == null
                      ? l10n.fieldRequired(l10n.shipmentsShipmentDetailDriver)
                      : null,
                ),
              ],
            ),
          ),
        ),
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          await _send(
            context,
            action == ShipmentAction.accept
                ? l10n.shipmentsAccepted
                : l10n.shipmentsReassigned,
            (completer) => ShipmentActionSubmitted(
              shipment: shipment,
              action: action,
              vehicleId: vehicleId,
              driverId: driverId,
              completer: completer,
            ),
          );
        },
      ),
    );
  }

  String? _quantityError(AppLocalizations l10n, String? value) {
    final quantity = double.tryParse((value ?? '').trim());
    return quantity == null || quantity < 0
        ? l10n.shipmentsInvalidWeighed
        : null;
  }

  void _quantitiesSheet(
    BuildContext context,
    AppLocalizations l10n, {
    required ShipmentAction action,
    required String title,
    required String message,
    required String confirm,
    required String done,
    required double? Function(ItemModel item) prefill,
  }) {
    final items = [
      for (final item
          in context.read<ShipmentDetailBloc>().state.shipmentDetails?.items ??
              const <ItemModel>[])
        if (item.id != null) item,
    ];
    final format = NumberFormat('0.###');
    final formKey = GlobalKey<FormState>();
    final controllers = {
      for (final item in items)
        item.id!: TextEditingController(
          text: format.format(prefill(item) ?? 0),
        ),
    };
    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: title,
        description: message,
        confirmText: confirm,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in items) ...[
                  TextFormField(
                    controller: controllers[item.id],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,3}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: '${item.crop?.name ?? '--'} *',
                      suffixText: item.unit?.name,
                      helperText:
                          '${l10n.shipmentsSold}: ${format.format(item.quantitySold ?? 0)}',
                    ),
                    validator: (value) => _quantityError(l10n, value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ),
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          await _send(
            context,
            done,
            (completer) => ShipmentActionSubmitted(
              shipment: shipment,
              action: action,
              quantities: {
                for (final entry in controllers.entries)
                  entry.key: double.parse(entry.value.text.trim()),
              },
              completer: completer,
            ),
          );
        },
      ),
    );
  }

  void _reweighSheet(BuildContext context, AppLocalizations l10n) {
    final items = [
      for (final item
          in context.read<ShipmentDetailBloc>().state.shipmentDetails?.items ??
              const <ItemModel>[])
        if (item.id != null) item,
    ];
    if (items.isEmpty) return;
    final format = NumberFormat('0.###');
    final formKey = GlobalKey<FormState>();
    final quantityCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    var item = items.first;
    void fill() => quantityCtrl.text = format.format(
      item.quantityReceived ?? item.quantitySold ?? 0,
    );
    fill();
    ConfirmSheet.show<void>(
      context,
      ConfirmSheet(
        title: l10n.shipmentsReweighTitle,
        description: l10n.shipmentsReweighMessage,
        confirmText: l10n.shipmentsReweigh,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (items.length > 1) ...[
                  DropdownButtonFormField<ItemModel>(
                    initialValue: item,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: '${l10n.shipmentsItem} *',
                      prefixIcon: const Icon(PhosphorIconsRegular.package),
                    ),
                    items: [
                      for (final option in items)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.crop?.name ?? '--'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      item = value;
                      fill();
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                TextFormField(
                  controller: quantityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,3}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: '${l10n.shipmentsQuantity} *',
                    suffixText: item.unit?.name,
                  ),
                  validator: (value) => _quantityError(l10n, value),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: reasonCtrl,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.shipmentsReason),
                ),
              ],
            ),
          ),
        ),
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          final reason = reasonCtrl.text.trim();
          await _send(
            context,
            l10n.shipmentsReweighed,
            (completer) => ShipmentActionSubmitted(
              shipment: shipment,
              action: ShipmentAction.reweigh,
              itemId: item.id,
              quantity: double.parse(quantityCtrl.text.trim()),
              reason: reason.isEmpty ? null : reason,
              completer: completer,
            ),
          );
        },
      ),
    );
  }
}
