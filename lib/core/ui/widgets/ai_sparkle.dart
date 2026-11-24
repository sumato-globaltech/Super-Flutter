import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// The AI mark: a sparkle on a gradient, moving when [animate] is set.
class AiSparkle extends StatefulWidget {
  const AiSparkle({this.size = 32, this.animate = false, super.key});

  final double size;
  final bool animate;

  @override
  State<AiSparkle> createState() => _AiSparkleState();
}

class _AiSparkleState extends State<AiSparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AiSparkle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final move = widget.animate && !MediaQuery.disableAnimationsOf(context);
    if (move && !_controller.isAnimating) _controller.repeat();
    if (!move) _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, icon) => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_controller.value * 6.2832),
              colors: const [
                Color(0xFF0A84FF),
                Color(0xFF0072FF),
                Color(0xFF7F00FF),
              ],
            ),
          ),
          child: icon,
        ),
        child: SizedBox.square(
          dimension: widget.size,
          child: Icon(
            PhosphorIconsFill.sparkle,
            size: widget.size * 0.55,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
