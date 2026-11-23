import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/communication/model/alert_model.dart';
import 'package:super_flutter/data/communication/model/banner_model.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';

enum DashboardStatus { initial, submitting, success, failure }

enum DashboardHomeStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.errorMessage,
    this.homeStatus = DashboardHomeStatus.initial,
    this.banners = const [],
    this.alerts = const [],
    this.notices = const [],
  });

  /// Signing out.
  final DashboardStatus status;
  final String? errorMessage;

  /// The home's content: each section shows what it could load.
  final DashboardHomeStatus homeStatus;
  final List<BannerModel> banners;
  final List<AlertModel> alerts;
  final List<NoticeModel> notices;

  bool get isSubmitting => status == DashboardStatus.submitting;

  bool get hasContent =>
      banners.isNotEmpty || alerts.isNotEmpty || notices.isNotEmpty;

  DashboardState copyWith({
    DashboardStatus? status,
    String? errorMessage,
    DashboardHomeStatus? homeStatus,
    List<BannerModel>? banners,
    List<AlertModel>? alerts,
    List<NoticeModel>? notices,
  }) {
    return DashboardState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      homeStatus: homeStatus ?? this.homeStatus,
      banners: banners ?? this.banners,
      alerts: alerts ?? this.alerts,
      notices: notices ?? this.notices,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    homeStatus,
    banners,
    alerts,
    notices,
  ];
}
