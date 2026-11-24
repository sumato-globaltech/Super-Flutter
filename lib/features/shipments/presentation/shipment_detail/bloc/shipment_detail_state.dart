import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';

enum ShipmentDetailStatus { initial, loading, success, failure }

class ShipmentDetailState extends Equatable {
  const ShipmentDetailState({
    this.status = ShipmentDetailStatus.initial,
    this.shipmentDetails,
    this.errorMessage,
    this.party = ShipmentParty.farmer,
  });

  final ShipmentDetailStatus status;
  final ShipmentModel? shipmentDetails;
  final String? errorMessage;
  final ShipmentParty party;

  ShipmentDetailState copyWith({
    ShipmentDetailStatus? status,
    ShipmentModel? shipmentDetails,
    String? errorMessage,
    ShipmentParty? party,
  }) {
    return ShipmentDetailState(
      status: status ?? this.status,
      shipmentDetails: shipmentDetails ?? this.shipmentDetails,
      errorMessage: errorMessage,
      party: party ?? this.party,
    );
  }

  @override
  List<Object?> get props => [status, shipmentDetails, errorMessage, party];
}
