import 'package:equatable/equatable.dart';

import 'facilities_state.dart';

sealed class FacilitiesEvent extends Equatable {
  const FacilitiesEvent();

  @override
  List<Object?> get props => [];
}

class FacilitiesStarted extends FacilitiesEvent {
  const FacilitiesStarted({this.filter});

  final FacilitiesFilter? filter;

  @override
  List<Object?> get props => [filter];
}

class FacilitiesMoreRequested extends FacilitiesEvent {
  const FacilitiesMoreRequested();
}
