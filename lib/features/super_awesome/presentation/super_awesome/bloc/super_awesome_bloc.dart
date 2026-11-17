import 'package:flutter_bloc/flutter_bloc.dart';

import 'super_awesome_event.dart';
import 'super_awesome_state.dart';

class SuperAwesomeBloc extends Bloc<SuperAwesomeEvent, SuperAwesomeState> {
  SuperAwesomeBloc() : super(const SuperAwesomeState()) {
    on<SuperAwesomeStarted>(_onStarted);
  }

  Future<void> _onStarted(
    SuperAwesomeStarted event,
    Emitter<SuperAwesomeState> emit,
  ) async {
    emit(state.copyWith(status: SuperAwesomeStatus.loading));
  }
}
