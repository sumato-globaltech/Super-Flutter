import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';
import 'package:super_flutter/features/farm/presentation/farms_list/bloc/farms_bloc.dart';
import 'package:super_flutter/features/farm/presentation/farms_list/bloc/farms_event.dart';
import 'package:super_flutter/features/farm/presentation/farms_list/bloc/farms_state.dart';

class MockFarmRemoteDataSource extends Mock implements FarmRemoteDataSource {}

void main() {
  late MockFarmRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = MockFarmRemoteDataSource();
  });

  const farm1 = FarmModel(
    id: 'f1',
    name: 'Green Hills Farm',
    areaHa: 2.5,
    isActive: true,
  );

  const farm2 = FarmModel(
    id: 'f2',
    name: 'Valley View Farm',
    areaHa: 4.0,
    isActive: true,
  );

  group('FarmsBloc', () {
    test('initial state has empty items and initial status', () {
      final bloc = FarmsBloc(remoteDataSource);
      expect(bloc.state.status, FarmsListStatus.initial);
      expect(bloc.state.items, isEmpty);
      bloc.close();
    });

    blocTest<FarmsBloc, FarmsState>(
      'emits [loading, success] on FarmsStarted',
      build: () {
        when(
          () => remoteDataSource.getFarms(
            status: 'active',
            page: 1,
          ),
        ).thenAnswer(
          (_) async => const Paged(items: [farm1], page: 1, lastPage: 2),
        );
        return FarmsBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const FarmsStarted()),
      expect: () => [
        const FarmsState(status: FarmsListStatus.loading, statusFilter: 'active'),
        const FarmsState(
          status: FarmsListStatus.success,
          items: [farm1],
          statusFilter: 'active',
          page: 1,
          hasMore: true,
        ),
      ],
    );

    blocTest<FarmsBloc, FarmsState>(
      'emits [loading, success] on FarmsStatusFilterChanged to archived',
      build: () {
        when(
          () => remoteDataSource.getFarms(
            status: 'archived',
            page: 1,
          ),
        ).thenAnswer(
          (_) async => const Paged(items: [], page: 1, lastPage: 1),
        );
        return FarmsBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const FarmsStatusFilterChanged('archived')),
      expect: () => [
        const FarmsState(
          status: FarmsListStatus.loading,
          statusFilter: 'archived',
        ),
        const FarmsState(
          status: FarmsListStatus.success,
          items: [],
          statusFilter: 'archived',
          page: 1,
          hasMore: false,
        ),
      ],
    );

    blocTest<FarmsBloc, FarmsState>(
      'appends items on FarmsMoreRequested',
      build: () {
        when(
          () => remoteDataSource.getFarms(
            status: 'active',
            page: 2,
          ),
        ).thenAnswer(
          (_) async => const Paged(items: [farm2], page: 2, lastPage: 2),
        );
        return FarmsBloc(remoteDataSource);
      },
      seed: () => const FarmsState(
        status: FarmsListStatus.success,
        items: [farm1],
        statusFilter: 'active',
        page: 1,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const FarmsMoreRequested()),
      expect: () => [
        const FarmsState(
          status: FarmsListStatus.success,
          items: [farm1],
          statusFilter: 'active',
          page: 1,
          hasMore: true,
          loadingMore: true,
        ),
        const FarmsState(
          status: FarmsListStatus.success,
          items: [farm1, farm2],
          statusFilter: 'active',
          page: 2,
          hasMore: false,
          loadingMore: false,
        ),
      ],
    );

    blocTest<FarmsBloc, FarmsState>(
      'emits failure on error',
      build: () {
        when(
          () => remoteDataSource.getFarms(
            status: any(named: 'status'),
            page: 1,
          ),
        ).thenThrow(Exception('Server error'));
        return FarmsBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(const FarmsStarted()),
      expect: () => [
        const FarmsState(status: FarmsListStatus.loading),
        isA<FarmsState>()
            .having((s) => s.status, 'status', FarmsListStatus.failure)
            .having((s) => s.items, 'items', isEmpty),
      ],
    );
  });
}
