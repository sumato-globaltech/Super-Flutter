import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';

enum FarmFormStatus { initial, loading, success, failure }

class FarmFormState extends Equatable {
  final FarmFormStatus status;
  final FarmModel? farm;
  final String? errorMessage;

  const FarmFormState({
    this.status = FarmFormStatus.initial,
    this.farm,
    this.errorMessage,
  });

  bool get isEditing => farm != null && farm!.id != null;

  FarmFormState copyWith({
    FarmFormStatus? status,
    FarmModel? farm,
    String? errorMessage,
  }) {
    return FarmFormState(
      status: status ?? this.status,
      farm: farm ?? this.farm,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, farm, errorMessage];
}
