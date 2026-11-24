import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/facilities/sources/remote/facilities_remote_data_source.dart';

import 'facility_stats_event.dart';
import 'facility_stats_state.dart';

@injectable
class FacilityStatsBloc extends Bloc<FacilityStatsEvent, FacilityStatsState> {
  FacilityStatsBloc(this._facilitiesRemoteDataSource)
    : super(const FacilityStatsState()) {
    on<FacilityStatsStarted>(_onStarted, transformer: restartable());
  }

  final FacilitiesRemoteDataSource _facilitiesRemoteDataSource;

  Future<void> _onStarted(
    FacilityStatsStarted event,
    Emitter<FacilityStatsState> emit,
  ) async {
    emit(state.copyWith(status: FacilityStatsStatus.loading));
    try {
      final facilityStats = await _facilitiesRemoteDataSource
          .getFacilityStats();
      emit(
        state.copyWith(
          status: FacilityStatsStatus.success,
          facilityStats: facilityStats,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FacilityStatsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FacilityStatsStatus.failure));
    }
  }
}
