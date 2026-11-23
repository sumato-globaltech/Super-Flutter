import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/crops/model/crop_advisory_model.dart';
import 'package:super_flutter/data/crops/model/crop_fertilizers_model.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';
import 'package:super_flutter/data/market/model/market_price_model.dart';
import 'package:super_flutter/features/crops/presentation/crop_detail/bloc/crop_detail_bloc.dart';
import 'package:super_flutter/features/crops/presentation/crop_detail/bloc/crop_detail_event.dart';
import 'package:super_flutter/features/crops/presentation/crop_detail/bloc/crop_detail_state.dart';

class MockCropRemoteDataSource extends Mock implements CropRemoteDataSource {}

void main() {
  late MockCropRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = MockCropRemoteDataSource();
  });

  final crop = const CropModel(
    id: 'c1',
    name: 'Ginger',
    slug: 'ginger',
    scientificName: 'Zingiber officinale',
  );

  final advisory = CropAdvisoryModel(
    crop: crop,
    month: const MonthModel(number: 11, name: 'November'),
    windows: const WindowsModel(sowing: 'Apr-May', harvest: 'Dec-Jan'),
  );

  final fertilizers = CropFertilizersModel(
    crop: crop,
    fertilizers: const [
      CropFertilizerGroupModel(
        label: 'Basal',
        items: [CropFertilizerItemModel(fertilizer: 'Urea')],
      ),
    ],
  );

  final price = MarketPriceModel(
    id: 'p1',
    priceDate: '2026-11-04',
    modalPrice: 120,
  );

  group('CropDetailBloc', () {
    test('initial state has initial status', () {
      final bloc = CropDetailBloc(remoteDataSource);
      expect(bloc.state.status, CropDetailStatus.initial);
      bloc.close();
    });

    blocTest<CropDetailBloc, CropDetailState>(
      'loads crop and all advisory details in parallel on CropDetailStarted',
      build: () {
        when(() => remoteDataSource.getCrop('ginger'))
            .thenAnswer((_) async => crop);
        when(
          () => remoteDataSource.getCropAdvisory(
            'ginger',
            districtId: any(named: 'districtId'),
          ),
        ).thenAnswer((_) async => advisory);
        when(
          () => remoteDataSource.getCropCalendar(
            'ginger',
            districtId: any(named: 'districtId'),
          ),
        ).thenAnswer((_) async => null);
        when(() => remoteDataSource.getCropFertilizers('ginger'))
            .thenAnswer((_) async => fertilizers);
        when(
          () => remoteDataSource.getCropPrices(
            'ginger',
            page: 1,
          ),
        ).thenAnswer(
          (_) async => Paged(items: [price], page: 1, lastPage: 1),
        );
        return CropDetailBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const CropDetailStarted('ginger')),
      expect: () => [
        const CropDetailState(
          status: CropDetailStatus.loading,
          slug: 'ginger',
        ),
        CropDetailState(
          status: CropDetailStatus.success,
          slug: 'ginger',
          crop: crop,
          advisory: advisory,
          fertilizers: fertilizers,
          prices: [price],
          pricesPage: 1,
          pricesHasMore: false,
        ),
      ],
    );

    blocTest<CropDetailBloc, CropDetailState>(
      'updates tab index on CropDetailTabChanged',
      build: () => CropDetailBloc(remoteDataSource),
      act: (bloc) => bloc.add(const CropDetailTabChanged(2)),
      expect: () => [
        const CropDetailState(selectedTab: 2),
      ],
    );
  });
}
