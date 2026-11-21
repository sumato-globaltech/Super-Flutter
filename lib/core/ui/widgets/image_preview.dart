import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';

import '../theme/app_colors.dart';
import 'progress_circle.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    this.imageUrl,
    this.file,
    this.title,
    this.heroTag,
  }) : assert(
         imageUrl != null || file != null,
         'ImagePreview needs an imageUrl or a file',
       );

  final String? imageUrl;
  final File? file;
  final String? title;
  final Object? heroTag;

  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    File? file,
    String? title,
    Object? heroTag,
  }) {
    if ((imageUrl == null || imageUrl.isEmpty) && file == null) {
      return Future.value();
    }
    return Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) => ImagePreview(
          imageUrl: imageUrl,
          file: file,
          title: title,
          heroTag: heroTag,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview>
    with SingleTickerProviderStateMixin {
  final _transformationController = TransformationController();
  late final AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;
  Offset _doubleTapPosition = Offset.zero;

  static const double _doubleTapScale = 2.5;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          final value = _zoomAnimation?.value;
          if (value != null) _transformationController.value = value;
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _onDoubleTap() {
    final isZoomedIn =
        _transformationController.value.getMaxScaleOnAxis() > 1.01;
    final end = isZoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -_doubleTapPosition.dx * (_doubleTapScale - 1),
              -_doubleTapPosition.dy * (_doubleTapScale - 1),
              0,
              1,
            )
            ..scaleByDouble(
              _doubleTapScale,
              _doubleTapScale,
              _doubleTapScale,
              1,
            ));

    _zoomAnimation =
        Matrix4Tween(begin: _transformationController.value, end: end).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;

    Widget image = widget.file != null
        ? Image.file(
            widget.file!,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _ErrorState(),
          )
        : CachedNetworkImage(
            imageUrl: widget.imageUrl!,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(child: DesignProgress()),
            errorWidget: (_, _, _) => _ErrorState(),
          );

    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: _onDoubleTapDown,
              onDoubleTap: _onDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1,
                maxScale: 5,
                child: Center(child: image),
              ),
            ),
          ),
          if (widget.title?.isNotEmpty == true)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: appColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: appColors.cardWrapper,
                  shape: CircleBorder(
                    side: BorderSide(color: appColors.cardRing),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        PhosphorIconsBold.x,
                        size: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular.imageBroken,
            size: 40,
            color: theme.appColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).imageUnavailable,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
