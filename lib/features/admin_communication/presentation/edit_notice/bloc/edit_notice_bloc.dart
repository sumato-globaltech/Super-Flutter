import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart';

import 'edit_notice_event.dart';
import 'edit_notice_state.dart';

@injectable
class EditNoticeBloc extends Bloc<EditNoticeEvent, EditNoticeState> {
  EditNoticeBloc(this._adminCommunicationRemoteDataSource)
    : super(const EditNoticeState()) {
    on<EditNoticeStarted>(_onStarted);
    on<EditNoticeFieldErrorCleared>(_onFieldErrorCleared);
    on<EditNoticeSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AdminCommunicationRemoteDataSource _adminCommunicationRemoteDataSource;

  Future<void> _onStarted(
    EditNoticeStarted event,
    Emitter<EditNoticeState> emit,
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
          status: EditNoticeStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(loadingOptions: false, status: EditNoticeStatus.failure),
      );
    }
  }

  void _onFieldErrorCleared(
    EditNoticeFieldErrorCleared event,
    Emitter<EditNoticeState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    EditNoticeSubmitted event,
    Emitter<EditNoticeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: EditNoticeStatus.submitting,
        fieldErrors: const {},
      ),
    );
    try {
      final ok = await _adminCommunicationRemoteDataSource.updateEditNotice(
        event.notice,
        categoryId: event.categoryId,
        title: event.title,
        bodyHtml: event.body,
        priority: event.priority,
        expiresOn: event.expiresOn,
      );
      if (!ok) {
        emit(state.copyWith(status: EditNoticeStatus.failure));
        return;
      }
      emit(state.copyWith(status: EditNoticeStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: EditNoticeStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: EditNoticeStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: EditNoticeStatus.failure));
    }
  }
}
