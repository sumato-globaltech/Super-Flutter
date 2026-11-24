import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the farmer profile; other users only have their account.
class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}
