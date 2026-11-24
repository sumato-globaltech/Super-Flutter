import 'package:equatable/equatable.dart';

sealed class MeetingsEvent extends Equatable {
  const MeetingsEvent();

  @override
  List<Object?> get props => [];
}

class MeetingsStarted extends MeetingsEvent {
  const MeetingsStarted({this.district, this.farmer = false});

  final String? district;

  /// A farmer starts with their own district.
  final bool farmer;

  @override
  List<Object?> get props => [district, farmer];
}

class MeetingsMoreRequested extends MeetingsEvent {
  const MeetingsMoreRequested();
}
