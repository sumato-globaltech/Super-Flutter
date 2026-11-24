import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/schemes/model/scheme_model.dart';
import 'package:super_flutter/data/schemes/sources/remote/schemes_remote_data_source.dart';

import 'schemes_event.dart';
import 'schemes_state.dart';

@injectable
class SchemesBloc extends Bloc<SchemesEvent, SchemesState> {
  SchemesBloc(this._schemesRemoteDataSource) : super(const SchemesState()) {
    on<SchemesStarted>(_onStarted, transformer: restartable());
    on<SchemesMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final SchemesRemoteDataSource _schemesRemoteDataSource;

  Future<Paged<SchemeModel>> _page({required int page}) => state.officer
      ? _schemesRemoteDataSource.getOfficerSchemes(
          page: page,
          perPage: Paged.defaultPerPage,
        )
      : _schemesRemoteDataSource.getSchemes(
          page: page,
          perPage: Paged.defaultPerPage,
        );

  Future<void> _onStarted(
    SchemesStarted event,
    Emitter<SchemesState> emit,
  ) async {
    emit(state.copyWith(status: SchemesStatus.loading, officer: event.officer));
    try {
      final schemes = await _page(page: 1);
      emit(
        state.copyWith(
          status: SchemesStatus.success,
          schemes: schemes,
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(status: SchemesStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(state.copyWith(status: SchemesStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    SchemesMoreRequested event,
    Emitter<SchemesState> emit,
  ) async {
    final current = state.schemes;
    final page = current?.nextPage;
    if (current == null ||
        page == null ||
        state.loadingMore ||
        state.status == SchemesStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _page(page: page);
      // A refresh that finished meanwhile has the newer list.
      if (state.schemes != current) return;
      emit(
        state.copyWith(
          status: SchemesStatus.success,
          schemes: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: SchemesStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: SchemesStatus.failure, loadingMore: false));
    }
  }
}
