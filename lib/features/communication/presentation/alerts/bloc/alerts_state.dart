import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/communication/model/alert_model.dart';

enum AlertsStatus { initial, loading, loaded, failure }

class AlertsState extends Equatable {
  const AlertsState({
    this.status = AlertsStatus.initial,
    this.alerts,
    this.loadingMore = false,
    this.errorMessage,
  });

  final AlertsStatus status;
  final Paged<AlertModel>? alerts;
  final bool loadingMore;
  final String? errorMessage;

  List<AlertModel> get items => alerts?.items ?? const [];
  bool get hasMore => alerts?.hasMore ?? false;

  AlertsState copyWith({
    AlertsStatus? status,
    Paged<AlertModel>? alerts,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return AlertsState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, alerts, loadingMore, errorMessage];
}
