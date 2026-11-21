import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/extensions/extensions.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/design_colors.dart';
import 'confirm_sheet.dart';
import 'image_preview.dart';
import 'shimmer_card.dart';

class ShadTextColors {
  ShadTextColors._();
  static const Color foregroundLight = Color(0xFF020817);
  static const Color foregroundDark = Color(0xFFF8FAFC);
  static const Color mutedForegroundLight = Color(0xFF64748B);
  static const Color mutedForegroundDark = Color(0xFF94A3B8);
  static Color foreground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? foregroundDark
      : foregroundLight;
  static Color mutedForeground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? mutedForegroundDark
      : mutedForegroundLight;
}

class _ReadMoreValue extends StatefulWidget {
  const _ReadMoreValue({
    required this.title,
    required this.text,
    required this.style,
    required this.isStart,
    required this.trimLines,
    this.iconData,
    this.accentColor,
  });

  final String title;
  final String text;
  final TextStyle style;
  final bool isStart;
  final int trimLines;
  final IconData? iconData;
  final Color? accentColor;

  @override
  State<_ReadMoreValue> createState() => _ReadMoreValueState();
}

class _ReadMoreValueState extends State<_ReadMoreValue> {
  late final TapGestureRecognizer _tapRecognizer = TapGestureRecognizer()
    ..onTap = _openSheet;

  static const String _ellipsis = '… ';

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  void _openSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      builder: (sheetContext) => ConfirmSheet(
        title: widget.title,
        description: '',
        icon: Icon(
          widget.iconData ?? PhosphorIconsRegular.textAlignLeft,
          size: 35,
          color: widget.accentColor ?? theme.colorScheme.primary,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.5,
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: SelectableText(
                widget.text,
                textAlign: TextAlign.start,
                // style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = Directionality.of(context);
    final textAlign = widget.isStart ? TextAlign.start : TextAlign.end;
    final linkLabel = AppLocalizations.of(context).readMore;
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final linkStyle = style.copyWith(
      color: theme.appColors.accent,
      fontWeight: FontWeight.w600,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          textScaler: MediaQuery.textScalerOf(context),
          textDirection: textDirection,
          textAlign: textAlign,
          maxLines: widget.trimLines,
        )..layout(maxWidth: maxWidth);

        if (!textPainter.didExceedMaxLines) {
          return Text(widget.text, style: widget.style, textAlign: textAlign);
        }

        final linkPainter = TextPainter(
          text: TextSpan(text: '$_ellipsis$linkLabel', style: linkStyle),
          textDirection: textDirection,
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();

        final cutPosition = textPainter.getPositionForOffset(
          Offset(
            textPainter.width - linkPainter.width,
            textPainter.height - textPainter.preferredLineHeight / 2,
          ),
        );
        final endIndex =
            (textPainter.getOffsetBefore(cutPosition.offset) ??
                    cutPosition.offset)
                .clamp(0, widget.text.length);

        return Text.rich(
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: widget.trimLines,
          TextSpan(
            style: widget.style,
            children: [
              TextSpan(
                text:
                    '${widget.text.substring(0, endIndex).trimRight()}'
                    '$_ellipsis',
              ),
              TextSpan(
                text: linkLabel,
                style: linkStyle,
                recognizer: _tapRecognizer,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CopyableValue extends StatefulWidget {
  const _CopyableValue({
    required this.text,
    required this.child,
    required this.isStart,
  });

  final String text;

  final Widget child;
  final bool isStart;

  @override
  State<_CopyableValue> createState() => _CopyableValueState();
}

class _CopyableValueState extends State<_CopyableValue> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[
      Flexible(child: widget.child),
      6.width,
      GestureDetector(
        onTap: _copy,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              _copied ? PhosphorIconsBold.check : PhosphorIconsRegular.copy,
              key: ValueKey<bool>(_copied),
              size: 14,
              color: _copied
                  ? theme.appColors.success
                  : ShadTextColors.mutedForeground(context),
            ),
          ),
        ),
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.isStart
          ? children
          : children.reversed.toList(growable: false),
    );
  }
}

class _Thumbnails extends StatelessWidget {
  const _Thumbnails({required this.urls, required this.size, this.title});

  final List<String?> urls;
  final String? title;
  final double size;
  // final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    final radius = BorderRadius.circular(9);

    return SizedBox(
      height: size,
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        child: Row(
          children: urls
              .whereType<String>()
              .where((url) => url.isNotEmpty)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () =>
                        ImagePreview.show(context, imageUrl: e, title: title),
                    child: Container(
                      width: size,
                      height: size,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: appColors.cardWrapper,
                        borderRadius: radius,
                        border: Border.all(color: appColors.cardRing),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: e,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Center(
                          child: SizedBox(
                            width: size * 0.35,
                            height: size * 0.35,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: appColors.textSecondary,
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => Icon(
                          PhosphorIconsRegular.imageBroken,
                          size: size * 0.4,
                          color: appColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class TitleDetailsCard extends StatelessWidget {
  const TitleDetailsCard({
    super.key,
    required this.title,
    this.text,
    this.child,
    this.isTextLoading,
    this.isCrossAxisAlignmentStart = true,
    this.color,
    this.colorTitle,
    this.titleFontSize,
    this.textFontSize,
    this.colorBGHighlight,
    this.isColumn = true,
    this.isBlockquote = false,
    this.isFirstItem = false,
    this.icon,
    this.iconData,
    this.accentColor,
    this.onTap,
    this.imagePreviewUrls,
    this.imageSize = 44,
    this.isCopyable = false,
    this.isReadMore = false,
    this.readMoreLines = 2,
    this.showNavigateIcon = false,
  });

  final String title;
  final String? text;
  final Widget? child;
  final bool? isTextLoading;
  final bool isCrossAxisAlignmentStart;
  final Color? color;
  final Color? colorTitle;
  final Color? colorBGHighlight;
  final double? titleFontSize;
  final double? textFontSize;
  final bool isColumn;
  final Widget? icon;
  final bool isBlockquote;
  final bool isFirstItem;
  final bool showNavigateIcon;
  final GestureTapCallback? onTap;
  final IconData? iconData;
  final Color? accentColor;

  final List<String?>? imagePreviewUrls;
  final double imageSize;

  final bool isCopyable;

  final bool isReadMore;
  final int readMoreLines;

  Widget _accentLayout(
    BuildContext context,
    TextStyle titleStyle,
    TextStyle valueStyle,
    TextStyle blockquoteStyle,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = accentColor == null
        ? null
        : _readableOn(accentColor!, theme.appColors.cardContent, isDark);
    final chip = Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            accent?.withValues(alpha: isDark ? 0.22 : 0.12) ??
            DesignColor.slate700.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child:
          icon ??
          Icon(iconData, size: 16, color: accent?.withValues(alpha: 0.95)),
    );
    final linkonClick = title.isNotEmpty
        ? <Widget>[
            Flexible(
              child: Text(
                title,
                textAlign: isCrossAxisAlignmentStart
                    ? TextAlign.start
                    : TextAlign.end,
                style: titleStyle.copyWith(
                  fontSize: titleFontSize ?? 11,
                  color: colorTitle ?? ShadTextColors.mutedForeground(context),
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (onTap != null || showNavigateIcon) ...[
              4.width,
              const Icon(
                PhosphorIconsBold.link,
                size: 12,
                color: Colors.blueAccent,
              ),
            ],
          ]
        : <Widget>[];

    final resolvedValueStyle = isBlockquote
        ? blockquoteStyle
        : valueStyle.copyWith(fontWeight: FontWeight.w600);

    final value = (isTextLoading != null && isTextLoading == true)
        ? SizedBox(
            height: 16,
            child: Column(
              children: [7.height, const ShimmerCard(height: 8.5, width: 60)],
            ),
          )
        : text != null
        ? (isReadMore && text?.isNotEmpty == true
              ? _ReadMoreValue(
                  title: title,
                  text: text!,
                  style: resolvedValueStyle,
                  isStart: isCrossAxisAlignmentStart,
                  trimLines: readMoreLines,
                  iconData: iconData,
                  accentColor: accentColor,
                )
              : Text(
                  text ?? "",
                  style: resolvedValueStyle,
                  textAlign: isCrossAxisAlignmentStart
                      ? TextAlign.start
                      : TextAlign.end,
                ))
        : child;

    final labels = Column(
      crossAxisAlignment: isCrossAxisAlignmentStart
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isCrossAxisAlignmentStart
              ? linkonClick
              : linkonClick.reversed.toList(growable: false),
        ),
        if (title.isNotEmpty) 2.height,
        if (value != null && isCopyable && text?.isNotEmpty == true)
          _CopyableValue(
            text: text!,
            isStart: isCrossAxisAlignmentStart,
            child: value,
          )
        else if (value != null)
          value,
        if (imagePreviewUrls?.isNotEmpty ?? false) ...[
          _Thumbnails(urls: imagePreviewUrls!, size: imageSize, title: title),
        ],
      ],
    );

    final parts = <Widget>[
      if (iconData != null) ...[chip, 10.width],
      Flexible(child: labels),
    ];
    if (imagePreviewUrls != null && (imagePreviewUrls?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: isFirstItem ? 0 : 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isCrossAxisAlignmentStart
              ? parts
              : parts.reversed.toList(growable: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foreground = ShadTextColors.foreground(context);
    final titleStyle = TextStyle(
      fontSize: titleFontSize ?? 12,
      fontWeight: FontWeight.w400,
      // height: 20 / 14,
      height: 0,
      letterSpacing: 0,
      color: colorTitle ?? foreground,
    );

    final valueStyle = TextStyle(
      fontSize: textFontSize ?? 14,
      fontWeight: FontWeight.w500,
      // height: 14 / 14,
      height: 0,
      letterSpacing: 0,
      color: color ?? foreground,
    );

    final blockquoteStyle = TextStyle(
      fontSize: textFontSize ?? 15,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      // height: 24 / 16,
      height: 0,
      letterSpacing: 0,
      color: color ?? foreground,
    );

    // if ((iconData != null )) {
    return _accentLayout(context, titleStyle, valueStyle, blockquoteStyle);
    // }
    // // if (isColumn) {
    // return Column(
    //   crossAxisAlignment: isCrossAxisAlignmentStart
    //       ? CrossAxisAlignment.start
    //       : CrossAxisAlignment.end,
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     if (title.isNotEmpty && !isFirstItem) 8.height,
    //     if (title.isNotEmpty) Text(title, style: titleStyle),
    //     Container(
    //       decoration: colorBGHighlight != null
    //           ? BoxDecoration(
    //               color: colorBGHighlight,
    //               borderRadius: BorderRadius.circular(4),
    //             )
    //           : null,
    //       child: Padding(
    //         padding: colorBGHighlight != null
    //             ? const EdgeInsets.fromLTRB(3, 0, 3, 0)
    //             : EdgeInsets.zero,
    //         child: Row(
    //           mainAxisSize: MainAxisSize.min,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             if (icon != null) icon!,
    //             if (icon != null) 6.width,
    //             Flexible(
    //               child: Text(
    //                 text ?? "",
    //                 style: isBlockquote ? blockquoteStyle : valueStyle,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ],
    // );
    // } else {
    //   return Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     children: [
    //       Text("$title: ", style: TextStyle(color: foreground)),
    //       Container(
    //         decoration: colorBGHighlight != null
    //             ? BoxDecoration(
    //                 color: colorBGHighlight,
    //                 borderRadius: BorderRadius.circular(4),
    //               )
    //             : null,
    //         child: Padding(
    //           padding: colorBGHighlight != null
    //               ? const EdgeInsets.fromLTRB(3, 0, 3, 0)
    //               : EdgeInsets.zero,
    //           child: Row(
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               if (icon != null) icon!,
    //               if (icon != null) 6.width,
    //               Text(text ?? "", style: TextStyle(color: foreground)),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   );
    // }
  }
}

/// [accent] lightened (dark mode) or darkened (light mode) just enough to
/// reach the WCAG 3:1 contrast icons need on [background]; an accent that
/// already reads is returned unchanged.
Color _readableOn(Color accent, Color background, bool isDark) {
  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  final target = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  var color = accent;
  for (var t = 0.1; contrast(color, background) < 3 && t <= 1; t += 0.1) {
    color = Color.lerp(accent, target, t)!;
  }
  return color;
}
