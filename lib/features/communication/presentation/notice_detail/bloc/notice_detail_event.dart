import 'package:equatable/equatable.dart';

sealed class NoticeDetailEvent extends Equatable {
  const NoticeDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the notice, or reloads it on retry.
class NoticeDetailStarted extends NoticeDetailEvent {
  const NoticeDetailStarted({required this.noticeId});

  final String noticeId;

  @override
  List<Object?> get props => [noticeId];
}
