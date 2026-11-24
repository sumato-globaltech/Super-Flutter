import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/shipments/model/assignment_options_model.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';

enum ShipmentAction { cancel, accept, reject, reassign, receive, reweigh }

sealed class ShipmentDetailEvent extends Equatable {
  const ShipmentDetailEvent();

  @override
  List<Object?> get props => [];
}

class ShipmentDetailStarted extends ShipmentDetailEvent {
  const ShipmentDetailStarted({
    required this.shipment,
    this.party = ShipmentParty.farmer,
  });

  final String shipment;
  final ShipmentParty party;

  @override
  List<Object?> get props => [shipment, party];
}

class ShipmentActionSubmitted extends ShipmentDetailEvent {
  const ShipmentActionSubmitted({
    required this.shipment,
    required this.action,
    required this.completer,
    this.reason,
    this.vehicleId,
    this.driverId,
    this.quantities,
    this.itemId,
    this.quantity,
  });

  final String shipment;
  final ShipmentAction action;
  final Completer<void> completer;
  final String? reason;
  final String? vehicleId;
  final String? driverId;
  final Map<String, double>? quantities;
  final String? itemId;
  final double? quantity;

  @override
  List<Object?> get props => [
    shipment,
    action,
    reason,
    vehicleId,
    driverId,
    quantities,
    itemId,
    quantity,
  ];
}

class ShipmentAssignmentOptionsRequested extends ShipmentDetailEvent {
  const ShipmentAssignmentOptionsRequested({
    required this.shipment,
    required this.completer,
  });

  final String shipment;
  final Completer<AssignmentOptionsModel?> completer;

  @override
  List<Object?> get props => [shipment];
}
