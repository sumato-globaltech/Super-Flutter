import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';

enum NoticesStatus { initial, loading, loaded, failure }

class NoticesState extends Equatable {
  const NoticesState({
    this.status = NoticesStatus.initial,
    this.notices,
    this.loadingMore = false,
    this.errorMessage,
  });

  final NoticesStatus status;
  final Paged<NoticeModel>? notices;
  final bool loadingMore;
  final String? errorMessage;

  List<NoticeModel> get items => notices?.items ?? const [];
  bool get hasMore => notices?.hasMore ?? false;

  NoticesState copyWith({
    NoticesStatus? status,
    Paged<NoticeModel>? notices,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return NoticesState(
      status: status ?? this.status,
      notices: notices ?? this.notices,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notices, loadingMore, errorMessage];
}
