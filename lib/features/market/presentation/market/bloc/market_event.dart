import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/market/model/market_model.dart';

enum MarketFilter { all, favourites }

sealed class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

class MarketStarted extends MarketEvent {
  const MarketStarted({this.isAuthenticated = false});

  final bool isAuthenticated;

  @override
  List<Object?> get props => [isAuthenticated];
}

class MarketFilterChanged extends MarketEvent {
  const MarketFilterChanged(this.filter);

  final MarketFilter filter;

  @override
  List<Object?> get props => [filter];
}

class MarketMoreRequested extends MarketEvent {
  const MarketMoreRequested();
}

class MarketFavouriteToggled extends MarketEvent {
  const MarketFavouriteToggled(this.market);

  final MarketModel market;

  @override
  List<Object?> get props => [market];
}
