import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    super.key,
  }) : assert(
         title == null || titleWidget == null,
         'Give title or titleWidget, not both.',
       );

  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  bool get _twoLines => subtitle?.isNotEmpty ?? false;

  @override
  Size get preferredSize => Size.fromHeight(
    (_twoLines ? kToolbarHeight + 8 : kToolbarHeight) +
        (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? _title(context, title, subtitle, centerTitle),
      leading: leading,
      actions: actions == null ? null : [...actions!, const SizedBox(width: 4)],
      bottom: bottom,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      toolbarHeight: _twoLines ? kToolbarHeight + 8 : kToolbarHeight,
    );
  }
}

class AppSliverTopBar extends StatelessWidget {
  const AppSliverTopBar({
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.floating = true,
    this.pinned = false,
    this.snap = true,
    this.backgroundColor,
    super.key,
  }) : assert(
         title == null || titleWidget == null,
         'Give title or titleWidget, not both.',
       ),
       assert(!snap || floating, 'snap needs floating.');

  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final bool floating;
  final bool pinned;
  final bool snap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final twoLines = subtitle?.isNotEmpty ?? false;
    return SliverAppBar(
      title: titleWidget ?? _title(context, title, subtitle, centerTitle),
      leading: leading,
      actions: actions == null ? null : [...actions!, const SizedBox(width: 4)],
      bottom: bottom,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      floating: floating,
      pinned: pinned,
      snap: snap,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: twoLines ? kToolbarHeight + 8 : kToolbarHeight,
    );
  }
}

Widget? _title(
  BuildContext context,
  String? title,
  String? subtitle,
  bool? centerTitle,
) {
  if (title == null) return null;
  final theme = Theme.of(context);
  final titleText = Text(title, maxLines: 1, overflow: TextOverflow.ellipsis);
  if (subtitle == null || subtitle.isEmpty) return titleText;

  final center = centerTitle ?? theme.appBarTheme.centerTitle ?? false;
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start,
    children: [
      titleText,
      Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.appColors.textSecondary,
        ),
      ),
    ],
  );
}
