import 'package:material_ui/material_ui.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    required this.height,
    required this.width,
    this.baseColor,
    this.highlightColor,
    this.radius,
    super.key,
  });

  final double height;
  final double width;
  final double? radius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      width: width,
      child: Shimmer.fromColors(
        baseColor: baseColor ?? theme.appColors.cardRing,
        highlightColor: highlightColor ?? theme.appColors.cardContent,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.all(Radius.circular(radius ?? 6)),
          ),
        ),
      ),
    );
  }
}
