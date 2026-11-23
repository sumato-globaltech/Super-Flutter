import 'package:equatable/equatable.dart';

sealed class MarketPricesEvent extends Equatable {
  const MarketPricesEvent();

  @override
  List<Object?> get props => [];
}

class MarketPricesStarted extends MarketPricesEvent {
  const MarketPricesStarted({required this.marketId});

  final String marketId;

  @override
  List<Object?> get props => [marketId];
}

class MarketPricesMoreRequested extends MarketPricesEvent {
  const MarketPricesMoreRequested();
}
