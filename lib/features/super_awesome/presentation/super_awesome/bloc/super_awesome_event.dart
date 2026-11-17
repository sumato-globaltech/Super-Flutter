import 'package:equatable/equatable.dart';

sealed class SuperAwesomeEvent extends Equatable {
  const SuperAwesomeEvent();

  @override
  List<Object?> get props => [];
}

class SuperAwesomeStarted extends SuperAwesomeEvent {
  const SuperAwesomeStarted();
}
