import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/ui/widgets/ai_chat.dart';

enum FarmingAssistantStatus { idle, thinking, failure }

class FarmingAssistantState extends Equatable {
  const FarmingAssistantState({
    this.status = FarmingAssistantStatus.idle,
    this.messages = const [],
    this.errorMessage,
  });

  final FarmingAssistantStatus status;
  final List<AiMessage> messages;
  final String? errorMessage;

  bool get isThinking => status == FarmingAssistantStatus.thinking;

  @override
  List<Object?> get props => [status, messages, errorMessage];
}
