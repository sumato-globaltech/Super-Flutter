import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';

enum NoticeDetailStatus { initial, loading, loaded, failure }

class NoticeDetailState extends Equatable {
  const NoticeDetailState({
    this.status = NoticeDetailStatus.initial,
    this.notice,
    this.errorMessage,
  });

  final NoticeDetailStatus status;
  final NoticeModel? notice;
  final String? errorMessage;

  bool get isLoading => status == NoticeDetailStatus.loading;

  NoticeDetailState copyWith({
    NoticeDetailStatus? status,
    NoticeModel? notice,
    String? errorMessage,
  }) {
    return NoticeDetailState(
      status: status ?? this.status,
      notice: notice ?? this.notice,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notice, errorMessage];
}
