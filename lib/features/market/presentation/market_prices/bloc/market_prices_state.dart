import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/market/model/market_price_model.dart';

enum MarketPricesStatus { initial, loading, loaded, failure }

class MarketPricesState extends Equatable {
  const MarketPricesState({
    this.status = MarketPricesStatus.initial,
    this.prices,
    this.loadingMore = false,
    this.errorMessage,
  });

  final MarketPricesStatus status;
  final Paged<MarketPriceModel>? prices;
  final bool loadingMore;
  final String? errorMessage;

  List<MarketPriceModel> get items => prices?.items ?? const [];
  bool get hasMore => prices?.hasMore ?? false;

  MarketPricesState copyWith({
    MarketPricesStatus? status,
    Paged<MarketPriceModel>? prices,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return MarketPricesState(
      status: status ?? this.status,
      prices: prices ?? this.prices,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, prices, loadingMore, errorMessage];
}
