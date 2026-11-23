import 'package:equatable/equatable.dart';

sealed class NoticesEvent extends Equatable {
  const NoticesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page, or refreshes.
class NoticesStarted extends NoticesEvent {
  const NoticesStarted();
}

/// Loads the next page (load more).
class NoticesMoreRequested extends NoticesEvent {
  const NoticesMoreRequested();
}
