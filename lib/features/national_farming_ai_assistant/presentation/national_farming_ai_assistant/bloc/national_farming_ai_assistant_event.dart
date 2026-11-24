import 'package:equatable/equatable.dart';

sealed class VistaarEvent extends Equatable {
  const VistaarEvent();

  @override
  List<Object?> get props => [];
}

class VistaarStarted extends VistaarEvent {
  const VistaarStarted();
}

sealed class VistaarChatEvent extends VistaarEvent {
  const VistaarChatEvent();
}

class VistaarAsked extends VistaarChatEvent {
  const VistaarAsked(this.question);

  final String question;

  @override
  List<Object?> get props => [question];
}

/// Asks the last question again after it failed.
class VistaarRetried extends VistaarChatEvent {
  const VistaarRetried();
}

class VistaarCleared extends VistaarChatEvent {
  const VistaarCleared();
}

class VistaarLanguageChosen extends VistaarEvent {
  const VistaarLanguageChosen(this.language);

  final String language;

  @override
  List<Object?> get props => [language];
}

class VistaarLocationToggled extends VistaarEvent {
  const VistaarLocationToggled({required this.useLocation});

  final bool useLocation;

  @override
  List<Object?> get props => [useLocation];
}

/// A null [photo] takes the chosen one away.
class VistaarPhotoChosen extends VistaarEvent {
  const VistaarPhotoChosen(this.photo);

  final String? photo;

  @override
  List<Object?> get props => [photo];
}
