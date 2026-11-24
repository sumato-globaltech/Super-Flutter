import 'package:equatable/equatable.dart';

sealed class NationalFarmingAiAssistantEvent extends Equatable {
  const NationalFarmingAiAssistantEvent();

  @override
  List<Object?> get props => [];
}

class NationalFarmingAiAssistantStarted
    extends NationalFarmingAiAssistantEvent {
  const NationalFarmingAiAssistantStarted({this.crop});

  /// The slug of the crop the questions are about.
  final String? crop;

  @override
  List<Object?> get props => [crop];
}

sealed class NationalFarmingAiAssistantChatEvent
    extends NationalFarmingAiAssistantEvent {
  const NationalFarmingAiAssistantChatEvent();
}

class NationalFarmingAiAssistantAsked
    extends NationalFarmingAiAssistantChatEvent {
  const NationalFarmingAiAssistantAsked(this.question);

  final String question;

  @override
  List<Object?> get props => [question];
}

/// Asks the last question again after it failed.
class NationalFarmingAiAssistantRetried
    extends NationalFarmingAiAssistantChatEvent {
  const NationalFarmingAiAssistantRetried();
}

class NationalFarmingAiAssistantCleared
    extends NationalFarmingAiAssistantChatEvent {
  const NationalFarmingAiAssistantCleared();
}

class NationalFarmingAiAssistantLanguageChosen
    extends NationalFarmingAiAssistantEvent {
  const NationalFarmingAiAssistantLanguageChosen(this.language);

  final String language;

  @override
  List<Object?> get props => [language];
}

class NationalFarmingAiAssistantLocationToggled
    extends NationalFarmingAiAssistantEvent {
  const NationalFarmingAiAssistantLocationToggled({required this.useLocation});

  final bool useLocation;

  @override
  List<Object?> get props => [useLocation];
}

/// A null [photo] takes the chosen one away.
class NationalFarmingAiAssistantPhotoChosen
    extends NationalFarmingAiAssistantEvent {
  const NationalFarmingAiAssistantPhotoChosen(this.photo);

  final String? photo;

  @override
  List<Object?> get props => [photo];
}
