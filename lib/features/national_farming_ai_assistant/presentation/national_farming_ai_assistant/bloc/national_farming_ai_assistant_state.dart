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
    this.questions,
    this.prefill,
  });

  final NationalFarmingAiAssistantStatus status;
  final List<AiMessage> messages;
  final String? errorMessage;
  final List<NationalFarmingAiAssistantLanguageModel> languages;
  final String language;
  final bool useLocation;
  final String? photo;

  /// Null while a crop's questions load, and empty when there are none.
  final List<String>? questions;
  final String? prefill;

  bool get isThinking => status == NationalFarmingAiAssistantStatus.thinking;

  NationalFarmingAiAssistantState copyWith({
    NationalFarmingAiAssistantStatus? status,
    List<AiMessage>? messages,
    String? Function()? errorMessage,
    List<NationalFarmingAiAssistantLanguageModel>? languages,
    String? language,
    bool? useLocation,
    String? Function()? photo,
    List<String>? questions,
    String? Function()? prefill,
  }) => NationalFarmingAiAssistantState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    languages: languages ?? this.languages,
    language: language ?? this.language,
    useLocation: useLocation ?? this.useLocation,
    photo: photo == null ? this.photo : photo(),
    questions: questions ?? this.questions,
    prefill: prefill == null ? this.prefill : prefill(),
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
    questions,
    prefill,
  ];
}
