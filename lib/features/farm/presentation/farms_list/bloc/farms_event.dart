import 'package:equatable/equatable.dart';

sealed class FarmsEvent extends Equatable {
  const FarmsEvent();

  @override
  List<Object?> get props => [];
}

class FarmsStarted extends FarmsEvent {
  final String status;

  const FarmsStarted({this.status = 'active'});

  @override
  List<Object?> get props => [status];
}

class FarmsStatusFilterChanged extends FarmsEvent {
  final String status;

  const FarmsStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class FarmsRefreshed extends FarmsEvent {
  const FarmsRefreshed();
}

class FarmsMoreRequested extends FarmsEvent {
  const FarmsMoreRequested();
}
