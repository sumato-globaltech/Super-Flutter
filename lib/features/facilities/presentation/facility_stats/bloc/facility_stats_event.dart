import 'package:equatable/equatable.dart';

sealed class FacilityStatsEvent extends Equatable {
  const FacilityStatsEvent();

  @override
  List<Object?> get props => [];
}

class FacilityStatsStarted extends FacilityStatsEvent {
  const FacilityStatsStarted();
}
