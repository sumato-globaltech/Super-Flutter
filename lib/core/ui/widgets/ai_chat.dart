import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/extensions/context_extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/utils/assistant_text.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ai_sparkle.dart';
import 'app_top_bar.dart';
import 'typing_dots.dart';

typedef AiMessage = ({String text, bool mine, String? image});

/// A whole AI chat page; its bloc keeps the messages and asks the questions.
class AiChat extends StatefulWidget {
  const AiChat({
    required this.title,
    required this.greeting,
    required this.intro,
    required this.prompts,
    required this.hint,
    required this.messages,
    required this.thinking,
    required this.failed,
    required this.onAsk,
    required this.onRetry,
    required this.onClear,
    this.errorMessage,
    this.tools,
    this.leading,
    this.emptyQuestion,
    this.prefill,
    super.key,
  });

  final String title;
  final String greeting;
  final String intro;
  final List<String> prompts;
  final String hint;
  final List<AiMessage> messages;
  final bool thinking;
  final bool failed;
  final String? errorMessage;
  final ValueChanged<String> onAsk;
  final VoidCallback onRetry;
  final VoidCallback onClear;

  /// Shown above the input.
  final Widget? tools;

  /// Shown inside the input, before the text.
  final Widget? leading;

  /// Asked when nothing is typed, such as with a photo.
  final String? emptyQuestion;

  /// Put in the input, unless the user already typed or asked something.
  final String? prefill;

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> with SingleTickerProviderStateMixin {
  static const _perCharacter = Duration(milliseconds: 16);
  static const _longest = Duration(seconds: 10);

  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// How much of the newest answer is typed out.
  late final AnimationController _typing = AnimationController(
    vsync: this,
    value: 1,
  );

  @override
  void didUpdateWidget(AiChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prefill = widget.prefill;
    if (prefill != null &&
        prefill != oldWidget.prefill &&
        widget.messages.isEmpty &&
        (_questionController.text.isEmpty ||
            _questionController.text == oldWidget.prefill)) {
      _questionController.text = prefill;
    }
    if (widget.messages.length <= oldWidget.messages.length) return;
    final newest = widget.messages.last;
    if (!newest.mine) _type(newest.text);
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
    final text = question.trim().isEmpty
        ? widget.emptyQuestion ?? ''
        : question;
    if (text.isEmpty || widget.thinking) return;
    _typing.value = 1;
    FocusManager.instance.primaryFocus?.unfocus();
    _questionController.clear();
    widget.onAsk(text);
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
    final messages = widget.messages.reversed.toList();
    final failed = widget.failed;
    final extra = widget.thinking || failed ? 1 : 0;
    return Scaffold(
      appBar: AppTopBar(
        titleWidget: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 15),
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              tooltip: l10n.farmingAssistantNew,
              icon: const Icon(PhosphorIconsRegular.notePencil),
              onPressed: widget.thinking
                  ? null
                  : () {
                      _typing.value = 1;
                      widget.onClear();
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
                              widget.greeting,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.intro,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.appColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            for (final prompt in widget.prompts)
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
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            PhosphorIconsRegular.arrowUpRight,
                                            size: 18,
                                            color:
                                                theme.appColors.textSecondary,
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
                                AiSparkle(animate: widget.thinking),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: failed
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.errorMessage ??
                                                  l10n.errorUnknown,
                                              style: body?.copyWith(
                                                color: theme.colorScheme.error,
                                              ),
                                            ),
                                            TextButton.icon(
                                              onPressed: widget.onRetry,
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
                                              label:
                                                  l10n.farmingAssistantThinking,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (message.image case final image?)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(image),
                                          height: 160,
                                          cacheHeight: 480,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => const Icon(
                                            PhosphorIconsRegular.image,
                                          ),
                                        ),
                                      ),
                                    ),
                                  SelectableText(message.text, style: body),
                                ],
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AiSparkle(animate: typing),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: typing
                                          ? Text.rich(
                                              assistantTextSpan(
                                                spans,
                                                style: body,
                                                cursor: true,
                                                count:
                                                    (assistantLength(spans) *
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
                                                  tooltip:
                                                      l10n.farmingAssistantCopy,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  iconSize: 18,
                                                  padding: EdgeInsets.zero,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  icon: Icon(
                                                    PhosphorIconsRegular.copy,
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
            ?widget.tools,
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
                  ?widget.leading,
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
                        hintText: widget.hint,
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
                          !widget.thinking &&
                          (_questionController.text.trim().isNotEmpty ||
                              widget.emptyQuestion != null);
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
  }
}
