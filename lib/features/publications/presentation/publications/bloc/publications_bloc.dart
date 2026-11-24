import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/publications/sources/remote/publications_remote_data_source.dart';

import 'publications_event.dart';
import 'publications_state.dart';

@injectable
class PublicationsBloc extends Bloc<PublicationsEvent, PublicationsState> {
  PublicationsBloc(this._publicationsRemoteDataSource)
    : super(const PublicationsState()) {
    on<PublicationsStarted>(_onStarted, transformer: restartable());
    on<PublicationsMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final PublicationsRemoteDataSource _publicationsRemoteDataSource;

  Future<void> _onStarted(
    PublicationsStarted event,
    Emitter<PublicationsState> emit,
  ) async {
    emit(state.copyWith(status: PublicationsStatus.loading));
    try {
      final publications = await _publicationsRemoteDataSource.getPublications(
        page: 1,
        perPage: Paged.defaultPerPage,
      );
      emit(
        state.copyWith(
          status: PublicationsStatus.success,
          publications: publications,
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: PublicationsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: PublicationsStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    PublicationsMoreRequested event,
    Emitter<PublicationsState> emit,
  ) async {
    final current = state.publications;
    final page = current?.nextPage;
    if (current == null ||
        page == null ||
        state.loadingMore ||
        state.status == PublicationsStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _publicationsRemoteDataSource.getPublications(
        page: page,
        perPage: Paged.defaultPerPage,
      );
      // A refresh that finished meanwhile has the newer list.
      if (state.publications != current) return;
      emit(
        state.copyWith(
          status: PublicationsStatus.success,
          publications: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: PublicationsStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(status: PublicationsStatus.failure, loadingMore: false),
      );
    }
  }
}
