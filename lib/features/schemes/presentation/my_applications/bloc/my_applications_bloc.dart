import 'package:flutter_bloc/flutter_bloc.dart';

import 'my_applications_event.dart';
import 'my_applications_state.dart';

class MyApplicationsBloc
    extends Bloc<MyApplicationsEvent, MyApplicationsState> {
  MyApplicationsBloc() : super(const MyApplicationsState()) {
    on<MyApplicationsStarted>(_onStarted);
  }

  Future<void> _onStarted(
    MyApplicationsStarted event,
    Emitter<MyApplicationsState> emit,
  ) async {
    emit(state.copyWith(status: MyApplicationsStatus.loading));
  }
}
