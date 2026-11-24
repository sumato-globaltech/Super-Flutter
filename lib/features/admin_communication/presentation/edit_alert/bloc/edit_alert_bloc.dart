import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart';

import 'edit_alert_event.dart';
import 'edit_alert_state.dart';

@injectable
class EditAlertBloc extends Bloc<EditAlertEvent, EditAlertState> {
  EditAlertBloc(this._adminCommunicationRemoteDataSource)
    : super(const EditAlertState()) {
    on<EditAlertStarted>(_onStarted);
    on<EditAlertFieldErrorCleared>(_onFieldErrorCleared);
    on<EditAlertSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AdminCommunicationRemoteDataSource _adminCommunicationRemoteDataSource;

  Future<void> _onStarted(
    EditAlertStarted event,
    Emitter<EditAlertState> emit,
  ) async {
    emit(state.copyWith(loadingOptions: true));
    try {
      final categoryOptions = await _adminCommunicationRemoteDataSource
          .getAlertType();
      final districtOptions = await _adminCommunicationRemoteDataSource
          .getDistricts();
      final severityOptions = await _adminCommunicationRemoteDataSource
          .getSeverities();
      emit(
        state.copyWith(
          loadingOptions: false,
          categoryOptions: categoryOptions,
          districtOptions: districtOptions,
          severityOptions: severityOptions,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: EditAlertStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(loadingOptions: false, status: EditAlertStatus.failure),
      );
    }
  }

  void _onFieldErrorCleared(
    EditAlertFieldErrorCleared event,
    Emitter<EditAlertState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    EditAlertSubmitted event,
    Emitter<EditAlertState> emit,
  ) async {
    emit(
      state.copyWith(status: EditAlertStatus.submitting, fieldErrors: const {}),
    );
    try {
      final ok = await _adminCommunicationRemoteDataSource.updateEditAlert(
        event.alert,
        categoryId: event.categoryId,
        districtId: event.districtId,
        title: event.title,
        description: event.description,
        severity: event.severity,
        startsOn: event.startsOn,
        endsOn: event.endsOn,
      );
      if (!ok) {
        emit(state.copyWith(status: EditAlertStatus.failure));
        return;
      }
      emit(state.copyWith(status: EditAlertStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: EditAlertStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: EditAlertStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: EditAlertStatus.failure));
    }
  }
}
