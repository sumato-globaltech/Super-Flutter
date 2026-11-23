import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';
import 'package:super_flutter/features/crops/presentation/crops_list/bloc/crops_list_bloc.dart';
import 'package:super_flutter/features/crops/presentation/crops_list/bloc/crops_list_event.dart';
import 'package:super_flutter/features/crops/presentation/crops_list/bloc/crops_list_state.dart';

class MockCropRemoteDataSource extends Mock implements CropRemoteDataSource {}

void main() {
  late MockCropRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = MockCropRemoteDataSource();
  });

  final crop1 = const CropModel(
    id: 'c1',
    name: 'Ginger',
    slug: 'ginger',
    type: CropTypeModel(id: 't1', name: 'Spices', slug: 'spices'),
    durationDays: 240,
  );

  final crop2 = const CropModel(
    id: 'c2',
    name: 'Cardamom',
    slug: 'cardamom',
    type: CropTypeModel(id: 't1', name: 'Spices', slug: 'spices'),
    durationDays: 300,
  );

  group('CropsListBloc', () {
    test('initial state has empty items and initial status', () {
      final bloc = CropsListBloc(remoteDataSource);
      expect(bloc.state.status, CropsListStatus.initial);
      expect(bloc.state.items, isEmpty);
      bloc.close();
    });

    blocTest<CropsListBloc, CropsListState>(
      'emits [loading, success] on CropsListStarted',
      build: () {
        when(
          () => remoteDataSource.getCrops(
            search: any(named: 'search'),
            type: any(named: 'type'),
            page: any(named: 'page'),
          ),
        ).thenAnswer(
          (_) async => Paged(items: [crop1], page: 1, lastPage: 2),
        );
        return CropsListBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const CropsListStarted()),
      expect: () => [
        const CropsListState(status: CropsListStatus.loading),
        CropsListState(
          status: CropsListStatus.success,
          items: [crop1],
          page: 1,
          hasMore: true,
        ),
      ],
    );

    blocTest<CropsListBloc, CropsListState>(
      'appends items on CropsListMoreRequested',
      build: () {
        when(
          () => remoteDataSource.getCrops(
            search: any(named: 'search'),
            type: any(named: 'type'),
            page: 2,
          ),
        ).thenAnswer(
          (_) async => Paged(items: [crop2], page: 2, lastPage: 2),
        );
        return CropsListBloc(remoteDataSource);
      },
      seed: () => CropsListState(
        status: CropsListStatus.success,
        items: [crop1],
        page: 1,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const CropsListMoreRequested()),
      expect: () => [
        CropsListState(
          status: CropsListStatus.success,
          items: [crop1],
          page: 1,
          hasMore: true,
          loadingMore: true,
        ),
        CropsListState(
          status: CropsListStatus.success,
          items: [crop1, crop2],
          page: 2,
          hasMore: false,
          loadingMore: false,
        ),
      ],
    );

    blocTest<CropsListBloc, CropsListState>(
      'filters by type on CropsListTypeSelected',
      build: () {
        when(
          () => remoteDataSource.getCrops(
            search: any(named: 'search'),
            type: 'spices',
            page: 1,
          ),
        ).thenAnswer(
          (_) async => Paged(items: [crop1, crop2], page: 1, lastPage: 1),
        );
        return CropsListBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const CropsListTypeSelected('spices')),
      expect: () => [
        const CropsListState(
          status: CropsListStatus.loading,
          selectedType: 'spices',
        ),
        CropsListState(
          status: CropsListStatus.success,
          items: [crop1, crop2],
          selectedType: 'spices',
          page: 1,
          hasMore: false,
        ),
      ],
    );

    blocTest<CropsListBloc, CropsListState>(
      'searches by query on CropsListSearchChanged',
      build: () {
        when(
          () => remoteDataSource.getCrops(
            search: 'Card',
            type: any(named: 'type'),
            page: 1,
          ),
        ).thenAnswer(
          (_) async => Paged(items: [crop2], page: 1, lastPage: 1),
        );
        return CropsListBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const CropsListSearchChanged('Card')),
      expect: () => [
        const CropsListState(
          status: CropsListStatus.loading,
          search: 'Card',
        ),
        CropsListState(
          status: CropsListStatus.success,
          items: [crop2],
          search: 'Card',
          page: 1,
          hasMore: false,
        ),
      ],
    );

    blocTest<CropsListBloc, CropsListState>(
      'emits failure on error',
      build: () {
        when(
          () => remoteDataSource.getCrops(
            search: any(named: 'search'),
            type: any(named: 'type'),
            page: 1,
          ),
        ).thenThrow(Exception('Server error'));
        return CropsListBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const CropsListStarted()),
      expect: () => [
        const CropsListState(status: CropsListStatus.loading),
        isA<CropsListState>()
            .having((s) => s.status, 'status', CropsListStatus.failure)
            .having((s) => s.items, 'items', isEmpty),
      ],
    );
  });
}
