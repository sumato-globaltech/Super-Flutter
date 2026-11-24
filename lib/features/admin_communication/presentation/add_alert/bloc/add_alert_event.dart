import 'package:equatable/equatable.dart';

sealed class AddAlertEvent extends Equatable {
  const AddAlertEvent();

  @override
  List<Object?> get props => [];
}

class AddAlertStarted extends AddAlertEvent {
  const AddAlertStarted();
}

class AddAlertFieldErrorCleared extends AddAlertEvent {
  const AddAlertFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class AddAlertSubmitted extends AddAlertEvent {
  const AddAlertSubmitted({
    required this.categoryId,
    this.districtId,
    required this.title,
    required this.description,
    required this.severity,
    required this.startsOn,
    this.endsOn,
  });

  final String categoryId;
  final String? districtId;
  final String title;
  final String description;
  final String severity;
  final DateTime startsOn;
  final DateTime? endsOn;

  @override
  List<Object?> get props => [
    categoryId,
    districtId,
    title,
    description,
    severity,
    startsOn,
    endsOn,
  ];
}
