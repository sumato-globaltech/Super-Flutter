import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';
import 'package:super_flutter/data/meetings/model/district_option_model.dart';
import 'package:super_flutter/data/meetings/sources/remote/meetings_remote_data_source.dart';

import 'crop_recommendations_event.dart';
import 'crop_recommendations_state.dart';

@injectable
class CropRecommendationsBloc
    extends Bloc<CropRecommendationsEvent, CropRecommendationsState> {
  CropRecommendationsBloc(this._remoteDataSource, this._meetingsRemoteDataSource)
      : super(CropRecommendationsState(sowingMonth: DateTime.now().month)) {
    on<RecommendationsStarted>(_onStarted, transformer: droppable());
    on<RecommendationsCropChanged>(_onCropChanged);
    on<RecommendationsDistrictChanged>(_onDistrictChanged);
    on<RecommendationsMonthChanged>(_onMonthChanged);
    on<RecommendationsAreaChanged>(_onAreaChanged);
    on<RecommendationsSubmitted>(_onSubmitted);
  }

  final CropRemoteDataSource _remoteDataSource;
  final MeetingsRemoteDataSource _meetingsRemoteDataSource;

  static const _cropsPerPage = 100;

  Future<List<CropModel>> _allCrops() async {
    final crops = <CropModel>[];
    int? page = 1;
    while (page != null) {
      final paged = await _remoteDataSource.getCrops(
        page: page,
        perPage: _cropsPerPage,
      );
      crops.addAll(paged.items);
      page = paged.nextPage;
    }
    return crops;
  }

  Future<void> _onStarted(
    RecommendationsStarted event,
    Emitter<CropRecommendationsState> emit,
  ) async {
    emit(state.copyWith(optionsStatus: RecommendationsStatus.loading));
    try {
      final results = await Future.wait([
        _meetingsRemoteDataSource.getDistrictList(),
        _allCrops(),
      ]);
      final districts = results[0] as List<DistrictOptionModel>;
      final crops = results[1] as List<CropModel>;
      emit(
        state.copyWith(
          districts: districts,
          crops: crops,
          districtId: districts.any((d) => d.id == state.districtId)
              ? state.districtId
              : districts.firstOrNull?.id ?? '',
          cropSlug:
              crops.any((c) => c.slug == state.cropSlug) ? state.cropSlug : '',
        ),
      );
    } catch (e) {
      _emitOptionsFailure(e, emit);
      return;
    }
    await _loadMonths(emit);
  }

  Future<void> _loadMonths(Emitter<CropRecommendationsState> emit) async {
    final cropSlug = state.cropSlug;
    final districtId = state.districtId;
    // A later crop or district choice loads its own months.
    bool stale() =>
        state.cropSlug != cropSlug || state.districtId != districtId;

    emit(state.copyWith(optionsStatus: RecommendationsStatus.loading));
    try {
      final months = await _remoteDataSource.getSowingMonths(
        crop: cropSlug.isEmpty ? null : cropSlug,
        districtId: districtId.isEmpty ? null : districtId,
      );
      if (stale()) return;
      emit(
        state.copyWith(
          optionsStatus: RecommendationsStatus.success,
          months: months,
          sowingMonth: months.any((m) => m.number == state.sowingMonth)
              ? state.sowingMonth
              : months.firstOrNull?.number,
        ),
      );
    } catch (e) {
      if (stale()) return;
      _emitOptionsFailure(e, emit);
    }
  }

  void _emitOptionsFailure(
    Object? error,
    Emitter<CropRecommendationsState> emit,
  ) {
    emit(
      state.copyWith(
        optionsStatus: RecommendationsStatus.failure,
        optionsError: error is AppException ? error.message : null,
      ),
    );
  }

  Future<void> _onCropChanged(
    RecommendationsCropChanged event,
    Emitter<CropRecommendationsState> emit,
  ) async {
    emit(state.copyWith(cropSlug: event.cropSlug));
    await _loadMonths(emit);
  }

  Future<void> _onDistrictChanged(
    RecommendationsDistrictChanged event,
    Emitter<CropRecommendationsState> emit,
  ) async {
    emit(state.copyWith(districtId: event.districtId));
    await _loadMonths(emit);
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
        crops: state.cropSlug.isEmpty ? null : [state.cropSlug],
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
