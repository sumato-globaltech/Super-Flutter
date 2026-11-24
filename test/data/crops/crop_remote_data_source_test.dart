import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_endpoints.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDio dio;
  late MockDioClient client;
  late CropRemoteDataSource source;

  setUp(() {
    dio = MockDio();
    client = MockDioClient();
    when(() => client.dio).thenReturn(dio);
    source = CropRemoteDataSource(client);
  });

  Response<dynamic> ok(dynamic data, {int statusCode = 200}) => Response(
        data: data,
        statusCode: statusCode,
        requestOptions: RequestOptions(),
      );

  group('getCrops', () {
    test('parses paginated crops envelope successfully', () async {
      when(
        () => dio.get<dynamic>(
          CropEndpoints.crops,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {
              'id': 'c1',
              'name': 'Ginger',
              'slug': 'ginger',
              'scientific_name': 'Zingiber officinale',
              'local_names': {
                'other': ['Adrak'],
              },
              'type': {'id': 't1', 'name': 'Spices', 'slug': 'spices'},
              'duration_days': 240,
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

      final result = await source.getCrops(search: 'Ginger');
      expect(result.items, hasLength(1));
      expect(result.items.first.name, 'Ginger');
      expect(result.items.first.localName, 'Adrak');
      expect(result.items.first.type?.name, 'Spices');
      expect(result.total, 1);
    });

    test('rethrows NetworkException on 500 DioException', () async {
      when(
        () => dio.get<dynamic>(
          CropEndpoints.crops,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(),
          ),
        ),
      );

      expect(() => source.getCrops(), throwsA(isA<NetworkException>()));
    });
  });

  group('getCrop', () {
    test('parses single crop with varieties', () async {
      when(
        () => dio.get<dynamic>(CropEndpoints.crop('ginger')),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {
            'id': 'c1',
            'name': 'Ginger',
            'slug': 'ginger',
            'varieties': [
              {
                'name': 'Nadia',
                'duration_days': 220,
                'yield_per_ha': 15.5,
              },
            ],
          },
        }),
      );

      final result = await source.getCrop('ginger');
      expect(result, isNotNull);
      expect(result!.name, 'Ginger');
      expect(result.varieties, hasLength(1));
      expect(result.varieties!.first.name, 'Nadia');
    });
  });

  group('getCropAdvisory', () {
    test('parses advisory data', () async {
      when(
        () => dio.get<dynamic>(
          CropEndpoints.advisory('ginger'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {
            'crop': {'id': 'c1', 'name': 'Ginger', 'slug': 'ginger'},
            'month': {'number': 11, 'name': 'November'},
            'windows': {'sowing': 'Apr-May', 'harvest': 'Dec-Jan'},
            'profile': {
              'climate': {'temp_min_c': 15, 'temp_max_c': 35},
              'soil': {'types': ['Loamy'], 'ph_min': 5.5, 'ph_max': 6.5},
              'sowing': {'method': 'Raised beds'},
              'field_practices': {'land_preparation': 'Deep ploughing'},
            },
            'practices': [
              {
                'kind': 'ipm_cultural',
                'label': 'Cultural control',
                'steps': ['Mulching'],
              },
            ],
            'fertilizers': [
              {
                'recommendation': 'basal',
                'label': 'Basal',
                'items': [
                  {'fertilizer': 'Urea', 'dosage': '50 kg/ha'},
                ],
              },
            ],
          },
        }),
      );

      final result = await source.getCropAdvisory('ginger');
      expect(result, isNotNull);
      expect(result!.month?.name, 'November');
      expect(result.windows?.sowing, 'Apr-May');
      expect(result.profile?.soil?.types, contains('Loamy'));
      expect(result.practices, hasLength(1));
      expect(result.fertilizers, hasLength(1));
    });
  });

  group('getCropFertilizers', () {
    test('parses fertilizers response', () async {
      when(
        () => dio.get<dynamic>(CropEndpoints.fertilizers('ginger')),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {
            'crop': {'id': 'c1', 'name': 'Ginger'},
            'fertilizers': [
              {
                'recommendation': 'foliar',
                'label': 'Foliar spray',
                'items': [
                  {'fertilizer': 'Zinc sulphate', 'dosage': '0.5%'},
                ],
              },
            ],
          },
        }),
      );

      final result = await source.getCropFertilizers('ginger');
      expect(result, isNotNull);
      expect(result!.fertilizers, hasLength(1));
      expect(result.fertilizers.first.label, 'Foliar spray');
    });
  });

  group('getSowingMonths', () {
    test('parses the months of a crop', () async {
      when(
        () => dio.get<dynamic>(
          CropEndpoints.sowingMonths,
          queryParameters: {'crop': 'ginger', 'district_id': 'd1'},
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': [
            {'number': 6, 'name': 'June'},
          ],
        }),
      );

      final months = await source.getSowingMonths(
        crop: 'ginger',
        districtId: 'd1',
      );
      expect(months.single.number, 6);
      expect(months.single.name, 'June');
    });
  });

  group('getRecommendations', () {
    test('parses crop recommendations', () async {
      when(
        () => dio.get<dynamic>(
          CropEndpoints.recommendations,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => ok({
          'success': true,
          'data': {
            'input': {
              'district': {'id': 'd1', 'name': 'Kohima'},
              'sowing_month': {'number': 11, 'name': 'November'},
              'area_ha': 2.0,
            },
            'results': [
              {
                'rank': 1,
                'crop': {'id': 'c1', 'name': 'Ginger', 'slug': 'ginger'},
                'suitability': 'high',
                'suitability_score': 95,
                'sowing_window': {
                  'label': 'Oct – Nov',
                  'months': [10, 11],
                  'source': 'crop',
                },
                'notes': ['Optimal season'],
              },
            ],
          },
        }),
      );

      final result = await source.getRecommendations(
        districtId: 'd1',
        sowingMonth: 11,
        areaHa: 2.0,
        crops: ['ginger'],
      );
      final query = verify(
        () => dio.get<dynamic>(
          CropEndpoints.recommendations,
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured.single as Map;
      expect(query['crops[]'], ['ginger']);
      expect(result!.results.first.sowingWindow, 'Oct – Nov');
      expect(result.input?.district?.name, 'Kohima');
      expect(result.results, hasLength(1));
      expect(result.results.first.rank, 1);
      expect(result.results.first.crop?.name, 'Ginger');
      expect(result.results.first.notes, contains('Optimal season'));
    });
  });
}
