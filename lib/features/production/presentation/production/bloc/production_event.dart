import 'package:equatable/equatable.dart';
import 'package:super_flutter/features/production/presentation/production/bloc/production_state.dart';

sealed class ProductionEvent extends Equatable {
  const ProductionEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the insights, with the current filter unless [filter] is given.
class ProductionStarted extends ProductionEvent {
  const ProductionStarted({this.filter});

  final ProductionFilter? filter;

  @override
  List<Object?> get props => [filter];
}
