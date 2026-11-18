import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/ui/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppGradients.backgroundDark
            : AppGradients.background,
      ),
      child: child,
    );
  }
}
