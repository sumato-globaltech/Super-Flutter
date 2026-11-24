import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';

enum ShipmentsStatus { initial, loading, success, failure }

class ShipmentsState extends Equatable {
  const ShipmentsState({
    this.status = ShipmentsStatus.initial,
    this.shipments,
    this.loadingMore = false,
    this.errorMessage,
    this.open = true,
    this.party = ShipmentParty.farmer,
  });

  final ShipmentsStatus status;
  final Paged<ShipmentModel>? shipments;
  final bool loadingMore;
  final String? errorMessage;
  final bool open;
  final ShipmentParty party;

  ShipmentsState copyWith({
    ShipmentsStatus? status,
    Paged<ShipmentModel>? shipments,
    bool? loadingMore,
    String? errorMessage,
    bool? open,
    ShipmentParty? party,
    bool clearShipments = false,
  }) {
    return ShipmentsState(
      status: status ?? this.status,
      shipments: clearShipments ? null : (shipments ?? this.shipments),
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
      open: open ?? this.open,
      party: party ?? this.party,
    );
  }

  @override
  List<Object?> get props => [
    status,
    shipments,
    loadingMore,
    errorMessage,
    open,
    party,
  ];
}
