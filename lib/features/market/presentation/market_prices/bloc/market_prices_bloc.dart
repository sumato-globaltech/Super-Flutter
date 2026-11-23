import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/market/sources/remote/market_remote_data_source.dart';

import 'market_prices_event.dart';
import 'market_prices_state.dart';

@injectable
class MarketPricesBloc extends Bloc<MarketPricesEvent, MarketPricesState> {
  MarketPricesBloc(this._remoteDataSource) : super(const MarketPricesState()) {
    on<MarketPricesStarted>(_onStarted, transformer: restartable());
    on<MarketPricesMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final MarketRemoteDataSource _remoteDataSource;
  String? _marketId;

  Future<void> _onStarted(
    MarketPricesStarted event,
    Emitter<MarketPricesState> emit,
  ) async {
    _marketId = event.marketId;
    emit(state.copyWith(status: MarketPricesStatus.loading, loadingMore: false));
    try {
      final result = await _remoteDataSource.getPriceHistory(
        marketId: event.marketId,
        page: 1,
        perPage: Paged.defaultPerPage,
      );
      emit(state.copyWith(status: MarketPricesStatus.loaded, prices: result));
    } on AppException catch (e) {
      emit(state.copyWith(status: MarketPricesStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: MarketPricesStatus.failure,
          errorMessage: 'Could not load price history.',
        ),
      );
    }
  }

  Future<void> _onMoreRequested(
    MarketPricesMoreRequested event,
    Emitter<MarketPricesState> emit,
  ) async {
    final current = state.prices;
    final marketId = _marketId;
    if (current == null || !current.hasMore || state.loadingMore || marketId == null) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _remoteDataSource.getPriceHistory(
        marketId: marketId,
        page: current.page + 1,
        perPage: Paged.defaultPerPage,
      );
      emit(
        state.copyWith(
          prices: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(loadingMore: false, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(loadingMore: false));
    }
  }
}
