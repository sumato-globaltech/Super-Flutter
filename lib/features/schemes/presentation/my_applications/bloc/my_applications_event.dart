import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class MyApplicationsEvent extends Equatable {
  const MyApplicationsEvent();

  @override
  List<Object?> get props => [];
}

class MyApplicationsStarted extends MyApplicationsEvent {
  const MyApplicationsStarted();
}

class MyApplicationsMoreRequested extends MyApplicationsEvent {
  const MyApplicationsMoreRequested();
}

class ApplicationWithdrawn extends MyApplicationsEvent {
  const ApplicationWithdrawn({
    required this.application,
    required this.completer,
  });

  final String application;
  final Completer<void> completer;

  @override
  List<Object?> get props => [application];
}

class ApplicationDocumentUploaded extends MyApplicationsEvent {
  const ApplicationDocumentUploaded({
    required this.application,
    required this.name,
    required this.path,
    required this.completer,
  });

  final String application;
  final String name;
  final String path;
  final Completer<void> completer;

  @override
  List<Object?> get props => [application, name, path];
}
