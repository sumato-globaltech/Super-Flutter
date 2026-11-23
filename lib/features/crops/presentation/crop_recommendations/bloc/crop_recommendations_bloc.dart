import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';

import 'crop_recommendations_event.dart';
import 'crop_recommendations_state.dart';

@injectable
class CropRecommendationsBloc
    extends Bloc<CropRecommendationsEvent, CropRecommendationsState> {
  CropRecommendationsBloc(this._remoteDataSource)
      : super(CropRecommendationsState(sowingMonth: DateTime.now().month)) {
    on<RecommendationsDistrictChanged>(_onDistrictChanged);
    on<RecommendationsMonthChanged>(_onMonthChanged);
    on<RecommendationsAreaChanged>(_onAreaChanged);
    on<RecommendationsSubmitted>(_onSubmitted);
  }

  final CropRemoteDataSource _remoteDataSource;

  void _onDistrictChanged(
    RecommendationsDistrictChanged event,
    Emitter<CropRecommendationsState> emit,
  ) {
    emit(state.copyWith(districtId: event.districtId));
  }

  void _onMonthChanged(
    RecommendationsMonthChanged event,
    Emitter<CropRecommendationsState> emit,
  ) {
    emit(state.copyWith(sowingMonth: event.month));
  }

  void _onAreaChanged(
    RecommendationsAreaChanged event,
    Emitter<CropRecommendationsState> emit,
  ) {
    emit(state.copyWith(areaHa: event.area));
  }

  Future<void> _onSubmitted(
    RecommendationsSubmitted event,
    Emitter<CropRecommendationsState> emit,
  ) async {
    if (state.districtId.trim().isEmpty) {
      emit(
        state.copyWith(
          status: RecommendationsStatus.failure,
          errorMessage: 'District is required',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RecommendationsStatus.loading));
    try {
      final result = await _remoteDataSource.getRecommendations(
        districtId: state.districtId.trim(),
        sowingMonth: state.sowingMonth,
        areaHa: state.areaHa,
      );
      if (result == null) {
        emit(
          state.copyWith(
            status: RecommendationsStatus.failure,
            errorMessage: 'No recommendations found',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: RecommendationsStatus.success,
          result: result,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RecommendationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
