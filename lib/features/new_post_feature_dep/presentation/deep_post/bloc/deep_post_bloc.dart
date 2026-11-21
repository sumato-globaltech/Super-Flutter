import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/new_post_feature_dep/sources/remote/new_post_feature_dep_remote_data_source.dart';

import 'deep_post_event.dart';
import 'deep_post_state.dart';

@injectable
class DeepPostBloc extends Bloc<DeepPostEvent, DeepPostState> {
  DeepPostBloc(this._newPostFeatureDepRemoteDataSource)
    : super(const DeepPostState()) {
    on<DeepPostStarted>(_onStarted);
    on<DeepPostFieldErrorCleared>(_onFieldErrorCleared);
    on<DeepPostSubmitted>(_onSubmitted, transformer: droppable());
  }

  final NewPostFeatureDepRemoteDataSource _newPostFeatureDepRemoteDataSource;

  Future<void> _onStarted(
    DeepPostStarted event,
    Emitter<DeepPostState> emit,
  ) async {
    emit(state.copyWith(loadingOptions: true));
    try {
      final districtOptions = await _newPostFeatureDepRemoteDataSource
          .getDistricts();
      emit(
        state.copyWith(loadingOptions: false, districtOptions: districtOptions),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: DeepPostStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: DeepPostStatus.failure,
          errorMessage: 'Could not load the form. Please try again.',
        ),
      );
    }
  }

  void _onFieldErrorCleared(
    DeepPostFieldErrorCleared event,
    Emitter<DeepPostState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    DeepPostSubmitted event,
    Emitter<DeepPostState> emit,
  ) async {
    emit(
      state.copyWith(status: DeepPostStatus.submitting, fieldErrors: const {}),
    );
    try {
      final ok = await _newPostFeatureDepRemoteDataSource.createDeepPost(
        name: event.name,
        districtId: event.districtId,
      );
      if (!ok) {
        emit(
          state.copyWith(
            status: DeepPostStatus.failure,
            errorMessage: 'The deep post was not created.',
          ),
        );
        return;
      }
      emit(state.copyWith(status: DeepPostStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: DeepPostStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: DeepPostStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DeepPostStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
