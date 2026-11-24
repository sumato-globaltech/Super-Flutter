import 'package:equatable/equatable.dart';

sealed class PublicationsEvent extends Equatable {
  const PublicationsEvent();

  @override
  List<Object?> get props => [];
}

class PublicationsStarted extends PublicationsEvent {
  const PublicationsStarted();
}

class PublicationsMoreRequested extends PublicationsEvent {
  const PublicationsMoreRequested();
}
