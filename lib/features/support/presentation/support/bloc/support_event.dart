import 'dart:async';

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

class SupportCallBackRequested extends SupportEvent {
  const SupportCallBackRequested({required this.completer, this.question});

  final Completer<void> completer;
  final String? question;

  @override
  List<Object?> get props => [question];
}
