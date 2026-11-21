import 'package:equatable/equatable.dart';

sealed class DeepPostEvent extends Equatable {
  const DeepPostEvent();

  @override
  List<Object?> get props => [];
}

class DeepPostStarted extends DeepPostEvent {
  const DeepPostStarted();
}

class DeepPostFieldErrorCleared extends DeepPostEvent {
  const DeepPostFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class DeepPostSubmitted extends DeepPostEvent {
  const DeepPostSubmitted({this.name, this.districtId});

  final String? name;
  final String? districtId;

  @override
  List<Object?> get props => [name, districtId];
}
