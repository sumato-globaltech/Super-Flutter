import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/farm/model/farm_crop_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/farm_photo_model.dart';
import 'package:super_flutter/data/farm/model/farm_transaction_model.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';
import 'package:super_flutter/features/farm/presentation/farm_detail/bloc/farm_detail_bloc.dart';
import 'package:super_flutter/features/farm/presentation/farm_detail/bloc/farm_detail_event.dart';
import 'package:super_flutter/features/farm/presentation/farm_detail/bloc/farm_detail_state.dart';

class MockFarmRemoteDataSource extends Mock implements FarmRemoteDataSource {}

void main() {
  late MockFarmRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = MockFarmRemoteDataSource();
  });

  const farm = FarmModel(
    id: 'f1',
    name: 'Green Hills Farm',
    areaHa: 2.5,
    isActive: true,
  );

  const crop = FarmCropModel(
    id: 'fc1',
    crop: FarmCropRefModel(id: 'c1', name: 'Ginger'),
    season: ValueLabelModel(value: 'kharif', label: 'Kharif'),
  );

  const tx = FarmTransactionModel(
    id: 't1',
    type: ValueLabelModel(value: 'income', label: 'Income'),
    amount: 15000.0,
  );

  const summary = FarmTransactionSummaryModel(
    totals: LedgerTotalModel(income: 15000.0, expense: 5000.0, net: 10000.0),
  );

  const photo = FarmPhotoModel(
    id: 'ph1',
    url: 'https://example.com/photo.jpg',
  );

  group('FarmDetailBloc', () {
    test('initial state has initial status', () {
      final bloc = FarmDetailBloc(remoteDataSource);
      expect(bloc.state.status, FarmDetailStatus.initial);
      bloc.close();
    });

    blocTest<FarmDetailBloc, FarmDetailState>(
      'loads farm, crops, transactions, summary, photos on FarmDetailStarted',
      build: () {
        when(() => remoteDataSource.getFarm('f1')).thenAnswer((_) async => farm);
        when(() => remoteDataSource.getFarmCrops('f1'))
            .thenAnswer((_) async => [crop]);
        when(
          () => remoteDataSource.getTransactions('f1', page: 1),
        ).thenAnswer((_) async => const Paged(items: [tx]));
        when(() => remoteDataSource.getTransactionSummary('f1'))
            .thenAnswer((_) async => summary);
        when(() => remoteDataSource.getPhotos('f1'))
            .thenAnswer((_) async => [photo]);
        return FarmDetailBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const FarmDetailStarted('f1')),
      expect: () => [
        const FarmDetailState(
          status: FarmDetailStatus.loading,
          farmId: 'f1',
        ),
        const FarmDetailState(
          status: FarmDetailStatus.success,
          farmId: 'f1',
          farm: farm,
          crops: [crop],
          transactions: [tx],
          summary: summary,
          photos: [photo],
        ),
      ],
    );

    blocTest<FarmDetailBloc, FarmDetailState>(
      'toggles archive status',
      build: () {
        when(() => remoteDataSource.archiveFarm('f1')).thenAnswer(
          (_) async => const FarmModel(id: 'f1', isActive: false),
        );
        return FarmDetailBloc(remoteDataSource);
      },
      seed: () => const FarmDetailState(
        status: FarmDetailStatus.success,
        farmId: 'f1',
        farm: farm,
      ),
      act: (bloc) => bloc.add(const FarmArchiveToggled()),
      expect: () => [
        const FarmDetailState(
          status: FarmDetailStatus.success,
          farmId: 'f1',
          farm: farm,
          isActionLoading: true,
        ),
        const FarmDetailState(
          status: FarmDetailStatus.success,
          farmId: 'f1',
          farm: FarmModel(id: 'f1', isActive: false),
          isActionLoading: false,
        ),
      ],
    );

    blocTest<FarmDetailBloc, FarmDetailState>(
      'deletes farm and sets isDeleted',
      build: () {
        when(() => remoteDataSource.deleteFarm('f1')).thenAnswer((_) async => true);
        return FarmDetailBloc(remoteDataSource);
      },
      seed: () => const FarmDetailState(
        status: FarmDetailStatus.success,
        farmId: 'f1',
        farm: farm,
      ),
      act: (bloc) => bloc.add(const FarmDeleted()),
      expect: () => [
        const FarmDetailState(
          status: FarmDetailStatus.success,
          farmId: 'f1',
          farm: farm,
          isActionLoading: true,
        ),
        const FarmDetailState(
          status: FarmDetailStatus.success,
          farmId: 'f1',
          farm: farm,
          isDeleted: true,
          isActionLoading: false,
        ),
      ],
    );
  });
}
