import 'package:equatable/equatable.dart';

sealed class EditNoticeEvent extends Equatable {
  const EditNoticeEvent();

  @override
  List<Object?> get props => [];
}

class EditNoticeStarted extends EditNoticeEvent {
  const EditNoticeStarted();
}

class EditNoticeFieldErrorCleared extends EditNoticeEvent {
  const EditNoticeFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class EditNoticeSubmitted extends EditNoticeEvent {
  const EditNoticeSubmitted({
    required this.notice,
    required this.categoryId,
    required this.title,
    this.body,
    required this.priority,
    this.expiresOn,
  });

  final String notice;
  final String categoryId;
  final String title;
  final String? body;
  final String priority;
  final DateTime? expiresOn;

  @override
  List<Object?> get props => [
    notice,
    categoryId,
    title,
    body,
    priority,
    expiresOn,
  ];
}
