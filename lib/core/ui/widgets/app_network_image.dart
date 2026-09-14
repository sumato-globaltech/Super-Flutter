import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppDimensions.borderRadiusSm,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: url.trim().isEmpty
            ? _Placeholder(icon: fallbackIcon, color: colors.skeleton)
            : Image.network(
                url,
                width: width,
                height: height,
                fit: fit,
                cacheWidth: width == null
                    ? null
                    : (width! * MediaQuery.devicePixelRatioOf(context)).round(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: colors.skeleton,
                    child: const SizedBox.expand(),
                  );
                },
                errorBuilder: (context, _, _) =>
                    _Placeholder(icon: fallbackIcon, color: colors.skeleton),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Icon(
          icon,
          size: AppDimensions.iconMd,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
