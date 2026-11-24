import 'package:equatable/equatable.dart';

sealed class QueueSummaryEvent extends Equatable {
  const QueueSummaryEvent();

  @override
  List<Object?> get props => [];
}

class QueueSummaryStarted extends QueueSummaryEvent {
  const QueueSummaryStarted();
}
