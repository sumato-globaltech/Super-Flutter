import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_spacing.dart';

class AppBottomBarItem {
  const AppBottomBarItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount,
    this.showDot = false,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badgeCount;
  final bool showDot;
}

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 64,
    this.iconSize = AppDimensions.iconMd,
    this.showElevation = true,
    this.shape = const CircularNotchedRectangle(),
    this.duration = const Duration(milliseconds: 270),
    this.curve = Curves.easeOutCubic,
    super.key,
  }) : assert(
         items.length >= 2 && items.length <= 5,
         'A bottom bar takes 2 to 5 destinations.',
       ),
       assert(selectedIndex >= 0 && selectedIndex < items.length);

  final List<AppBottomBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;
  final double iconSize;
  final bool showElevation;
  final NotchedShape? shape;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final navTheme = theme.bottomNavigationBarTheme;
    final selectedColor = navTheme.selectedItemColor ?? colors.primary;
    final unselectedColor =
        navTheme.unselectedItemColor ?? theme.appColors.textSecondary;
    final labelBase = theme.textTheme.labelSmall ?? const TextStyle();

    return BottomAppBar(
      shape: shape,
      color: navTheme.backgroundColor ?? colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: showElevation ? null : 0,
      shadowColor: theme.appColors.cardShadow,
      height: height,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: Builder(
                builder: (context) {
                  final item = items[index];
                  final selected = index == selectedIndex;
                  final color = selected ? selectedColor : unselectedColor;
                  final labelStyle =
                      (selected
                          ? navTheme.selectedLabelStyle
                          : navTheme.unselectedLabelStyle) ??
                      labelBase;
                  final count = item.badgeCount ?? 0;

                  return Semantics(
                    container: true,
                    button: true,
                    selected: selected,
                    child: InkWell(
                      onTap: () => onSelected(index),
                      borderRadius: AppDimensions.borderRadiusSm,
                      splashColor: selectedColor.withValues(alpha: 0.08),
                      highlightColor: selectedColor.withValues(alpha: 0.04),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: selected ? 1.12 : 1,
                            duration: duration,
                            curve: curve,
                            child: Badge(
                              isLabelVisible: count > 0 || item.showDot,
                              label: count > 0
                                  ? Text(count > 99 ? '99+' : '$count')
                                  : null,
                              backgroundColor: colors.error,
                              textColor: colors.onError,
                              child: Icon(
                                selected
                                    ? item.activeIcon ?? item.icon
                                    : item.icon,
                                size: iconSize,
                                color: color,
                              ),
                            ),
                          ),
                          Gap.xxs,
                          MediaQuery.withClampedTextScaling(
                            maxScaleFactor: 1.3,
                            child: AnimatedDefaultTextStyle(
                              duration: duration,
                              curve: curve,
                              style: labelStyle.copyWith(
                                color: color,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
