import 'package:equatable/equatable.dart';

sealed class AlertsEvent extends Equatable {
  const AlertsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page, or refreshes.
class AlertsStarted extends AlertsEvent {
  const AlertsStarted();
}

/// Loads the next page (load more).
class AlertsMoreRequested extends AlertsEvent {
  const AlertsMoreRequested();
}
