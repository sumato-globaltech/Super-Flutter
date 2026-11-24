import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/crops/model/crop_advisory_model.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/model/crop_recommendation_model.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';
import 'package:super_flutter/data/meetings/model/district_option_model.dart';
import 'package:super_flutter/data/meetings/sources/remote/meetings_remote_data_source.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_bloc.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_event.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_state.dart';

class MockCropRemoteDataSource extends Mock implements CropRemoteDataSource {}

class MockMeetingsRemoteDataSource extends Mock
    implements MeetingsRemoteDataSource {}

void main() {
  late MockCropRemoteDataSource remoteDataSource;
  late MockMeetingsRemoteDataSource meetings;

  setUp(() {
    remoteDataSource = MockCropRemoteDataSource();
    meetings = MockMeetingsRemoteDataSource();
    when(() => meetings.getDistrictList()).thenAnswer(
      (_) async => [DistrictOptionModel(id: 'd1', name: 'Kohima')],
    );
    when(
      () => remoteDataSource.getCrops(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((call) async {
      final page = call.namedArguments[#page] as int;
      return Paged(
        items: [CropModel(id: 'c$page', name: 'Crop $page', slug: 'crop-$page')],
        page: page,
        lastPage: 2,
      );
    });
    when(
      () => remoteDataSource.getSowingMonths(
        crop: any(named: 'crop'),
        districtId: any(named: 'districtId'),
      ),
    ).thenAnswer(
      (call) async => call.namedArguments[#crop] == null
          ? [
              for (var month = 1; month <= 12; month++)
                MonthModel(number: month, name: 'Month $month'),
            ]
          : const [
              MonthModel(number: 6, name: 'June'),
              MonthModel(number: 7, name: 'July'),
            ],
    );
  });

  final result = CropRecommendationResultModel(
    input: const CropRecommendationInputModel(
      district: DistrictModel(id: 'd1', name: 'Kohima'),
      areaHa: 2.0,
    ),
    results: const [
      CropRecommendationItemModel(
        rank: 1,
        crop: CropModel(id: 'c1', name: 'Ginger', slug: 'ginger'),
        suitabilityScore: 92,
        sowingWindow: 'April - May',
        notes: ['Optimal sowing season'],
      ),
    ],
  );

  group('CropRecommendationsBloc', () {
    test('initial state has month set to current month', () {
      final bloc = CropRecommendationsBloc(remoteDataSource, meetings);
      expect(bloc.state.status, RecommendationsStatus.initial);
      expect(bloc.state.sowingMonth, inInclusiveRange(1, 12));
      bloc.close();
    });

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'loads districts, every page of crops and the months',
      build: () => CropRecommendationsBloc(remoteDataSource, meetings),
      act: (bloc) => bloc.add(const RecommendationsStarted()),
      verify: (bloc) {
        expect(bloc.state.optionsStatus, RecommendationsStatus.success);
        expect(bloc.state.districtId, 'd1');
        expect(bloc.state.crops.map((c) => c.slug), ['crop-1', 'crop-2']);
        expect(bloc.state.months, hasLength(12));
        expect(bloc.state.sowingMonth, DateTime.now().month);
      },
    );

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'reports when the options cannot be loaded',
      build: () {
        when(() => meetings.getDistrictList())
            .thenThrow(const NetworkException('Server error'));
        return CropRecommendationsBloc(remoteDataSource, meetings);
      },
      act: (bloc) => bloc.add(const RecommendationsStarted()),
      verify: (bloc) {
        expect(bloc.state.optionsStatus, RecommendationsStatus.failure);
        expect(bloc.state.optionsError, 'Server error');
      },
    );

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'a crop limits the months to its sowing window',
      build: () => CropRecommendationsBloc(remoteDataSource, meetings),
      seed: () => const CropRecommendationsState(districtId: 'd1'),
      act: (bloc) => bloc.add(const RecommendationsCropChanged('crop-1')),
      verify: (bloc) {
        expect(bloc.state.months.map((m) => m.number), [6, 7]);
        expect(bloc.state.sowingMonth, 6);
        verify(
          () => remoteDataSource.getSowingMonths(
            crop: 'crop-1',
            districtId: 'd1',
          ),
        ).called(1);
      },
    );

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'keeps the months of the latest crop when answers arrive out of order',
      build: () {
        when(
          () => remoteDataSource.getSowingMonths(
            crop: 'slow',
            districtId: any(named: 'districtId'),
          ),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return const [MonthModel(number: 1, name: 'January')];
        });
        return CropRecommendationsBloc(remoteDataSource, meetings);
      },
      act: (bloc) => bloc
        ..add(const RecommendationsCropChanged('slow'))
        ..add(const RecommendationsCropChanged('crop-1')),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.optionsStatus, RecommendationsStatus.success);
        expect(bloc.state.months.map((m) => m.number), [6, 7]);
      },
    );

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'sends the chosen crop',
      build: () {
        when(
          () => remoteDataSource.getRecommendations(
            districtId: 'd1',
            sowingMonth: 6,
            areaHa: 1,
            crops: ['crop-1'],
          ),
        ).thenAnswer((_) async => result);
        return CropRecommendationsBloc(remoteDataSource, meetings);
      },
      seed: () => const CropRecommendationsState(
        districtId: 'd1',
        sowingMonth: 6,
        cropSlug: 'crop-1',
      ),
      act: (bloc) => bloc.add(const RecommendationsSubmitted()),
      verify: (bloc) =>
          expect(bloc.state.status, RecommendationsStatus.success),
    );

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'updates district, month and area',
      build: () => CropRecommendationsBloc(remoteDataSource, meetings),
      act: (bloc) async {
        bloc.add(const RecommendationsDistrictChanged('d1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const RecommendationsMonthChanged(5));
        bloc.add(const RecommendationsAreaChanged(2.5));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.districtId, 'd1');
        expect(bloc.state.sowingMonth, 5);
        expect(bloc.state.areaHa, 2.5);
      },
    );

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'emits failure if district is empty on submit',
      build: () => CropRecommendationsBloc(remoteDataSource, meetings),
      act: (bloc) => bloc.add(const RecommendationsSubmitted()),
      expect: () => [
        isA<CropRecommendationsState>()
            .having((s) => s.status, 'status', RecommendationsStatus.failure)
            .having((s) => s.errorMessage, 'error', 'District is required'),
      ],
    );

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'submits and returns recommendations successfully',
      build: () {
        when(
          () => remoteDataSource.getRecommendations(
            districtId: 'd1',
            sowingMonth: 5,
            areaHa: 2.5,
          ),
        ).thenAnswer((_) async => result);
        return CropRecommendationsBloc(remoteDataSource, meetings);
      },
      seed: () => const CropRecommendationsState(
        districtId: 'd1',
        sowingMonth: 5,
        areaHa: 2.5,
      ),
      act: (bloc) => bloc.add(const RecommendationsSubmitted()),
      expect: () => [
        isA<CropRecommendationsState>()
            .having((s) => s.status, 'status', RecommendationsStatus.loading),
        isA<CropRecommendationsState>()
            .having((s) => s.status, 'status', RecommendationsStatus.success)
            .having((s) => s.result, 'result', result),
      ],
    );
  });
}
