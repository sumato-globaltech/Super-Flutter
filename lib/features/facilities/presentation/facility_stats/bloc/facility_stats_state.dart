import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/facilities/model/facility_stats_model.dart';

enum FacilityStatsStatus { initial, loading, success, failure }

class FacilityStatsState extends Equatable {
  const FacilityStatsState({
    this.status = FacilityStatsStatus.initial,
    this.facilityStats,
    this.errorMessage,
  });

  final FacilityStatsStatus status;
  final FacilityStatsModel? facilityStats;
  final String? errorMessage;

  FacilityStatsState copyWith({
    FacilityStatsStatus? status,
    FacilityStatsModel? facilityStats,
    String? errorMessage,
  }) {
    return FacilityStatsState(
      status: status ?? this.status,
      facilityStats: facilityStats ?? this.facilityStats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, facilityStats, errorMessage];
}
