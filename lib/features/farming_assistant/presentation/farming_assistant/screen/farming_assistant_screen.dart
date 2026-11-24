import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/widgets/ai_chat.dart';
import 'package:super_flutter/features/farming_assistant/presentation/farming_assistant/bloc/farming_assistant_bloc.dart';
import 'package:super_flutter/features/farming_assistant/presentation/farming_assistant/bloc/farming_assistant_event.dart';
import 'package:super_flutter/features/farming_assistant/presentation/farming_assistant/bloc/farming_assistant_state.dart';

class FarmingAssistantScreen extends StatelessWidget {
  const FarmingAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FarmingAssistantBloc>(),
      child: const FarmingAssistantView(),
    );
  }
}

class FarmingAssistantView extends StatelessWidget {
  const FarmingAssistantView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<FarmingAssistantBloc>();
    return BlocBuilder<FarmingAssistantBloc, FarmingAssistantState>(
      builder: (context, state) => AiChat(
        title: l10n.farmingAssistantTitle,
        greeting: l10n.farmingAssistantHello,
        intro: l10n.farmingAssistantIntro,
        prompts: [
          l10n.farmingAssistantPromptDisease,
          l10n.farmingAssistantPromptBanana,
        ],
        hint: l10n.farmingAssistantHint,
        messages: state.messages,
        thinking: state.isThinking,
        failed: state.status == FarmingAssistantStatus.failure,
        errorMessage: state.errorMessage,
        onAsk: (question) => bloc.add(QuestionAsked(question)),
        onRetry: () => bloc.add(const QuestionRetried()),
        onClear: () => bloc.add(const ChatCleared()),
      ),
    );
  }
}
