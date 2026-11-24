import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart';

import 'add_notice_event.dart';
import 'add_notice_state.dart';

@injectable
class AddNoticeBloc extends Bloc<AddNoticeEvent, AddNoticeState> {
  AddNoticeBloc(this._adminCommunicationRemoteDataSource)
    : super(const AddNoticeState()) {
    on<AddNoticeStarted>(_onStarted);
    on<AddNoticeFieldErrorCleared>(_onFieldErrorCleared);
    on<AddNoticeSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AdminCommunicationRemoteDataSource _adminCommunicationRemoteDataSource;

  Future<void> _onStarted(
    AddNoticeStarted event,
    Emitter<AddNoticeState> emit,
  ) async {
    emit(state.copyWith(loadingOptions: true));
    try {
      final categoryOptions = await _adminCommunicationRemoteDataSource
          .getNoticeType();
      final priorityOptions = await _adminCommunicationRemoteDataSource
          .getPriorities();
      emit(
        state.copyWith(
          loadingOptions: false,
          categoryOptions: categoryOptions,
          priorityOptions: priorityOptions,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: AddNoticeStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(loadingOptions: false, status: AddNoticeStatus.failure),
      );
    }
  }

  void _onFieldErrorCleared(
    AddNoticeFieldErrorCleared event,
    Emitter<AddNoticeState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    AddNoticeSubmitted event,
    Emitter<AddNoticeState> emit,
  ) async {
    emit(
      state.copyWith(status: AddNoticeStatus.submitting, fieldErrors: const {}),
    );
    try {
      final ok = await _adminCommunicationRemoteDataSource.addNotice(
        categoryId: event.categoryId,
        title: event.title,
        bodyHtml: event.body,
        priority: event.priority,
        expiresOn: event.expiresOn,
      );
      if (!ok) {
        emit(state.copyWith(status: AddNoticeStatus.failure));
        return;
      }
      emit(state.copyWith(status: AddNoticeStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: AddNoticeStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AddNoticeStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AddNoticeStatus.failure));
    }
  }
}
