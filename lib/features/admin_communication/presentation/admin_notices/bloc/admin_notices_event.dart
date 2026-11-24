import 'dart:async';

import 'package:equatable/equatable.dart';

enum AdminNoticeAction { publish, archive, restore, delete }

sealed class AdminNoticesEvent extends Equatable {
  const AdminNoticesEvent();

  @override
  List<Object?> get props => [];
}

class AdminNoticesStarted extends AdminNoticesEvent {
  const AdminNoticesStarted();
}

class AdminNoticesMoreRequested extends AdminNoticesEvent {
  const AdminNoticesMoreRequested();
}

class AdminNoticeActionSubmitted extends AdminNoticesEvent {
  const AdminNoticeActionSubmitted({
    required this.notice,
    required this.action,
    required this.completer,
  });

  final String notice;
  final AdminNoticeAction action;
  final Completer<void> completer;

  @override
  List<Object?> get props => [notice, action];
}
