import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/support/sources/remote/support_remote_data_source.dart';

import 'create_ticket_event.dart';
import 'create_ticket_state.dart';

@injectable
class CreateTicketBloc extends Bloc<CreateTicketEvent, CreateTicketState> {
  CreateTicketBloc(this._supportRemoteDataSource)
    : super(const CreateTicketState()) {
    on<CreateTicketStarted>(_onStarted);
    on<CreateTicketFieldErrorCleared>(_onFieldErrorCleared);
    on<CreateTicketSubmitted>(_onSubmitted, transformer: droppable());
  }

  final SupportRemoteDataSource _supportRemoteDataSource;

  Future<void> _onStarted(
    CreateTicketStarted event,
    Emitter<CreateTicketState> emit,
  ) async {
    emit(state.copyWith(loadingOptions: true));
    try {
      final categoryOptions = await _supportRemoteDataSource
          .getTicketCategory();
      final cropOptions = await _supportRemoteDataSource.getCrops();
      emit(
        state.copyWith(
          loadingOptions: false,
          categoryOptions: categoryOptions,
          cropOptions: cropOptions,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: CreateTicketStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadingOptions: false,
          status: CreateTicketStatus.failure,
        ),
      );
    }
  }

  void _onFieldErrorCleared(
    CreateTicketFieldErrorCleared event,
    Emitter<CreateTicketState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    CreateTicketSubmitted event,
    Emitter<CreateTicketState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CreateTicketStatus.submitting,
        fieldErrors: const {},
      ),
    );
    try {
      final ok = await _supportRemoteDataSource.createTicket(
        categoryId: event.categoryId,
        subject: event.subject,
        question: event.question,
        cropId: event.cropId,
        photo: event.photo,
      );
      if (!ok) {
        emit(state.copyWith(status: CreateTicketStatus.failure));
        return;
      }
      emit(state.copyWith(status: CreateTicketStatus.success));
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: CreateTicketStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: CreateTicketStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: CreateTicketStatus.failure));
    }
  }
}
