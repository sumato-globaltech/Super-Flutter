import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/admin_communication/model/admin_notice_model.dart';

enum AdminNoticesStatus { initial, loading, success, failure }

class AdminNoticesState extends Equatable {
  const AdminNoticesState({
    this.status = AdminNoticesStatus.initial,
    this.adminNotices,
    this.loadingMore = false,
    this.errorMessage,
  });

  final AdminNoticesStatus status;
  final Paged<AdminNoticeModel>? adminNotices;
  final bool loadingMore;
  final String? errorMessage;

  AdminNoticesState copyWith({
    AdminNoticesStatus? status,
    Paged<AdminNoticeModel>? adminNotices,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return AdminNoticesState(
      status: status ?? this.status,
      adminNotices: adminNotices ?? this.adminNotices,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, adminNotices, loadingMore, errorMessage];
}
