import 'package:equatable/equatable.dart';

sealed class FarmingAssistantEvent extends Equatable {
  const FarmingAssistantEvent();

  @override
  List<Object?> get props => [];
}

class QuestionAsked extends FarmingAssistantEvent {
  const QuestionAsked(this.question);

  final String question;

  @override
  List<Object?> get props => [question];
}

/// Asks the last question again after it failed.
class QuestionRetried extends FarmingAssistantEvent {
  const QuestionRetried();
}

class ChatCleared extends FarmingAssistantEvent {
  const ChatCleared();
}
