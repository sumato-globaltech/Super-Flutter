import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class SchemeDetailEvent extends Equatable {
  const SchemeDetailEvent();

  @override
  List<Object?> get props => [];
}

class SchemeDetailStarted extends SchemeDetailEvent {
  const SchemeDetailStarted({required this.scheme, this.farmer = false});

  final String scheme;
  final bool farmer;

  @override
  List<Object?> get props => [scheme, farmer];
}

class SchemeApplied extends SchemeDetailEvent {
  const SchemeApplied({required this.scheme, required this.completer});

  final String scheme;
  final Completer<void> completer;

  @override
  List<Object?> get props => [scheme];
}
