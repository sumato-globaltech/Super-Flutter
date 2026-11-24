import 'package:equatable/equatable.dart';

sealed class MyApplicationsEvent extends Equatable {
  const MyApplicationsEvent();

  @override
  List<Object?> get props => [];
}

class MyApplicationsStarted extends MyApplicationsEvent {
  const MyApplicationsStarted();
}
