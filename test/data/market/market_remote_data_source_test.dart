import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/data/market/sources/remote/market_endpoints.dart';
import 'package:super_flutter/data/market/sources/remote/market_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDio dio;
  late MockDioClient client;
  late MarketRemoteDataSource source;

  setUp(() {
    dio = MockDio();
    client = MockDioClient();
    when(() => client.dio).thenReturn(dio);
    source = MarketRemoteDataSource(client);
  });

  Response<dynamic> ok(dynamic data, {int statusCode = 200}) => Response(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(),
  );

  group('getMarkets', () {
    test('parses paginated markets response', () async {
      when(
        () => dio.get<dynamic>(
          MarketEndpoints.markets,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {
              'id': 'm1',
              'name': 'Kohima Town',
              'type': {'value': 'retail', 'label': 'Retail'},
              'address': 'Main Market',
              'latitude': 25.67,
              'longitude': 94.11,
              'facilities': ['storage', 'parking'],
              'district': {'id': 'd1', 'name': 'Kohima'},
              'distance_km': 4.5,
            },
          ],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 1, 'per_page': 20},
        }),
      );

      final result = await source.getMarkets(districtId: 'd1');
      expect(result.items, hasLength(1));
      final market = result.items.first;
      expect(market.id, 'm1');
      expect(market.name, 'Kohima Town');
      expect(market.type?.label, 'Retail');
      expect(market.district?.name, 'Kohima');
      expect(market.distanceKm, 4.5);
    });
  });

  group('getSummary', () {
    test('parses summary response', () async {
      when(
        () => dio.get<dynamic>(
          MarketEndpoints.summary,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {
            'markets': 5,
            'markets_reporting_today': 3,
            'crops_tracked': 12,
            'latest_price_date': '2026-11-16',
            'recent_days': 7,
            'price_unit': 'qtl',
            'crops': [
              {
                'crop': {'id': 'c1', 'name': 'Rice', 'slug': 'rice'},
                'markets': 3,
                'latest_price_date': '2026-11-16',
                'lowest_price': '2000.00',
                'median_price': '2500.00',
                'highest_price': '3000.00',
              },
            ],
          },
        }),
      );

      final summary = await source.getSummary();
      expect(summary.markets, 5);
      expect(summary.marketsReportingToday, 3);
      expect(summary.cropsTracked, 12);
      expect(summary.crops, hasLength(1));
      expect(summary.crops!.first.crop?.name, 'Rice');
      expect(summary.crops!.first.medianPrice, '2500.00');
    });
  });

  group('getPriceHistory', () {
    test('parses paginated price history', () async {
      when(
        () => dio.get<dynamic>(
          MarketEndpoints.prices('m1'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {
              'id': 'p1',
              'price_date': '2026-11-16',
              'min_price': 1800,
              'modal_price': 2000,
              'max_price': 2200,
              'crop': {'id': 'c1', 'name': 'Rice', 'slug': 'rice'},
              'unit': {'code': 'qtl', 'name': 'Quintal'},
              'modal_price_per_quintal': 2000.0,
              'source': 'manual',
            },
          ],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 1, 'per_page': 20},
        }),
      );

      final result = await source.getPriceHistory(marketId: 'm1');
      expect(result.items, hasLength(1));
      final price = result.items.first;
      expect(price.id, 'p1');
      expect(price.crop?.name, 'Rice');
      expect(price.modalPrice, 2000);
      expect(price.unit?.code, 'qtl');
    });
  });

  group('favourites', () {
    test('getFavourites returns favourites with isFavourite = true', () async {
      when(
        () => dio.get<dynamic>(
          MarketEndpoints.favourites,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {'id': 'm1', 'name': 'Kohima Town'},
          ],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 1, 'per_page': 20},
        }),
      );

      final result = await source.getFavourites();
      expect(result.items, hasLength(1));
      expect(result.items.first.isFavourite, isTrue);
    });

    test('addFavourite posts and returns market with isFavourite = true', () async {
      when(
        () => dio.post<dynamic>(MarketEndpoints.favourite('m1')),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {'id': 'm1', 'name': 'Kohima Town'},
        }),
      );

      final result = await source.addFavourite('m1');
      expect(result.id, 'm1');
      expect(result.isFavourite, isTrue);
    });

    test('removeFavourite deletes favourite', () async {
      when(
        () => dio.delete<dynamic>(MarketEndpoints.favourite('m1')),
      ).thenAnswer((_) async => ok(null, statusCode: 204));

      await expectLater(source.removeFavourite('m1'), completes);
    });
  });
}
