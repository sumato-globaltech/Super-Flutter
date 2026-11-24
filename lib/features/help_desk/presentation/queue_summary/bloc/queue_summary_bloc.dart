import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/help_desk/sources/remote/help_desk_remote_data_source.dart';

import 'queue_summary_event.dart';
import 'queue_summary_state.dart';

@injectable
class QueueSummaryBloc extends Bloc<QueueSummaryEvent, QueueSummaryState> {
  QueueSummaryBloc(this._helpDeskRemoteDataSource)
    : super(const QueueSummaryState()) {
    on<QueueSummaryStarted>(_onStarted, transformer: restartable());
  }

  final HelpDeskRemoteDataSource _helpDeskRemoteDataSource;

  Future<void> _onStarted(
    QueueSummaryStarted event,
    Emitter<QueueSummaryState> emit,
  ) async {
    emit(state.copyWith(status: QueueSummaryStatus.loading));
    try {
      final queueSummary = await _helpDeskRemoteDataSource.getQueueSummary();
      emit(
        state.copyWith(
          status: QueueSummaryStatus.success,
          queueSummary: queueSummary,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: QueueSummaryStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: QueueSummaryStatus.failure));
    }
  }
}
