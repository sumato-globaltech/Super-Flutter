import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_colors.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
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

class FarmingAssistantView extends StatefulWidget {
  const FarmingAssistantView({super.key});

  @override
  State<FarmingAssistantView> createState() => _FarmingAssistantViewState();
}

class _FarmingAssistantViewState extends State<FarmingAssistantView> {
  final TextEditingController _questionController = TextEditingController();
  late final FarmingAssistantBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<FarmingAssistantBloc>();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _ask(String question) {
    if (question.trim().isEmpty || _bloc.state.isThinking) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _questionController.clear();
    _bloc.add(QuestionAsked(question));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<FarmingAssistantBloc, FarmingAssistantState>(
      builder: (context, state) {
        final messages = state.messages.reversed.toList();
        final failed = state.status == FarmingAssistantStatus.failure;
        final extra = state.isThinking || failed ? 1 : 0;
        return Scaffold(
          appBar: AppTopBar(title: l10n.farmingAssistantTitle),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? ListView(
                          padding: AppSpacing.pagePadding,
                          children: [
                            DesignCard(
                              title: l10n.farmingAssistantHello,
                              paddingChild: const EdgeInsets.fromLTRB(
                                14,
                                14,
                                14,
                                16,
                              ),
                              child: Text(
                                l10n.farmingAssistantIntro,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DesignCard(
                              title: l10n.farmingAssistantTry,
                              paddingChild: const EdgeInsets.fromLTRB(
                                14,
                                14,
                                14,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final (index, prompt) in [
                                    l10n.farmingAssistantPromptDisease,
                                    l10n.farmingAssistantPromptBanana,
                                  ].indexed)
                                    TitleDetailsCard(
                                      title: l10n.farmingAssistantAsk,
                                      text: prompt,
                                      isFirstItem: index == 0,
                                      showNavigateIcon: true,
                                      iconData: PhosphorIconsRegular.chatText,
                                      accentColor: DesignColor.accentName,
                                      onTap: () => _ask(prompt),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: AppSpacing.pagePadding,
                          itemCount: messages.length + extra,
                          itemBuilder: (context, index) {
                            if (index < extra) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: failed
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              state.errorMessage ??
                                                  l10n.errorUnknown,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        theme.colorScheme.error,
                                                  ),
                                            ),
                                            TextButton(
                                              onPressed: () => _bloc.add(
                                                const QuestionRetried(),
                                              ),
                                              child: Text(l10n.tryAgain),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const DesignProgress(),
                                            const SizedBox(width: 12),
                                            Text(l10n.farmingAssistantThinking),
                                          ],
                                        ),
                                ),
                              );
                            }
                            final message = messages[index - extra];
                            return Align(
                              alignment: message.mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                constraints: const BoxConstraints(
                                  maxWidth: 320,
                                ),
                                decoration: BoxDecoration(
                                  color: message.mine
                                      ? theme.colorScheme.primary
                                      : theme.appColors.cardWrapper,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: SelectableText(
                                  message.text,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: message.mine
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: AppSpacing.pagePadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionController,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 1000,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _ask,
                          decoration: InputDecoration(
                            hintText: l10n.farmingAssistantHint,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filled(
                        tooltip: l10n.farmingAssistantSend,
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        onPressed: state.isThinking
                            ? null
                            : () => _ask(_questionController.text),
                        icon: const Icon(PhosphorIconsFill.paperPlaneRight),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.farmingAssistantDisclaimer,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
