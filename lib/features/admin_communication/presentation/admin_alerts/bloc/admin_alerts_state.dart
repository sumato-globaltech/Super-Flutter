import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/admin_communication/model/admin_alert_model.dart';

enum AdminAlertsStatus { initial, loading, success, failure }

class AdminAlertsState extends Equatable {
  const AdminAlertsState({
    this.status = AdminAlertsStatus.initial,
    this.adminAlerts,
    this.loadingMore = false,
    this.errorMessage,
  });

  final AdminAlertsStatus status;
  final Paged<AdminAlertModel>? adminAlerts;
  final bool loadingMore;
  final String? errorMessage;

  AdminAlertsState copyWith({
    AdminAlertsStatus? status,
    Paged<AdminAlertModel>? adminAlerts,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return AdminAlertsState(
      status: status ?? this.status,
      adminAlerts: adminAlerts ?? this.adminAlerts,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, adminAlerts, loadingMore, errorMessage];
}
