import 'package:equatable/equatable.dart';

sealed class CreateTicketEvent extends Equatable {
  const CreateTicketEvent();

  @override
  List<Object?> get props => [];
}

class CreateTicketStarted extends CreateTicketEvent {
  const CreateTicketStarted();
}

class CreateTicketFieldErrorCleared extends CreateTicketEvent {
  const CreateTicketFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class CreateTicketSubmitted extends CreateTicketEvent {
  const CreateTicketSubmitted({
    required this.categoryId,
    required this.subject,
    required this.question,
    this.cropId,
    this.photo,
  });

  final String categoryId;
  final String subject;
  final String question;
  final String? cropId;
  final String? photo;

  @override
  List<Object?> get props => [categoryId, subject, question, cropId, photo];
}
