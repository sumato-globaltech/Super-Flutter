import 'package:equatable/equatable.dart';

sealed class EditAlertEvent extends Equatable {
  const EditAlertEvent();

  @override
  List<Object?> get props => [];
}

class EditAlertStarted extends EditAlertEvent {
  const EditAlertStarted();
}

class EditAlertFieldErrorCleared extends EditAlertEvent {
  const EditAlertFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class EditAlertSubmitted extends EditAlertEvent {
  const EditAlertSubmitted({
    required this.alert,
    required this.categoryId,
    this.districtId,
    required this.title,
    required this.description,
    required this.severity,
    required this.startsOn,
    this.endsOn,
  });

  final String alert;
  final String categoryId;
  final String? districtId;
  final String title;
  final String description;
  final String severity;
  final DateTime startsOn;
  final DateTime? endsOn;

  @override
  List<Object?> get props => [
    alert,
    categoryId,
    districtId,
    title,
    description,
    severity,
    startsOn,
    endsOn,
  ];
}
