import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/schemes/model/scheme_application_model.dart';
import 'package:super_flutter/data/schemes/sources/remote/schemes_remote_data_source.dart';

import 'scheme_detail_event.dart';
import 'scheme_detail_state.dart';

@injectable
class SchemeDetailBloc extends Bloc<SchemeDetailEvent, SchemeDetailState> {
  SchemeDetailBloc(this._schemesRemoteDataSource)
    : super(const SchemeDetailState()) {
    on<SchemeDetailStarted>(_onStarted, transformer: restartable());
    on<SchemeApplied>(_onApplied, transformer: droppable());
  }

  final SchemesRemoteDataSource _schemesRemoteDataSource;

  Future<SchemeApplicationModel?> _applicationTo(String scheme) async {
    final applications = await _schemesRemoteDataSource.getSchemeApplications(
      perPage: 100,
    );
    for (final application in applications.items) {
      if (application.scheme?.id == scheme) return application;
    }
    return null;
  }

  Future<void> _onStarted(
    SchemeDetailStarted event,
    Emitter<SchemeDetailState> emit,
  ) async {
    emit(
      state.copyWith(status: SchemeDetailStatus.loading, farmer: event.farmer),
    );
    try {
      final schemeDetails = await _schemesRemoteDataSource.getScheme(
        event.scheme,
      );
      SchemeApplicationModel? application;
      if (event.farmer) {
        try {
          application = await _applicationTo(event.scheme);
        } catch (_) {}
      }
      emit(
        state.copyWith(
          status: SchemeDetailStatus.success,
          schemeDetails: schemeDetails,
          application: application,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: SchemeDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: SchemeDetailStatus.failure));
    }
  }

  Future<void> _onApplied(
    SchemeApplied event,
    Emitter<SchemeDetailState> emit,
  ) async {
    try {
      await _schemesRemoteDataSource.applyScheme(event.scheme);
      final application = await _applicationTo(event.scheme);
      emit(state.copyWith(application: application));
      event.completer.complete();
    } catch (e) {
      event.completer.completeError(e);
    }
  }
}
