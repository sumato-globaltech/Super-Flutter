import 'package:equatable/equatable.dart';

sealed class TicketDetailEvent extends Equatable {
  const TicketDetailEvent();

  @override
  List<Object?> get props => [];
}

class TicketDetailStarted extends TicketDetailEvent {
  const TicketDetailStarted({required this.ticket});

  final String ticket;

  @override
  List<Object?> get props => [ticket];
}
