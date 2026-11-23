import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/unknown_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/market/model/market_model.dart';
import 'package:super_flutter/data/market/model/market_price_model.dart';
import 'package:super_flutter/data/market/model/market_summary_model.dart';
import 'package:super_flutter/data/market/sources/remote/market_remote_data_source.dart';
import 'package:super_flutter/features/market/presentation/market/bloc/market_bloc.dart';
import 'package:super_flutter/features/market/presentation/market/bloc/market_event.dart';
import 'package:super_flutter/features/market/presentation/market/bloc/market_state.dart';
import 'package:super_flutter/features/market/presentation/market_prices/bloc/market_prices_bloc.dart';
import 'package:super_flutter/features/market/presentation/market_prices/bloc/market_prices_event.dart';
import 'package:super_flutter/features/market/presentation/market_prices/bloc/market_prices_state.dart';

class MockMarketRemoteDataSource extends Mock
    implements MarketRemoteDataSource {}

final _summary = MarketSummaryModel(
  markets: 4,
  marketsReportingToday: 2,
  cropsTracked: 8,
  priceUnit: 'qtl',
  crops: [
    CropSummaryModel(
      crop: CropModel(id: 'c1', name: 'Rice', slug: 'rice'),
      markets: 2,
      medianPrice: '2200.00',
    ),
  ],
);

final _markets = Paged(
  items: [
    MarketModel(
      id: 'm1',
      name: 'Kohima Town',
      district: DistrictModel(id: 'd1', name: 'Kohima'),
      type: MarketTypeModel(value: 'retail', label: 'Retail'),
    ),
    MarketModel(
      id: 'm2',
      name: 'Dimapur Mandi',
      district: DistrictModel(id: 'd2', name: 'Dimapur'),
      type: MarketTypeModel(value: 'wholesale', label: 'Wholesale'),
    ),
  ],
  page: 1,
  lastPage: 2,
  perPage: 20,
  total: 25,
);

final _moreMarkets = Paged(
  items: [
    MarketModel(id: 'm3', name: 'Mokokchung Market'),
  ],
  page: 2,
  lastPage: 2,
  perPage: 20,
  total: 25,
);

final _favourites = Paged(
  items: [
    MarketModel(id: 'm1', name: 'Kohima Town', isFavourite: true),
  ],
  page: 1,
  lastPage: 1,
  perPage: 20,
  total: 1,
);

final _prices = Paged(
  items: [
    MarketPriceModel(
      id: 'p1',
      crop: CropModel(id: 'c1', name: 'Rice'),
      priceDate: '2026-11-16',
      modalPrice: 2200,
      minPrice: 2000,
      maxPrice: 2400,
      unit: UnitModel(code: 'qtl', name: 'Quintal'),
    ),
  ],
  page: 1,
  lastPage: 1,
  perPage: 20,
  total: 1,
);

void main() {
  late MockMarketRemoteDataSource source;

  setUp(() {
    source = MockMarketRemoteDataSource();
  });

  // ─── MarketBloc ───

  group('MarketBloc', () {
    void answer({bool authenticated = false, bool fail = false}) {
      if (fail) {
        when(() => source.getSummary())
            .thenThrow(const UnknownException('Offline'));
        when(
          () => source.getMarkets(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenThrow(const UnknownException('Offline'));
        return;
      }

      when(() => source.getSummary()).thenAnswer((_) async => _summary);
      when(
        () => source.getMarkets(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => _markets);

      if (authenticated) {
        when(
          () => source.getFavourites(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => _favourites);
      }
    }

    blocTest<MarketBloc, MarketState>(
      'loads summary and markets for guest',
      setUp: () => answer(authenticated: false),
      build: () => MarketBloc(source),
      act: (b) => b.add(const MarketStarted(isAuthenticated: false)),
      expect: () => [
        const MarketState(status: MarketStatus.loading),
        MarketState(
          status: MarketStatus.loaded,
          summary: _summary,
          markets: _markets,
          favouriteIds: const {},
        ),
      ],
      verify: (_) {
        verify(() => source.getSummary()).called(1);
        verify(() => source.getMarkets(page: 1, perPage: 20)).called(1);
        verifyNever(
          () => source.getFavourites(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        );
      },
    );

    blocTest<MarketBloc, MarketState>(
      'loads summary, markets and marks favourites for authenticated user',
      setUp: () => answer(authenticated: true),
      build: () => MarketBloc(source),
      act: (b) => b.add(const MarketStarted(isAuthenticated: true)),
      expect: () => [
        const MarketState(status: MarketStatus.loading),
        isA<MarketState>()
            .having((s) => s.status, 'status', MarketStatus.loaded)
            .having((s) => s.favouriteIds, 'favouriteIds', {'m1'})
            .having((s) => s.markets?.items.first.isFavourite, 'm1 isFav', isTrue)
            .having((s) => s.markets?.items[1].isFavourite, 'm2 isFav', isFalse),
      ],
    );

    blocTest<MarketBloc, MarketState>(
      'failure emits error state',
      setUp: () => answer(fail: true),
      build: () => MarketBloc(source),
      act: (b) => b.add(const MarketStarted()),
      skip: 1,
      expect: () => [
        const MarketState(
          status: MarketStatus.failure,
          errorMessage: 'Offline',
        ),
      ],
    );

    blocTest<MarketBloc, MarketState>(
      'switch filter to favourites loads favourites',
      setUp: () {
        when(
          () => source.getFavourites(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => _favourites);
      },
      build: () => MarketBloc(source),
      seed: () => MarketState(
        status: MarketStatus.loaded,
        markets: _markets,
        filter: MarketFilter.all,
      ),
      act: (b) => b.add(const MarketFilterChanged(MarketFilter.favourites)),
      expect: () => [
        MarketState(
          status: MarketStatus.loading,
          markets: _markets,
          filter: MarketFilter.favourites,
        ),
        MarketState(
          status: MarketStatus.loaded,
          markets: _markets,
          favourites: _favourites,
          favouriteIds: const {'m1'},
          filter: MarketFilter.favourites,
        ),
      ],
    );

    blocTest<MarketBloc, MarketState>(
      'load more appends next page',
      setUp: () {
        when(
          () => source.getMarkets(
            page: 2,
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => _moreMarkets);
      },
      build: () => MarketBloc(source),
      seed: () => MarketState(
        status: MarketStatus.loaded,
        markets: _markets,
        filter: MarketFilter.all,
      ),
      act: (b) => b.add(const MarketMoreRequested()),
      expect: () => [
        MarketState(
          status: MarketStatus.loaded,
          markets: _markets,
          loadingMore: true,
          filter: MarketFilter.all,
        ),
        isA<MarketState>()
            .having((s) => s.markets?.items, 'items count', hasLength(3))
            .having((s) => s.loadingMore, 'loadingMore', isFalse),
      ],
    );

    blocTest<MarketBloc, MarketState>(
      'toggle favourite adds favourite when not favourited',
      setUp: () {
        when(() => source.addFavourite('m2')).thenAnswer(
          (_) async => MarketModel(id: 'm2', name: 'Dimapur Mandi', isFavourite: true),
        );
      },
      build: () => MarketBloc(source),
      seed: () => MarketState(
        status: MarketStatus.loaded,
        markets: _markets,
        favouriteIds: const {'m1'},
      ),
      act: (b) => b.add(MarketFavouriteToggled(_markets.items[1])),
      expect: () => [
        isA<MarketState>()
            .having((s) => s.favouriteIds, 'has m2', contains('m2')),
      ],
      verify: (_) => verify(() => source.addFavourite('m2')).called(1),
    );

    blocTest<MarketBloc, MarketState>(
      'toggle favourite removes favourite when already favourited',
      setUp: () {
        when(() => source.removeFavourite('m1')).thenAnswer((_) async {});
      },
      build: () => MarketBloc(source),
      seed: () => MarketState(
        status: MarketStatus.loaded,
        markets: _markets,
        favourites: _favourites,
        favouriteIds: const {'m1'},
      ),
      act: (b) => b.add(MarketFavouriteToggled(_markets.items[0])),
      expect: () => [
        isA<MarketState>()
            .having((s) => s.favouriteIds, 'no m1', isNot(contains('m1'))),
      ],
      verify: (_) => verify(() => source.removeFavourite('m1')).called(1),
    );
  });

  // ─── MarketPricesBloc ───

  group('MarketPricesBloc', () {
    blocTest<MarketPricesBloc, MarketPricesState>(
      'loads price history for market',
      setUp: () {
        when(
          () => source.getPriceHistory(
            marketId: 'm1',
            page: 1,
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => _prices);
      },
      build: () => MarketPricesBloc(source),
      act: (b) => b.add(const MarketPricesStarted(marketId: 'm1')),
      expect: () => [
        const MarketPricesState(status: MarketPricesStatus.loading),
        MarketPricesState(status: MarketPricesStatus.loaded, prices: _prices),
      ],
      verify: (_) =>
          verify(() => source.getPriceHistory(marketId: 'm1', page: 1, perPage: 20))
              .called(1),
    );

    blocTest<MarketPricesBloc, MarketPricesState>(
      'failure emits error state',
      setUp: () {
        when(
          () => source.getPriceHistory(
            marketId: 'm1',
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenThrow(const UnknownException('Offline'));
      },
      build: () => MarketPricesBloc(source),
      act: (b) => b.add(const MarketPricesStarted(marketId: 'm1')),
      skip: 1,
      expect: () => [
        const MarketPricesState(
          status: MarketPricesStatus.failure,
          errorMessage: 'Offline',
        ),
      ],
    );
  });
}
