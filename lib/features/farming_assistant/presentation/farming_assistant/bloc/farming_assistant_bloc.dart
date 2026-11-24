import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/farming_assistant/sources/remote/farming_assistant_remote_data_source.dart';

import 'farming_assistant_event.dart';
import 'farming_assistant_state.dart';

@injectable
class FarmingAssistantBloc
    extends Bloc<FarmingAssistantEvent, FarmingAssistantState> {
  FarmingAssistantBloc(this._farmingAssistantRemoteDataSource)
    : super(const FarmingAssistantState()) {
    on<FarmingAssistantEvent>(_onEvent, transformer: droppable());
  }

  final FarmingAssistantRemoteDataSource _farmingAssistantRemoteDataSource;

  Future<void> _onEvent(
    FarmingAssistantEvent event,
    Emitter<FarmingAssistantState> emit,
  ) async {
    final String question;
    final List<AssistantMessage> messages;
    switch (event) {
      case QuestionAsked():
        question = event.question.trim();
        if (question.isEmpty) return;
        messages = [...state.messages, (text: question, mine: true)];
      case QuestionRetried():
        if (state.status != FarmingAssistantStatus.failure) return;
        messages = state.messages;
        question = messages.last.text;
      case ChatCleared():
        emit(const FarmingAssistantState());
        return;
    }
    emit(
      FarmingAssistantState(
        status: FarmingAssistantStatus.thinking,
        messages: messages,
      ),
    );
    String? message;
    try {
      final answer =
          (await _farmingAssistantRemoteDataSource.createAssistantAnswer(
            question: question,
          ))?.answer;
      if (answer != null && answer.isNotEmpty) {
        emit(
          FarmingAssistantState(
            messages: [...messages, (text: answer, mine: false)],
          ),
        );
        return;
      }
    } on AppException catch (e) {
      message = e.message;
    } catch (_) {}
    emit(
      FarmingAssistantState(
        status: FarmingAssistantStatus.failure,
        messages: messages,
        errorMessage: message,
      ),
    );
  }
}
