import 'package:equatable/equatable.dart';

typedef AssistantMessage = ({String text, bool mine});

enum FarmingAssistantStatus { idle, thinking, failure }

class FarmingAssistantState extends Equatable {
  const FarmingAssistantState({
    this.status = FarmingAssistantStatus.idle,
    this.messages = const [],
    this.errorMessage,
  });

  final FarmingAssistantStatus status;
  final List<AssistantMessage> messages;
  final String? errorMessage;

  bool get isThinking => status == FarmingAssistantStatus.thinking;

  @override
  List<Object?> get props => [status, messages, errorMessage];
}
