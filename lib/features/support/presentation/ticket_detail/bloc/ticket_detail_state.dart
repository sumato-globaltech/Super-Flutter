import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/support/model/ticket_model.dart';

enum TicketDetailStatus { initial, loading, success, failure }

class TicketDetailState extends Equatable {
  const TicketDetailState({
    this.status = TicketDetailStatus.initial,
    this.ticketDetails,
    this.errorMessage,
  });

  final TicketDetailStatus status;
  final TicketModel? ticketDetails;
  final String? errorMessage;

  TicketDetailState copyWith({
    TicketDetailStatus? status,
    TicketModel? ticketDetails,
    String? errorMessage,
  }) {
    return TicketDetailState(
      status: status ?? this.status,
      ticketDetails: ticketDetails ?? this.ticketDetails,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, ticketDetails, errorMessage];
}
