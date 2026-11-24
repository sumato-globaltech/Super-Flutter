import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/ui/widgets/ai_chat.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/sources/remote/national_farming_ai_assistant_remote_data_source.dart';
import 'package:uuid/uuid.dart';

import 'national_farming_ai_assistant_event.dart';
import 'national_farming_ai_assistant_state.dart';

@injectable
class NationalFarmingAiAssistantBloc
    extends
        Bloc<NationalFarmingAiAssistantEvent, NationalFarmingAiAssistantState> {
  NationalFarmingAiAssistantBloc(
    this._nationalFarmingAiAssistantRemoteDataSource,
  ) : super(const NationalFarmingAiAssistantState()) {
    on<NationalFarmingAiAssistantStarted>(_onStarted);
    on<NationalFarmingAiAssistantChatEvent>(_onChat, transformer: droppable());
    on<NationalFarmingAiAssistantLanguageChosen>((event, emit) async {
      emit(state.copyWith(language: event.language));
      await _loadQuestions(emit);
    });
    on<NationalFarmingAiAssistantLocationToggled>(
      (event, emit) => emit(state.copyWith(useLocation: event.useLocation)),
    );
    on<NationalFarmingAiAssistantPhotoChosen>(
      (event, emit) => emit(state.copyWith(photo: () => event.photo)),
    );
  }

  final NationalFarmingAiAssistantRemoteDataSource
  _nationalFarmingAiAssistantRemoteDataSource;

  /// The assistant remembers a chat by this id.
  String _sessionId = const Uuid().v4();

  String? _crop;

  Future<void> _onStarted(
    NationalFarmingAiAssistantStarted event,
    Emitter<NationalFarmingAiAssistantState> emit,
  ) async {
    _crop = event.crop;
    await Future.wait([_loadQuestions(emit), _loadLanguages(emit)]);
  }

  Future<void> _loadLanguages(
    Emitter<NationalFarmingAiAssistantState> emit,
  ) async {
    try {
      final languages = await _nationalFarmingAiAssistantRemoteDataSource
          .getNationalFarmingAiAssistantLanguages();
      emit(state.copyWith(languages: languages));
    } catch (_) {
      // The chat still works in English.
    }
  }

  Future<void> _loadQuestions(
    Emitter<NationalFarmingAiAssistantState> emit,
  ) async {
    final crop = _crop;
    final language = state.language;
    if (crop == null) return emit(state.copyWith(questions: const []));
    try {
      final questions = await _nationalFarmingAiAssistantRemoteDataSource
          .getNationalFarmingAiAssistantQuestions(
            crop: crop,
            language: language,
          );
      if (state.language != language) return;
      emit(
        state.copyWith(
          questions: [for (final item in questions) ?item.question],
          prefill: () => questions
              .where((item) => item.prefill ?? false)
              .firstOrNull
              ?.question,
        ),
      );
    } catch (_) {
      // The usual suggestions show instead.
      if (state.questions == null) emit(state.copyWith(questions: const []));
    }
  }

  Future<void> _onChat(
    NationalFarmingAiAssistantChatEvent event,
    Emitter<NationalFarmingAiAssistantState> emit,
  ) async {
    final List<AiMessage> messages;
    switch (event) {
      case NationalFarmingAiAssistantAsked():
        final question = event.question.trim();
        if (question.isEmpty) return;
        messages = [
          ...state.messages,
          (text: question, mine: true, image: state.photo),
        ];
      case NationalFarmingAiAssistantRetried():
        if (state.status != NationalFarmingAiAssistantStatus.failure) return;
        messages = state.messages;
      case NationalFarmingAiAssistantCleared():
        _sessionId = const Uuid().v4();
        emit(
          state.copyWith(
            status: NationalFarmingAiAssistantStatus.idle,
            messages: const [],
            errorMessage: () => null,
            photo: () => null,
          ),
        );
        return;
    }
    emit(
      state.copyWith(
        status: NationalFarmingAiAssistantStatus.thinking,
        messages: messages,
        errorMessage: () => null,
        photo: event is NationalFarmingAiAssistantAsked ? () => null : null,
      ),
    );
    String? message;
    try {
      final answer =
          (await _nationalFarmingAiAssistantRemoteDataSource
                  .createNationalFarmingAiAssistantAnswer(
                    question: messages.last.text,
                    sessionId: _sessionId,
                    language: state.language,
                    useLocation: state.useLocation,
                    image: messages.last.image,
                  ))
              ?.answer;
      if (answer != null && answer.isNotEmpty) {
        emit(
          state.copyWith(
            status: NationalFarmingAiAssistantStatus.idle,
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
        status: NationalFarmingAiAssistantStatus.failure,
        errorMessage: () => message,
      ),
    );
  }
}
