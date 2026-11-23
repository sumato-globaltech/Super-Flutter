import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/market/model/market_model.dart';
import 'package:super_flutter/data/market/sources/remote/market_remote_data_source.dart';

import 'market_event.dart';
import 'market_state.dart';

@injectable
class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc(this._remoteDataSource) : super(const MarketState()) {
    on<MarketStarted>(_onStarted, transformer: restartable());
    on<MarketFilterChanged>(_onFilterChanged);
    on<MarketMoreRequested>(_onMoreRequested, transformer: droppable());
    on<MarketFavouriteToggled>(_onFavouriteToggled);
  }

  final MarketRemoteDataSource _remoteDataSource;

  Future<void> _onStarted(
    MarketStarted event,
    Emitter<MarketState> emit,
  ) async {
    emit(state.copyWith(status: MarketStatus.loading, loadingMore: false));
    try {
      final summaryFuture = _remoteDataSource.getSummary();
      final marketsFuture = _remoteDataSource.getMarkets(
        page: 1,
        perPage: Paged.defaultPerPage,
      );
      final favsFuture = event.isAuthenticated
          ? _remoteDataSource.getFavourites(page: 1, perPage: 100)
          : null;

      final summary = await summaryFuture;
      final markets = await marketsFuture;
      final favs = favsFuture != null ? await favsFuture : null;

      final favIds = favs?.items.map((m) => m.id ?? '').toSet() ?? const <String>{};

      // Mark favourites on the market list items
      final decoratedItems = markets.items.map((m) {
        return m.copyWith(isFavourite: favIds.contains(m.id));
      }).toList();

      final decoratedMarkets = Paged<MarketModel>(
        items: decoratedItems,
        page: markets.page,
        lastPage: markets.lastPage,
        perPage: markets.perPage,
        total: markets.total,
      );

      emit(
        state.copyWith(
          status: MarketStatus.loaded,
          summary: summary,
          markets: decoratedMarkets,
          favourites: favs,
          favouriteIds: favIds,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: MarketStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: MarketStatus.failure,
          errorMessage: 'Could not load markets.',
        ),
      );
    }
  }

  Future<void> _onFilterChanged(
    MarketFilterChanged event,
    Emitter<MarketState> emit,
  ) async {
    if (state.filter == event.filter) return;

    if (event.filter == MarketFilter.favourites && state.favourites == null) {
      emit(state.copyWith(filter: event.filter, status: MarketStatus.loading));
      try {
        final favs = await _remoteDataSource.getFavourites(
          page: 1,
          perPage: Paged.defaultPerPage,
        );
        final favIds = favs.items.map((m) => m.id ?? '').toSet();
        emit(
          state.copyWith(
            status: MarketStatus.loaded,
            favourites: favs,
            favouriteIds: favIds,
          ),
        );
      } on AppException catch (e) {
        emit(state.copyWith(status: MarketStatus.failure, errorMessage: e.message));
      } catch (_) {
        emit(
          state.copyWith(
            status: MarketStatus.failure,
            errorMessage: 'Could not load favourite markets.',
          ),
        );
      }
    } else {
      emit(state.copyWith(filter: event.filter));
    }
  }

  Future<void> _onMoreRequested(
    MarketMoreRequested event,
    Emitter<MarketState> emit,
  ) async {
    final current = state.currentPaged;
    if (current == null || !current.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final nextPage = current.page + 1;
      final next = state.filter == MarketFilter.all
          ? await _remoteDataSource.getMarkets(
              page: nextPage,
              perPage: Paged.defaultPerPage,
            )
          : await _remoteDataSource.getFavourites(
              page: nextPage,
              perPage: Paged.defaultPerPage,
            );

      final decoratedItems = next.items.map((m) {
        return m.copyWith(
          isFavourite: state.favouriteIds.contains(m.id) || state.filter == MarketFilter.favourites,
        );
      }).toList();

      final decoratedNext = Paged<MarketModel>(
        items: decoratedItems,
        page: next.page,
        lastPage: next.lastPage,
        perPage: next.perPage,
        total: next.total,
      );

      final appended = current.append(decoratedNext);
      if (state.filter == MarketFilter.all) {
        emit(state.copyWith(markets: appended, loadingMore: false));
      } else {
        emit(state.copyWith(favourites: appended, loadingMore: false));
      }
    } on AppException catch (e) {
      emit(state.copyWith(loadingMore: false, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(loadingMore: false));
    }
  }

  Future<void> _onFavouriteToggled(
    MarketFavouriteToggled event,
    Emitter<MarketState> emit,
  ) async {
    final market = event.market;
    final id = market.id;
    if (id == null) return;

    final wasFavourite = state.favouriteIds.contains(id);
    final newFavIds = Set<String>.from(state.favouriteIds);
    if (wasFavourite) {
      newFavIds.remove(id);
    } else {
      newFavIds.add(id);
    }

    // Optimistic update
    Paged<MarketModel>? updatePaged(Paged<MarketModel>? paged) {
      if (paged == null) return null;
      return Paged<MarketModel>(
        items: paged.items.map((m) {
          if (m.id == id) {
            return m.copyWith(isFavourite: !wasFavourite);
          }
          return m;
        }).toList(),
        page: paged.page,
        lastPage: paged.lastPage,
        perPage: paged.perPage,
        total: paged.total,
      );
    }

    Paged<MarketModel>? newFavs = state.favourites;
    if (wasFavourite && newFavs != null) {
      newFavs = Paged<MarketModel>(
        items: newFavs.items.where((m) => m.id != id).toList(),
        page: newFavs.page,
        lastPage: newFavs.lastPage,
        perPage: newFavs.perPage,
        total: (newFavs.total - 1).clamp(0, 999999),
      );
    }

    emit(
      state.copyWith(
        favouriteIds: newFavIds,
        markets: updatePaged(state.markets),
        favourites: newFavs,
      ),
    );

    try {
      if (wasFavourite) {
        await _remoteDataSource.removeFavourite(id);
      } else {
        await _remoteDataSource.addFavourite(id);
      }
    } catch (_) {
      // Revert if API failed
      emit(
        state.copyWith(
          favouriteIds: state.favouriteIds,
          markets: updatePaged(state.markets),
          favourites: state.favourites,
        ),
      );
    }
  }
}
