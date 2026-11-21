import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_spacing.dart';
import 'app_confirm_sheet.dart';
import 'app_network_image.dart';

class TitleDetailsCard extends StatelessWidget {
  const TitleDetailsCard({
    required this.title,
    this.text,
    this.child,
    this.icon,
    this.accentColor,
    this.onTap,
    this.isLoading = false,
    this.alignEnd = false,
    this.isBlockquote = false,
    this.isCopyable = false,
    this.readMoreLines,
    this.imageUrls,
    this.onImageTap,
    this.imageSize = 44,
    super.key,
  }) : assert(text == null || child == null, 'Give text or child, not both.');

  final String title;
  final String? text;
  final Widget? child;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool alignEnd;
  final bool isBlockquote;
  final bool isCopyable;
  final int? readMoreLines;
  final List<String>? imageUrls;
  final ValueChanged<int>? onImageTap;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appColors = theme.appColors;
    final isDark = theme.brightness == Brightness.dark;
    final accent = accentColor ?? colors.primary;
    final cross = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;

    final titleStyle = theme.textTheme.bodySmall?.copyWith(
      color: appColors.textSecondary,
      letterSpacing: 0.2,
    );
    final base = theme.textTheme.bodyMedium ?? const TextStyle();
    final valueStyle = isBlockquote
        ? base.copyWith(fontStyle: FontStyle.italic, color: colors.onSurface)
        : base.copyWith(fontWeight: FontWeight.w600, color: colors.onSurface);

    final value = text;
    final Widget? body = isLoading
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Container(
              width: 72,
              height: AppSpacing.md,
              decoration: BoxDecoration(
                color: colors.skeleton,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppDimensions.radiusXs),
                ),
              ),
            ),
          )
        : value != null
        ? readMoreLines != null && value.isNotEmpty
              ? _ReadMoreText(
                  title: title,
                  text: value,
                  style: valueStyle,
                  textAlign: textAlign,
                  maxLines: readMoreLines!,
                  icon: icon,
                )
              : Text(value, style: valueStyle, textAlign: textAlign)
        : child;

    final urls = imageUrls ?? const <String>[];
    final labels = Column(
      crossAxisAlignment: cross,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: alignEnd ? TextDirection.rtl : null,
            children: [
              Flexible(child: Text(title, style: titleStyle)),
              if (onTap != null) ...[
                Gap.xs,
                Icon(
                  PhosphorIconsBold.link,
                  size: AppDimensions.iconXs - 2,
                  color: appColors.accent,
                ),
              ],
            ],
          ),
        if (title.isNotEmpty && body != null) Gap.xxs,
        if (body != null)
          isCopyable && !isLoading && (value?.isNotEmpty ?? false)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: alignEnd ? TextDirection.rtl : null,
                  children: [
                    Flexible(child: body),
                    Gap.xs,
                    _CopyButton(text: value!),
                  ],
                )
              : body,
        if (urls.isNotEmpty) ...[
          Gap.sm,
          SizedBox(
            height: imageSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              reverse: alignEnd,
              itemCount: urls.length,
              separatorBuilder: (_, _) => Gap.sm,
              itemBuilder: (context, index) => InkWell(
                borderRadius: AppDimensions.borderRadiusSm,
                onTap: onImageTap == null ? null : () => onImageTap!(index),
                child: AppNetworkImage(
                  url: urls[index],
                  width: imageSize,
                  height: imageSize,
                  fallbackIcon: PhosphorIconsRegular.imageBroken,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      textDirection: alignEnd ? TextDirection.rtl : null,
      children: [
        if (icon != null) ...[
          Container(
            width: AppDimensions.avatarSm,
            height: AppDimensions.avatarSm,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSpacing.sm + 1),
              ),
            ),
            child: Icon(icon, size: AppDimensions.iconXs + 2, color: accent),
          ),
          Gap.md,
        ],
        Flexible(child: labels),
      ],
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.borderRadiusSm,
      child: content,
    );
  }
}

class _ReadMoreText extends StatefulWidget {
  const _ReadMoreText({
    required this.title,
    required this.text,
    required this.style,
    required this.textAlign,
    required this.maxLines,
    this.icon,
  });

  final String title;
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int maxLines;
  final IconData? icon;

  @override
  State<_ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<_ReadMoreText> {
  late final TapGestureRecognizer _recognizer = TapGestureRecognizer()
    ..onTap = _openFullText;

  static const _ellipsis = '… ';

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _openFullText() {
    AppConfirmSheet.show<void>(
      context,
      AppConfirmSheet<void>(
        title: widget.title,
        icon: widget.icon ?? PhosphorIconsRegular.textAlignLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.5,
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              widget.text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final linkStyle = widget.style.copyWith(
      color: theme.appColors.accent,
      fontWeight: FontWeight.w600,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final full = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: direction,
          textAlign: widget.textAlign,
          textScaler: scaler,
          maxLines: widget.maxLines,
        )..layout(maxWidth: constraints.maxWidth);

        if (!full.didExceedMaxLines) {
          full.dispose();
          return Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
          );
        }

        final link = TextPainter(
          text: TextSpan(text: '$_ellipsis${l10n.readMore}', style: linkStyle),
          textDirection: direction,
          textScaler: scaler,
          maxLines: 1,
        )..layout();
        final cut = full.getPositionForOffset(
          Offset(
            full.width - link.width,
            full.height - full.preferredLineHeight / 2,
          ),
        );
        final end = (full.getOffsetBefore(cut.offset) ?? cut.offset).clamp(
          0,
          widget.text.length,
        );
        full.dispose();
        link.dispose();

        return Semantics(
          button: true,
          onTapHint: l10n.readMore,
          child: Text.rich(
            TextSpan(
              style: widget.style,
              children: [
                TextSpan(
                  text:
                      '${widget.text.substring(0, end).trimRight()}$_ellipsis',
                ),
                TextSpan(
                  text: l10n.readMore,
                  style: linkStyle,
                  recognizer: _recognizer,
                ),
              ],
            ),
            textAlign: widget.textAlign,
            maxLines: widget.maxLines,
          ),
        );
      },
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.text});

  final String text;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appColors = Theme.of(context).appColors;

    return IconButton(
      onPressed: _copy,
      tooltip: _copied ? l10n.copied : l10n.copy,
      visualDensity: VisualDensity.compact,
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      constraints: const BoxConstraints(
        minWidth: AppSpacing.xl,
        minHeight: AppSpacing.xl - AppSpacing.xs,
      ),
      padding: EdgeInsets.zero,
      iconSize: AppDimensions.iconXs,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          _copied ? PhosphorIconsBold.check : PhosphorIconsRegular.copy,
          key: ValueKey(_copied),
          color: _copied ? appColors.success : appColors.textSecondary,
        ),
      ),
    );
  }
}
