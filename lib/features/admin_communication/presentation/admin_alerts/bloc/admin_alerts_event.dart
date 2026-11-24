import 'dart:async';

import 'package:equatable/equatable.dart';

enum AdminAlertAction { activate, cancel, delete }

sealed class AdminAlertsEvent extends Equatable {
  const AdminAlertsEvent();

  @override
  List<Object?> get props => [];
}

class AdminAlertsStarted extends AdminAlertsEvent {
  const AdminAlertsStarted();
}

class AdminAlertsMoreRequested extends AdminAlertsEvent {
  const AdminAlertsMoreRequested();
}

class AdminAlertActionSubmitted extends AdminAlertsEvent {
  const AdminAlertActionSubmitted({
    required this.alert,
    required this.action,
    required this.completer,
  });

  final String alert;
  final AdminAlertAction action;
  final Completer<void> completer;

  @override
  List<Object?> get props => [alert, action];
}
