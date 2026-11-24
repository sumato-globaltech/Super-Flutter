import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/shipments/model/shipment_options_model.dart';

enum RequestShipmentStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

class RequestShipmentState extends Equatable {
  const RequestShipmentState({
    this.status = RequestShipmentStatus.initial,
    this.options,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final RequestShipmentStatus status;
  final ShipmentOptionsModel? options;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  bool get isSubmitting => status == RequestShipmentStatus.submitting;

  RequestShipmentState copyWith({
    RequestShipmentStatus? status,
    ShipmentOptionsModel? options,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return RequestShipmentState(
      status: status ?? this.status,
      options: options ?? this.options,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [status, options, errorMessage, fieldErrors];
}
