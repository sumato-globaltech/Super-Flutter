import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';
import 'package:super_flutter/features/farm/presentation/farm_form/bloc/farm_form_bloc.dart';
import 'package:super_flutter/features/farm/presentation/farm_form/bloc/farm_form_event.dart';
import 'package:super_flutter/features/farm/presentation/farm_form/bloc/farm_form_state.dart';

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
  );

  group('FarmFormBloc', () {
    test('initial state has initial status', () {
      final bloc = FarmFormBloc(remoteDataSource);
      expect(bloc.state.status, FarmFormStatus.initial);
      expect(bloc.state.isEditing, false);
      bloc.close();
    });

    blocTest<FarmFormBloc, FarmFormState>(
      'sets initialFarm on FarmFormInitialized',
      build: () => FarmFormBloc(remoteDataSource),
      act: (bloc) => bloc.add(const FarmFormInitialized(initialFarm: farm)),
      expect: () => [
        const FarmFormState(farm: farm),
      ],
    );

    blocTest<FarmFormBloc, FarmFormState>(
      'creates new farm when not editing',
      build: () {
        when(
          () => remoteDataSource.createFarm(any()),
        ).thenAnswer((_) async => farm);
        return FarmFormBloc(remoteDataSource);
      },
      act: (bloc) => bloc.add(
        const FarmFormSubmitted({'name': 'Green Hills Farm', 'area_ha': 2.5}),
      ),
      expect: () => [
        const FarmFormState(status: FarmFormStatus.loading),
        const FarmFormState(
          status: FarmFormStatus.success,
          farm: farm,
        ),
      ],
    );

    blocTest<FarmFormBloc, FarmFormState>(
      'updates existing farm when editing',
      build: () {
        when(
          () => remoteDataSource.updateFarm('f1', any()),
        ).thenAnswer((_) async => farm);
        return FarmFormBloc(remoteDataSource);
      },
      seed: () => const FarmFormState(farm: farm),
      act: (bloc) => bloc.add(
        const FarmFormSubmitted({'name': 'Updated Farm', 'area_ha': 3.0}),
      ),
      expect: () => [
        const FarmFormState(
          status: FarmFormStatus.loading,
          farm: farm,
        ),
        const FarmFormState(
          status: FarmFormStatus.success,
          farm: farm,
        ),
      ],
    );
  });
}
