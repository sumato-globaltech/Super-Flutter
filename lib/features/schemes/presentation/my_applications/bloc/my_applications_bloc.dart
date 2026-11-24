import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/schemes/sources/remote/schemes_remote_data_source.dart';

import 'my_applications_event.dart';
import 'my_applications_state.dart';

@injectable
class MyApplicationsBloc
    extends Bloc<MyApplicationsEvent, MyApplicationsState> {
  MyApplicationsBloc(this._schemesRemoteDataSource)
    : super(const MyApplicationsState()) {
    on<MyApplicationsStarted>(_onStarted, transformer: restartable());
    on<MyApplicationsMoreRequested>(_onMoreRequested, transformer: droppable());
    on<ApplicationWithdrawn>(_onWithdrawn, transformer: droppable());
    on<ApplicationDocumentUploaded>(_onUploaded, transformer: droppable());
  }

  final SchemesRemoteDataSource _schemesRemoteDataSource;

  Future<void> _reload(Emitter<MyApplicationsState> emit) async {
    final applications = await _schemesRemoteDataSource.getSchemeApplications(
      page: 1,
      perPage: Paged.defaultPerPage,
    );
    emit(
      state.copyWith(
        status: MyApplicationsStatus.success,
        applications: applications,
        loadingMore: false,
      ),
    );
  }

  Future<void> _onStarted(
    MyApplicationsStarted event,
    Emitter<MyApplicationsState> emit,
  ) async {
    emit(state.copyWith(status: MyApplicationsStatus.loading));
    try {
      await _reload(emit);
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: MyApplicationsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: MyApplicationsStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    MyApplicationsMoreRequested event,
    Emitter<MyApplicationsState> emit,
  ) async {
    final current = state.applications;
    final page = current?.nextPage;
    if (current == null || page == null || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _schemesRemoteDataSource.getSchemeApplications(
        page: page,
        perPage: Paged.defaultPerPage,
      );
      if (state.applications != current) return;
      emit(
        state.copyWith(
          status: MyApplicationsStatus.success,
          applications: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: MyApplicationsStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MyApplicationsStatus.failure,
          loadingMore: false,
        ),
      );
    }
  }

  Future<void> _onWithdrawn(
    ApplicationWithdrawn event,
    Emitter<MyApplicationsState> emit,
  ) async {
    try {
      await _schemesRemoteDataSource.withdrawApplication(event.application);
      await _reload(emit);
      event.completer.complete();
    } catch (e) {
      event.completer.completeError(e);
    }
  }

  Future<void> _onUploaded(
    ApplicationDocumentUploaded event,
    Emitter<MyApplicationsState> emit,
  ) async {
    try {
      await _schemesRemoteDataSource.createApplicationDocument(
        event.application,
        name: event.name,
        file: event.path,
      );
      await _reload(emit);
      event.completer.complete();
    } catch (e) {
      event.completer.completeError(e);
    }
  }
}
