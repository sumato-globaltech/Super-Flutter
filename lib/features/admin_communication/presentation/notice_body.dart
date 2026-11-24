import 'dart:convert';

final _formatting = RegExp(r'<(strong|em|u|h2|h3|ul|ol|li|a)\b');

/// Whether [html] has formatting that plain text can't keep.
bool noticeBodyHasFormatting(String? html) => _formatting.hasMatch(html ?? '');

String noticeBodyToText(String? html) => (html ?? '')
    .replaceAll(RegExp(r'\s*\n\s*'), ' ')
    .replaceAll(RegExp(r'<br\s*/?>'), '\n')
    .replaceAll(RegExp('<li[^>]*>'), '• ')
    .replaceAll(RegExp('</li>'), '\n')
    .replaceAll(RegExp('</(p|h2|h3|ul|ol)>'), '\n\n')
    .replaceAll(RegExp('<[^>]+>'), '')
    .replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (m) => String.fromCharCode(int.parse(m[1]!)),
    )
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

String? noticeBodyToHtml(String text) {
  if (text.trim().isEmpty) return null;
  const escape = HtmlEscape(HtmlEscapeMode.element);
  return [
    for (final paragraph in text.trim().split(RegExp(r'\n\s*\n')))
      '<p>${escape.convert(paragraph).replaceAll('\n', '<br>')}</p>',
  ].join();
}
