import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/ui/widgets/ai_chat.dart';
import 'package:super_flutter/data/vistaar/sources/remote/vistaar_remote_data_source.dart';
import 'package:uuid/uuid.dart';

import 'vistaar_event.dart';
import 'vistaar_state.dart';

@injectable
class VistaarBloc extends Bloc<VistaarEvent, VistaarState> {
  VistaarBloc(this._vistaarRemoteDataSource) : super(const VistaarState()) {
    on<VistaarStarted>(_onStarted);
    on<VistaarChatEvent>(_onChat, transformer: droppable());
    on<VistaarLanguageChosen>(
      (event, emit) => emit(state.copyWith(language: event.language)),
    );
    on<VistaarLocationToggled>(
      (event, emit) => emit(state.copyWith(useLocation: event.useLocation)),
    );
    on<VistaarPhotoChosen>(
      (event, emit) => emit(state.copyWith(photo: () => event.photo)),
    );
  }

  final VistaarRemoteDataSource _vistaarRemoteDataSource;

  /// Vistaar remembers a chat by this id.
  String _sessionId = const Uuid().v4();

  Future<void> _onStarted(
    VistaarStarted event,
    Emitter<VistaarState> emit,
  ) async {
    try {
      final languages = await _vistaarRemoteDataSource.getVistaarLanguages();
      emit(state.copyWith(languages: languages));
    } catch (_) {
      // The chat still works in English.
    }
  }

  Future<void> _onChat(
    VistaarChatEvent event,
    Emitter<VistaarState> emit,
  ) async {
    final List<AiMessage> messages;
    switch (event) {
      case VistaarAsked():
        final question = event.question.trim();
        if (question.isEmpty) return;
        messages = [
          ...state.messages,
          (text: question, mine: true, image: state.photo),
        ];
      case VistaarRetried():
        if (state.status != VistaarStatus.failure) return;
        messages = state.messages;
      case VistaarCleared():
        _sessionId = const Uuid().v4();
        emit(
          state.copyWith(
            status: VistaarStatus.idle,
            messages: const [],
            errorMessage: () => null,
            photo: () => null,
          ),
        );
        return;
    }
    emit(
      state.copyWith(
        status: VistaarStatus.thinking,
        messages: messages,
        errorMessage: () => null,
        photo: event is VistaarAsked ? () => null : null,
      ),
    );
    String? message;
    try {
      final answer = (await _vistaarRemoteDataSource.createVistaarAnswer(
        question: messages.last.text,
        sessionId: _sessionId,
        language: state.language,
        useLocation: state.useLocation,
        image: messages.last.image,
      ))?.answer;
      if (answer != null && answer.isNotEmpty) {
        emit(
          state.copyWith(
            status: VistaarStatus.idle,
            messages: [...messages, (text: answer, mine: false, image: null)],
          ),
        );
        return;
      }
    } on AppException catch (e) {
      message = e.message;
    } catch (_) {}
    emit(
      state.copyWith(
        status: VistaarStatus.failure,
        errorMessage: () => message,
      ),
    );
  }
}
