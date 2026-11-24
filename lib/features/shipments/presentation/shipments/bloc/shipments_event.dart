import 'package:equatable/equatable.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';

sealed class ShipmentsEvent extends Equatable {
  const ShipmentsEvent();

  @override
  List<Object?> get props => [];
}

class ShipmentsStarted extends ShipmentsEvent {
  const ShipmentsStarted({this.open, this.party});

  final bool? open;
  final ShipmentParty? party;

  @override
  List<Object?> get props => [open, party];
}

class ShipmentsMoreRequested extends ShipmentsEvent {
  const ShipmentsMoreRequested();
}
