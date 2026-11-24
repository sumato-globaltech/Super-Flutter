import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/help_desk/model/queue_summary_model.dart';

enum QueueSummaryStatus { initial, loading, success, failure }

class QueueSummaryState extends Equatable {
  const QueueSummaryState({
    this.status = QueueSummaryStatus.initial,
    this.queueSummary,
    this.errorMessage,
  });

  final QueueSummaryStatus status;
  final QueueSummaryModel? queueSummary;
  final String? errorMessage;

  QueueSummaryState copyWith({
    QueueSummaryStatus? status,
    QueueSummaryModel? queueSummary,
    String? errorMessage,
  }) {
    return QueueSummaryState(
      status: status ?? this.status,
      queueSummary: queueSummary ?? this.queueSummary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, queueSummary, errorMessage];
}
