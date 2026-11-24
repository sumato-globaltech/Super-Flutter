import 'package:equatable/equatable.dart';

sealed class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => [];
}

class SupportStarted extends SupportEvent {
  const SupportStarted();
}

class SupportMoreRequested extends SupportEvent {
  const SupportMoreRequested();
}
