import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/market/model/market_model.dart';
import 'package:super_flutter/data/market/model/market_summary_model.dart';

import 'market_event.dart';

enum MarketStatus { initial, loading, loaded, failure }

class MarketState extends Equatable {
  const MarketState({
    this.status = MarketStatus.initial,
    this.filter = MarketFilter.all,
    this.markets,
    this.favourites,
    this.summary,
    this.loadingMore = false,
    this.errorMessage,
    this.favouriteIds = const {},
  });

  final MarketStatus status;
  final MarketFilter filter;
  final Paged<MarketModel>? markets;
  final Paged<MarketModel>? favourites;
  final MarketSummaryModel? summary;
  final bool loadingMore;
  final String? errorMessage;
  final Set<String> favouriteIds;

  Paged<MarketModel>? get currentPaged =>
      filter == MarketFilter.all ? markets : favourites;

  List<MarketModel> get items => currentPaged?.items ?? const [];
  bool get hasMore => currentPaged?.hasMore ?? false;

  MarketState copyWith({
    MarketStatus? status,
    MarketFilter? filter,
    Paged<MarketModel>? markets,
    Paged<MarketModel>? favourites,
    MarketSummaryModel? summary,
    bool? loadingMore,
    String? errorMessage,
    Set<String>? favouriteIds,
  }) {
    return MarketState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      markets: markets ?? this.markets,
      favourites: favourites ?? this.favourites,
      summary: summary ?? this.summary,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
      favouriteIds: favouriteIds ?? this.favouriteIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filter,
    markets,
    favourites,
    summary,
    loadingMore,
    errorMessage,
    favouriteIds,
  ];
}
