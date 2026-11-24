import 'package:equatable/equatable.dart';

sealed class RequestShipmentEvent extends Equatable {
  const RequestShipmentEvent();

  @override
  List<Object?> get props => [];
}

class RequestShipmentStarted extends RequestShipmentEvent {
  const RequestShipmentStarted();
}

class RequestShipmentFieldErrorCleared extends RequestShipmentEvent {
  const RequestShipmentFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class RequestShipmentSubmitted extends RequestShipmentEvent {
  const RequestShipmentSubmitted({
    required this.vendorId,
    required this.pickupDistrictId,
    required this.pickupAddress,
    required this.preferredPickupOn,
    required this.items,
    this.notes,
  });

  final String vendorId;
  final String pickupDistrictId;
  final String pickupAddress;
  final DateTime preferredPickupOn;
  final List<Map<String, dynamic>> items;
  final String? notes;

  @override
  List<Object?> get props => [
    vendorId,
    pickupDistrictId,
    pickupAddress,
    preferredPickupOn,
    items,
    notes,
  ];
}
