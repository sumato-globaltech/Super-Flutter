import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class DesignCard extends StatelessWidget {
  const DesignCard({
    super.key,
    this.title,
    this.child,
    this.actions,
    this.onTap,
    this.borderRadius,
    this.paddingChild,
    this.children = const [],
  });
  final String? title;
  final Widget? child;
  final List<Widget> children;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? paddingChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusSm),
      child: Ink(
        decoration: BoxDecoration(
          color: colors.cardWrapper,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 2.0,
                    left: 12.0,
                    right: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        title ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: .w500,
                          fontSize: 15,
                        ),
                      ),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
              if (children.isNotEmpty)
                for (int i = 0; i < children.length; i++)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.spaceXs,
                      i == 0 ? AppSizes.spaceXs : 0,
                      AppSizes.spaceXs,
                      AppSizes.spaceSm,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: colors.cardContent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(color: colors.cardRing),
                        boxShadow: AppShadows.sm,
                      ),
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        child: Padding(
                          padding:
                              paddingChild ??
                              const EdgeInsets.all(AppSizes.spaceMd),
                          child: children[i],
                        ),
                      ),
                    ),
                  )
              else
                Padding(
                  padding: const EdgeInsets.all(AppSizes.spaceXs),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: colors.cardContent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(color: colors.cardRing),
                      boxShadow: AppShadows.sm,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      child: Padding(
                        padding:
                            paddingChild ??
                            const EdgeInsets.all(AppSizes.spaceMd),
                        child:
                            child ??
                            const Text(
                              'Add Your Own Widget As per your requirement',
                              style: TextStyle(fontSize: 16),
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
