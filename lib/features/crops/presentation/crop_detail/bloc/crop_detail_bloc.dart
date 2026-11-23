import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';

import 'crop_detail_event.dart';
import 'crop_detail_state.dart';

@injectable
class CropDetailBloc extends Bloc<CropDetailEvent, CropDetailState> {
  CropDetailBloc(this._remoteDataSource) : super(const CropDetailState()) {
    on<CropDetailStarted>(_onStarted, transformer: restartable());
    on<CropDetailTabChanged>(_onTabChanged);
    on<CropDetailRefreshed>(_onRefreshed, transformer: restartable());
    on<CropDetailPricesMoreRequested>(
      _onPricesMoreRequested,
      transformer: droppable(),
    );
  }

  final CropRemoteDataSource _remoteDataSource;

  Future<void> _loadAll(
    Emitter<CropDetailState> emit, {
    required String slug,
    String? districtId,
  }) async {
    try {
      final results = await Future.wait([
        _remoteDataSource.getCrop(slug),
        _remoteDataSource.getCropAdvisory(slug, districtId: districtId),
        _remoteDataSource.getCropCalendar(slug, districtId: districtId),
        _remoteDataSource.getCropFertilizers(slug),
        _remoteDataSource.getCropPrices(slug, page: 1),
      ]);

      final crop = results[0];
      final advisory = results[1];
      final calendar = results[2];
      final fertilizers = results[3];
      final pricesPaged = results[4];

      if (crop == null && advisory == null) {
        emit(
          state.copyWith(
            status: CropDetailStatus.failure,
            errorMessage: 'Crop not found',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: CropDetailStatus.success,
          slug: slug,
          districtId: districtId,
          crop: crop as dynamic,
          advisory: advisory as dynamic,
          calendar: calendar as dynamic,
          fertilizers: fertilizers as dynamic,
          prices: pricesPaged != null ? (pricesPaged as dynamic).items : const [],
          pricesPage: 1,
          pricesHasMore:
              pricesPaged != null ? (pricesPaged as dynamic).hasMore : false,
          loadingMorePrices: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CropDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStarted(
    CropDetailStarted event,
    Emitter<CropDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CropDetailStatus.loading,
        slug: event.slug,
        districtId: event.districtId,
      ),
    );
    await _loadAll(emit, slug: event.slug, districtId: event.districtId);
  }

  void _onTabChanged(
    CropDetailTabChanged event,
    Emitter<CropDetailState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.index));
  }

  Future<void> _onRefreshed(
    CropDetailRefreshed event,
    Emitter<CropDetailState> emit,
  ) async {
    if (state.slug.isEmpty) return;
    await _loadAll(emit, slug: state.slug, districtId: state.districtId);
  }

  Future<void> _onPricesMoreRequested(
    CropDetailPricesMoreRequested event,
    Emitter<CropDetailState> emit,
  ) async {
    if (!state.pricesHasMore || state.loadingMorePrices || state.slug.isEmpty) {
      return;
    }
    emit(state.copyWith(loadingMorePrices: true));
    try {
      final nextPage = state.pricesPage + 1;
      final paged = await _remoteDataSource.getCropPrices(
        state.slug,
        page: nextPage,
      );
      emit(
        state.copyWith(
          prices: [...state.prices, ...paged.items],
          pricesPage: nextPage,
          pricesHasMore: paged.hasMore,
          loadingMorePrices: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loadingMorePrices: false));
    }
  }
}
