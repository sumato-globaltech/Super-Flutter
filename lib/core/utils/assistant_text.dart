import 'package:material_ui/material_ui.dart';

typedef AssistantSpan = ({String text, bool bold});

/// Splits an answer into plain and bold parts, dropping Markdown's marks.
List<AssistantSpan> assistantSpans(String answer) {
  final lines = answer.replaceAll('\r\n', '\n').split('\n');
  final spans = <AssistantSpan>[];
  void add(String text, {required bool bold}) {
    if (text.isNotEmpty) spans.add((text: text, bold: bold));
  }

  for (final (index, raw) in lines.indexed) {
    final heading = RegExp(r'^#{1,6}\s+').hasMatch(raw);
    final line = raw
        .replaceFirst(RegExp(r'^#{1,6}\s+'), '')
        .replaceFirst(RegExp(r'^(\s*)[-*]\s+'), '• ');
    final parts = line.split('**');
    // An odd count of marks means the last one is just text.
    final paired = parts.length.isOdd;
    for (final (i, part) in parts.indexed) {
      final stray = !paired && i == parts.length - 1;
      add(stray ? '**$part' : part, bold: heading || (i.isOdd && !stray));
    }
    if (index < lines.length - 1) add('\n', bold: false);
  }
  return spans;
}

int assistantLength(List<AssistantSpan> spans) =>
    spans.fold(0, (sum, span) => sum + span.text.characters.length);

/// The first [count] characters of [spans].
TextSpan assistantTextSpan(
  List<AssistantSpan> spans, {
  required TextStyle? style,
  int? count,
  bool cursor = false,
}) {
  var left = count ?? -1;
  final children = <TextSpan>[];
  for (final span in spans) {
    if (left == 0) break;
    var text = span.text;
    if (left > 0) {
      final characters = text.characters;
      text = characters.take(left).toString();
      left -= characters.length < left ? characters.length : left;
    }
    children.add(
      TextSpan(
        text: text,
        style: span.bold ? const TextStyle(fontWeight: FontWeight.w700) : null,
      ),
    );
  }
  if (cursor) children.add(const TextSpan(text: ' ●'));
  return TextSpan(style: style, children: children);
}
