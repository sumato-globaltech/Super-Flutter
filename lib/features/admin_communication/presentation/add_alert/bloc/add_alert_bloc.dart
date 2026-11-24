import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart';

import 'add_alert_event.dart';
import 'add_alert_state.dart';

@injectable
class AddAlertBloc extends Bloc<AddAlertEvent, AddAlertState> {
  AddAlertBloc(this._adminCommunicationRemoteDataSource)
    : super(const AddAlertState()) {
    on<AddAlertStarted>(_onStarted);
    on<AddAlertFieldErrorCleared>(_onFieldErrorCleared);
    on<AddAlertSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AdminCommunicationRemoteDataSource _adminCommunicationRemoteDataSource;

  Future<void> _onStarted(
    AddAlertStarted event,
    Emitter<AddAlertState> emit,
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
          status: AddAlertStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(loadingOptions: false, status: AddAlertStatus.failure),
      );
    }
  }

  void _onFieldErrorCleared(
    AddAlertFieldErrorCleared event,
    Emitter<AddAlertState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    AddAlertSubmitted event,
    Emitter<AddAlertState> emit,
  ) async {
    emit(
      state.copyWith(status: AddAlertStatus.submitting, fieldErrors: const {}),
    );
    try {
      final ok = await _adminCommunicationRemoteDataSource.addAlert(
        categoryId: event.categoryId,
        districtId: event.districtId,
        title: event.title,
        description: event.description,
        severity: event.severity,
        startsOn: event.startsOn,
        endsOn: event.endsOn,
      );
      if (!ok) {
        emit(state.copyWith(status: AddAlertStatus.failure));
        return;
      }
      emit(state.copyWith(status: AddAlertStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: AddAlertStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: AddAlertStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(state.copyWith(status: AddAlertStatus.failure));
    }
  }
}
