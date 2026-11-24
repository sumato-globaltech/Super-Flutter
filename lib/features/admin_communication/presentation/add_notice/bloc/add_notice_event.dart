import 'package:equatable/equatable.dart';

sealed class AddNoticeEvent extends Equatable {
  const AddNoticeEvent();

  @override
  List<Object?> get props => [];
}

class AddNoticeStarted extends AddNoticeEvent {
  const AddNoticeStarted();
}

class AddNoticeFieldErrorCleared extends AddNoticeEvent {
  const AddNoticeFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class AddNoticeSubmitted extends AddNoticeEvent {
  const AddNoticeSubmitted({
    required this.categoryId,
    required this.title,
    this.body,
    required this.priority,
    this.expiresOn,
  });

  final String categoryId;
  final String title;
  final String? body;
  final String priority;
  final DateTime? expiresOn;

  @override
  List<Object?> get props => [categoryId, title, body, priority, expiresOn];
}
