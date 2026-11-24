import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/support/sources/remote/support_remote_data_source.dart';

import 'ticket_detail_event.dart';
import 'ticket_detail_state.dart';

@injectable
class TicketDetailBloc extends Bloc<TicketDetailEvent, TicketDetailState> {
  TicketDetailBloc(this._supportRemoteDataSource)
    : super(const TicketDetailState()) {
    on<TicketDetailStarted>(_onStarted, transformer: restartable());
  }

  final SupportRemoteDataSource _supportRemoteDataSource;

  Future<void> _onStarted(
    TicketDetailStarted event,
    Emitter<TicketDetailState> emit,
  ) async {
    emit(state.copyWith(status: TicketDetailStatus.loading));
    try {
      final ticketDetails = await _supportRemoteDataSource.getTicket(
        event.ticket,
      );
      emit(
        state.copyWith(
          status: TicketDetailStatus.success,
          ticketDetails: ticketDetails,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: TicketDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: TicketDetailStatus.failure));
    }
  }
}
