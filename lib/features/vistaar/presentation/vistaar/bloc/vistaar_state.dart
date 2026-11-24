import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/ui/widgets/ai_chat.dart';
import 'package:super_flutter/data/vistaar/model/vistaar_language_model.dart';

enum VistaarStatus { idle, thinking, failure }

class VistaarState extends Equatable {
  const VistaarState({
    this.status = VistaarStatus.idle,
    this.messages = const [],
    this.errorMessage,
    this.languages = const [],
    this.language = 'en',
    this.useLocation = false,
    this.photo,
  });

  final VistaarStatus status;
  final List<AiMessage> messages;
  final String? errorMessage;
  final List<VistaarLanguageModel> languages;
  final String language;
  final bool useLocation;
  final String? photo;

  bool get isThinking => status == VistaarStatus.thinking;

  VistaarState copyWith({
    VistaarStatus? status,
    List<AiMessage>? messages,
    String? Function()? errorMessage,
    List<VistaarLanguageModel>? languages,
    String? language,
    bool? useLocation,
    String? Function()? photo,
  }) => VistaarState(
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
