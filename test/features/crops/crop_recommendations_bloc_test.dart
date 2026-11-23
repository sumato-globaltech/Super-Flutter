import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/model/crop_recommendation_model.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_bloc.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_event.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_state.dart';

class MockCropRemoteDataSource extends Mock implements CropRemoteDataSource {}

void main() {
  late MockCropRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = MockCropRemoteDataSource();
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
      final bloc = CropRecommendationsBloc(remoteDataSource);
      expect(bloc.state.status, RecommendationsStatus.initial);
      expect(bloc.state.sowingMonth, inInclusiveRange(1, 12));
      bloc.close();
    });

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'updates district, month and area',
      build: () => CropRecommendationsBloc(remoteDataSource),
      act: (bloc) {
        bloc.add(const RecommendationsDistrictChanged('d1'));
        bloc.add(const RecommendationsMonthChanged(5));
        bloc.add(const RecommendationsAreaChanged(2.5));
      },
      expect: () => [
        isA<CropRecommendationsState>()
            .having((s) => s.districtId, 'districtId', 'd1'),
        isA<CropRecommendationsState>()
            .having((s) => s.sowingMonth, 'sowingMonth', 5),
        isA<CropRecommendationsState>()
            .having((s) => s.areaHa, 'areaHa', 2.5),
      ],
    );

    blocTest<CropRecommendationsBloc, CropRecommendationsState>(
      'emits failure if district is empty on submit',
      build: () => CropRecommendationsBloc(remoteDataSource),
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
        return CropRecommendationsBloc(remoteDataSource);
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
