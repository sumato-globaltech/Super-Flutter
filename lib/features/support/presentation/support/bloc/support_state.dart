import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/support/model/call_center_model.dart';
import 'package:super_flutter/data/support/model/ticket_model.dart';

enum SupportStatus { initial, loading, success, failure }

class SupportState extends Equatable {
  const SupportState({
    this.status = SupportStatus.initial,
    this.tickets,
    this.loadingMore = false,
    this.errorMessage,
    this.callCenter,
  });

  final SupportStatus status;
  final Paged<TicketModel>? tickets;
  final bool loadingMore;
  final String? errorMessage;
  final CallCenterModel? callCenter;

  SupportState copyWith({
    SupportStatus? status,
    Paged<TicketModel>? tickets,
    bool? loadingMore,
    String? errorMessage,
    CallCenterModel? callCenter,
  }) {
    return SupportState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
      callCenter: callCenter ?? this.callCenter,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tickets,
    loadingMore,
    errorMessage,
    callCenter,
  ];
}
