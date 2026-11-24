import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/ui/widgets/ai_chat.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/model/national_farming_ai_assistant_language_model.dart';

enum NationalFarmingAiAssistantStatus { idle, thinking, failure }

class NationalFarmingAiAssistantState extends Equatable {
  const NationalFarmingAiAssistantState({
    this.status = NationalFarmingAiAssistantStatus.idle,
    this.messages = const [],
    this.errorMessage,
    this.languages = const [],
    this.language = 'en',
    this.useLocation = false,
    this.photo,
  });

  final NationalFarmingAiAssistantStatus status;
  final List<AiMessage> messages;
  final String? errorMessage;
  final List<NationalFarmingAiAssistantLanguageModel> languages;
  final String language;
  final bool useLocation;
  final String? photo;

  bool get isThinking => status == NationalFarmingAiAssistantStatus.thinking;

  NationalFarmingAiAssistantState copyWith({
    NationalFarmingAiAssistantStatus? status,
    List<AiMessage>? messages,
    String? Function()? errorMessage,
    List<NationalFarmingAiAssistantLanguageModel>? languages,
    String? language,
    bool? useLocation,
    String? Function()? photo,
  }) => NationalFarmingAiAssistantState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    languages: languages ?? this.languages,
    language: language ?? this.language,
    useLocation: useLocation ?? this.useLocation,
    photo: photo == null ? this.photo : photo(),
  );

  @override
  List<Object?> get props => [
    status,
    messages,
    errorMessage,
    languages,
    language,
    useLocation,
    photo,
  ];
}
