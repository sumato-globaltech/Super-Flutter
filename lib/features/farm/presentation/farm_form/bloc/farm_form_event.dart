import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';

sealed class FarmFormEvent extends Equatable {
  const FarmFormEvent();

  @override
  List<Object?> get props => [];
}

class FarmFormInitialized extends FarmFormEvent {
  final FarmModel? initialFarm;

  const FarmFormInitialized({this.initialFarm});

  @override
  List<Object?> get props => [initialFarm];
}

class FarmFormSubmitted extends FarmFormEvent {
  final Map<String, dynamic> data;

  const FarmFormSubmitted(this.data);

  @override
  List<Object?> get props => [data];
}
