import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';

import 'farm_form_event.dart';
import 'farm_form_state.dart';

@injectable
class FarmFormBloc extends Bloc<FarmFormEvent, FarmFormState> {
  FarmFormBloc(this._remoteDataSource) : super(const FarmFormState()) {
    on<FarmFormInitialized>(_onInitialized);
    on<FarmFormSubmitted>(_onSubmitted);
  }

  final FarmRemoteDataSource _remoteDataSource;

  void _onInitialized(
    FarmFormInitialized event,
    Emitter<FarmFormState> emit,
  ) {
    emit(state.copyWith(farm: event.initialFarm));
  }

  Future<void> _onSubmitted(
    FarmFormSubmitted event,
    Emitter<FarmFormState> emit,
  ) async {
    emit(state.copyWith(status: FarmFormStatus.loading));
    try {
      if (state.isEditing) {
        final updated = await _remoteDataSource.updateFarm(
          state.farm!.id!,
          event.data,
        );
        if (updated != null) {
          emit(
            state.copyWith(
              status: FarmFormStatus.success,
              farm: updated,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: FarmFormStatus.failure,
              errorMessage: 'Failed to update farm',
            ),
          );
        }
      } else {
        final created = await _remoteDataSource.createFarm(event.data);
        if (created != null) {
          emit(
            state.copyWith(
              status: FarmFormStatus.success,
              farm: created,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: FarmFormStatus.failure,
              errorMessage: 'Failed to create farm',
            ),
          );
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: FarmFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
