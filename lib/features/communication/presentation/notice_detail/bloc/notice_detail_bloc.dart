import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';

import 'notice_detail_event.dart';
import 'notice_detail_state.dart';

@injectable
class NoticeDetailBloc extends Bloc<NoticeDetailEvent, NoticeDetailState> {
  NoticeDetailBloc(this._communicationRemoteDataSource)
    : super(const NoticeDetailState()) {
    on<NoticeDetailStarted>(_onStarted, transformer: restartable());
  }

  final CommunicationRemoteDataSource _communicationRemoteDataSource;

  Future<void> _onStarted(
    NoticeDetailStarted event,
    Emitter<NoticeDetailState> emit,
  ) async {
    emit(state.copyWith(status: NoticeDetailStatus.loading));
    try {
      final notice = await _communicationRemoteDataSource.getNotice(
        event.noticeId,
      );
      emit(state.copyWith(status: NoticeDetailStatus.loaded, notice: notice));
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: NoticeDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: NoticeDetailStatus.failure,
          errorMessage: 'Could not load the notice.',
        ),
      );
    }
  }
}
