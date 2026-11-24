import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_endpoints.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDio dio;
  late MockDioClient client;
  late FarmRemoteDataSource source;

  setUp(() {
    dio = MockDio();
    client = MockDioClient();
    when(() => client.dio).thenReturn(dio);
    source = FarmRemoteDataSource(client);
  });

  Response<dynamic> ok(dynamic data, {int statusCode = 200}) => Response(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(),
  );

  group('getFarms', () {
    test('parses paginated farms envelope successfully', () async {
      when(
        () => dio.get<dynamic>(
          FarmEndpoints.farms,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {
              'id': 'f1',
              'code': 'FARM-001',
              'name': 'Green Hills Farm',
              'area_ha': 2.5,
              'district': {'id': 'd1', 'name': 'Kohima'},
              'is_active': true,
            },
          ],
          'meta': {
            'current_page': 1,
            'last_page': 1,
            'total': 1,
            'per_page': 50,
          },
        }),
      );

      final result = await source.getFarms(status: 'active');
      expect(result.items, hasLength(1));
      expect(result.items.first.name, 'Green Hills Farm');
      expect(result.items.first.areaHa, 2.5);
      expect(result.items.first.isActive, true);
    });

    test('rethrows NetworkException on 500 DioException', () async {
      when(
        () => dio.get<dynamic>(
          FarmEndpoints.farms,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(statusCode: 500, requestOptions: RequestOptions()),
        ),
      );

      expect(() => source.getFarms(), throwsA(isA<NetworkException>()));
    });
  });

  group('CRUD operations', () {
    test('getFarm parses single farm', () async {
      when(() => dio.get<dynamic>(FarmEndpoints.farm('f1'))).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {'id': 'f1', 'name': 'Green Hills Farm', 'area_ha': 2.5},
        }),
      );

      final farm = await source.getFarm('f1');
      expect(farm, isNotNull);
      expect(farm!.name, 'Green Hills Farm');
    });

    test('createFarm posts the form fields to /farmer/farms', () async {
      when(() => dio.post<dynamic>(ApiEndpoints.farm, data: any(named: 'data')))
          .thenAnswer(
            (_) async => ok({
              'success': true,
              'data': {'id': 'f1', 'name': 'New Farm', 'area_ha': 1.0},
            }, statusCode: 201),
          );

      final sent = await source.createFarm(
        name: 'New Farm',
        areaHa: 1.0,
        blockId: 'b1',
      );

      expect(sent, isTrue);
      final data =
          verify(
                () => dio.post<dynamic>(
                  ApiEndpoints.farm,
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(data, {'name': 'New Farm', 'area_ha': 1.0, 'block_id': 'b1'});
    });

    test('updateFarmDetail puts the form fields to the farm', () async {
      when(
        () => dio.put<dynamic>(
          ApiEndpoints.farmDetail('f1'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {'id': 'f1', 'name': 'Updated Farm'},
        }),
      );

      final sent = await source.updateFarmDetail(
        'f1',
        name: 'Updated Farm',
        areaHa: 2.0,
      );

      expect(sent, isTrue);
      expect(ApiEndpoints.farmDetail('f1'), '/api/v1/farmer/farms/f1');
    });

    test('deleteFarm deletes farm', () async {
      when(() => dio.delete<dynamic>(FarmEndpoints.farm('f1')))
          .thenAnswer((_) async => ok(null, statusCode: 200));

      final success = await source.deleteFarm('f1');
      expect(success, true);
    });

    test('archiveFarm posts to archive endpoint', () async {
      when(() => dio.post<dynamic>(FarmEndpoints.archive('f1'))).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {'id': 'f1', 'is_active': false},
        }),
      );

      final farm = await source.archiveFarm('f1');
      expect(farm, isNotNull);
      expect(farm!.isActive, false);
    });
  });

  group('Farm Crops', () {
    test('getFarmCrops parses list of crops', () async {
      when(() => dio.get<dynamic>(FarmEndpoints.crops('f1'))).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {
              'id': 'fc1',
              'crop': {'id': 'c1', 'name': 'Ginger'},
              'season': {'value': 'kharif', 'label': 'Kharif'},
              'status': {'value': 'growing', 'label': 'Growing'},
              'area_ha': 1.2,
            },
          ],
        }),
      );

      final crops = await source.getFarmCrops('f1');
      expect(crops, hasLength(1));
      expect(crops.first.crop?.name, 'Ginger');
      expect(crops.first.season?.label, 'Kharif');
    });
  });

  group('Transactions & Summary', () {
    test('getTransactions parses paginated transactions', () async {
      when(
        () => dio.get<dynamic>(
          FarmEndpoints.transactions('f1'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {
              'id': 't1',
              'type': {'value': 'income', 'label': 'Income'},
              'category': {'id': 'cat1', 'name': 'Crop Sale'},
              'amount': 25000.0,
              'occurred_on': '2026-11-01',
            },
          ],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
        }),
      );

      final result = await source.getTransactions('f1');
      expect(result.items, hasLength(1));
      expect(result.items.first.isIncome, true);
      expect(result.items.first.amount, 25000.0);
    });

    test('getTransactionSummary parses totals and crop totals', () async {
      when(
        () => dio.get<dynamic>(FarmEndpoints.transactionSummary('f1')),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {
            'totals': {'income': 50000.0, 'expense': 20000.0, 'net': 30000.0},
            'general': {'income': 0.0, 'expense': 5000.0, 'net': -5000.0},
            'crops': [
              {
                'farm_crop_id': 'fc1',
                'crop': 'Ginger',
                'income': 50000.0,
                'expense': 15000.0,
                'net': 35000.0,
              },
            ],
          },
        }),
      );

      final summary = await source.getTransactionSummary('f1');
      expect(summary, isNotNull);
      expect(summary!.totals?.income, 50000.0);
      expect(summary.totals?.net, 30000.0);
      expect(summary.crops, hasLength(1));
    });
  });

  group('Photos', () {
    test('getPhotos parses list of photos', () async {
      when(() => dio.get<dynamic>(FarmEndpoints.photos('f1'))).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {
              'id': 'ph1',
              'url': 'https://example.com/photo1.jpg',
              'size': 1024,
            },
          ],
        }),
      );

      final photos = await source.getPhotos('f1');
      expect(photos, hasLength(1));
      expect(photos.first.url, 'https://example.com/photo1.jpg');
    });

    test('deletePhoto deletes photo', () async {
      when(() => dio.delete<dynamic>(FarmEndpoints.photo('f1', 'ph1')))
          .thenAnswer((_) async => ok(null, statusCode: 200));

      final success = await source.deletePhoto('f1', 'ph1');
      expect(success, true);
    });
  });
}
