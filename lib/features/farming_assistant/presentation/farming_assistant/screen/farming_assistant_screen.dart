import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_colors.dart';
import 'package:super_flutter/core/ui/theme/app_spacing.dart';
import 'package:super_flutter/core/ui/widgets/ai_sparkle.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';
import 'package:super_flutter/core/ui/widgets/typing_dots.dart';
import 'package:super_flutter/features/farming_assistant/presentation/assistant_text.dart';
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

class _FarmingAssistantViewState extends State<FarmingAssistantView>
    with SingleTickerProviderStateMixin {
  static const _perCharacter = Duration(milliseconds: 16);
  static const _longest = Duration(seconds: 10);

  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// How much of the newest answer is typed out.
  late final AnimationController _typing = AnimationController(
    vsync: this,
    value: 1,
  );
  late final FarmingAssistantBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<FarmingAssistantBloc>();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _typing.dispose();
    super.dispose();
  }

  void _type(String answer) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final wanted = _perCharacter * assistantLength(assistantSpans(answer));
    _typing
      ..duration = wanted < _longest ? wanted : _longest
      ..forward(from: 0);
  }

  void _ask(String question) {
    if (question.trim().isEmpty || _bloc.state.isThinking) return;
    _typing.value = 1;
    FocusManager.instance.primaryFocus?.unfocus();
    _questionController.clear();
    _bloc.add(QuestionAsked(question));
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyLarge?.copyWith(
      height: 1.5,
      color: theme.colorScheme.onSurface,
    );
    return BlocConsumer<FarmingAssistantBloc, FarmingAssistantState>(
      listenWhen: (prev, curr) => curr.messages.length > prev.messages.length,
      listener: (context, state) {
        final newest = state.messages.last;
        if (!newest.mine) _type(newest.text);
      },
      builder: (context, state) {
        final messages = state.messages.reversed.toList();
        final failed = state.status == FarmingAssistantStatus.failure;
        final extra = state.isThinking || failed ? 1 : 0;
        return Scaffold(
          appBar: AppTopBar(
            title: l10n.farmingAssistantTitle,
            actions: [
              if (messages.isNotEmpty)
                IconButton(
                  tooltip: l10n.farmingAssistantNew,
                  icon: const Icon(PhosphorIconsRegular.notePencil),
                  onPressed: state.isThinking
                      ? null
                      : () {
                          _typing.value = 1;
                          _bloc.add(const ChatCleared());
                        },
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const AiSparkle(size: 64, animate: true),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.farmingAssistantHello,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.farmingAssistantIntro,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.appColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                for (final prompt in [
                                  l10n.farmingAssistantPromptDisease,
                                  l10n.farmingAssistantPromptBanana,
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Material(
                                      color: theme.appColors.cardWrapper,
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () => _ask(prompt),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  prompt,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                PhosphorIconsRegular
                                                    .arrowUpRight,
                                                size: 18,
                                                color: theme
                                                    .appColors
                                                    .textSecondary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: messages.length + extra,
                          itemBuilder: (context, index) {
                            if (index < extra) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AiSparkle(animate: state.isThinking),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: failed
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  state.errorMessage ??
                                                      l10n.errorUnknown,
                                                  style: body?.copyWith(
                                                    color:
                                                        theme.colorScheme.error,
                                                  ),
                                                ),
                                                TextButton.icon(
                                                  onPressed: () => _bloc.add(
                                                    const QuestionRetried(),
                                                  ),
                                                  icon: const Icon(
                                                    PhosphorIconsRegular
                                                        .arrowClockwise,
                                                    size: 18,
                                                  ),
                                                  label: Text(l10n.tryAgain),
                                                ),
                                              ],
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                top: 12,
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Semantics(
                                                  liveRegion: true,
                                                  label: l10n
                                                      .farmingAssistantThinking,
                                                  child: const TypingDots(),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final at = index - extra;
                            final message = messages[at];
                            if (message.mine) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 20,
                                    left: 48,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.appColors.cardWrapper,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: SelectableText(
                                    message.text,
                                    style: body,
                                  ),
                                ),
                              );
                            }
                            final spans = assistantSpans(message.text);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: AnimatedBuilder(
                                animation: _typing,
                                builder: (context, _) {
                                  final typing = at == 0 && _typing.value < 1;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AiSparkle(animate: typing),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 3,
                                          ),
                                          child: typing
                                              ? Text.rich(
                                                  assistantTextSpan(
                                                    spans,
                                                    style: body,
                                                    cursor: true,
                                                    count:
                                                        (assistantLength(
                                                                  spans,
                                                                ) *
                                                                _typing.value)
                                                            .floor(),
                                                  ),
                                                  semanticsLabel: message.text,
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SelectableText.rich(
                                                      assistantTextSpan(
                                                        spans,
                                                        style: body,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      tooltip: l10n
                                                          .farmingAssistantCopy,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      iconSize: 18,
                                                      padding: EdgeInsets.zero,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      icon: Icon(
                                                        PhosphorIconsRegular
                                                            .copy,
                                                        color: theme
                                                            .appColors
                                                            .textSecondary,
                                                      ),
                                                      onPressed: () async {
                                                        await Clipboard.setData(
                                                          ClipboardData(
                                                            text: spans
                                                                .map(
                                                                  (span) =>
                                                                      span.text,
                                                                )
                                                                .join(),
                                                          ),
                                                        );
                                                        if (!context.mounted) {
                                                          return;
                                                        }
                                                        context.showSnackBar(
                                                          l10n.farmingAssistantCopied,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                  padding: const EdgeInsets.fromLTRB(16, 4, 6, 4),
                  decoration: BoxDecoration(
                    color: theme.appColors.field,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: theme.appColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionController,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: 1000,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _ask,
                          style: body,
                          decoration: InputDecoration(
                            hintText: l10n.farmingAssistantHint,
                            counterText: '',
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ListenableBuilder(
                        listenable: Listenable.merge([
                          _questionController,
                          _typing,
                        ]),
                        builder: (context, _) {
                          final typing = _typing.value < 1;
                          final ready =
                              !state.isThinking &&
                              _questionController.text.trim().isNotEmpty;
                          return IconButton.filled(
                            tooltip: typing
                                ? l10n.farmingAssistantStop
                                : l10n.farmingAssistantSend,
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              disabledBackgroundColor: theme.appColors.border,
                              disabledForegroundColor:
                                  theme.appColors.textSecondary,
                            ),
                            onPressed: typing
                                ? () => _typing.value = 1
                                : ready
                                ? () => _ask(_questionController.text)
                                : null,
                            icon: Icon(
                              typing
                                  ? PhosphorIconsFill.stop
                                  : PhosphorIconsBold.arrowUp,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.farmingAssistantDisclaimer,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.appColors.textSecondary,
                    ),
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
