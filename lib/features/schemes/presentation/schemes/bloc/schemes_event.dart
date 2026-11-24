import 'package:equatable/equatable.dart';

sealed class SchemesEvent extends Equatable {
  const SchemesEvent();

  @override
  List<Object?> get props => [];
}

class SchemesStarted extends SchemesEvent {
  const SchemesStarted({this.officer});

  final bool? officer;

  @override
  List<Object?> get props => [officer];
}

class SchemesMoreRequested extends SchemesEvent {
  const SchemesMoreRequested();
}
