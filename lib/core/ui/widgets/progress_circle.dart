import 'package:material_ui/material_ui.dart';

class DesignProgressAnimation extends StatefulWidget {
  const DesignProgressAnimation({
    Key? key,
    this.color,
    this.size,
    this.value = 0.0,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  final Color? color;
  final double? size;
  final double value;
  final Duration duration;

  @override
  State<DesignProgressAnimation> createState() =>
      _DesignProgressAnimationState();
}

class _DesignProgressAnimationState extends State<DesignProgressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.value,
      upperBound: 1.0,
      lowerBound: 0.0,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(covariant DesignProgressAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.animateTo(
        widget.value,
        duration: widget.duration,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size ?? 20,
      width: widget.size ?? 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CircularProgressIndicator(
          strokeWidth: 1.5,
          color: widget.color,
          value: _controller.value,
        ),
      ),
    );
  }
}


class DesignProgress extends StatelessWidget {
  const DesignProgress({
    Key? key,
    this.color,
    this.size,
    this.value,
  }) : super(key: key);

  final Color? color;
  final double? size;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 20,
      width: size ?? 20,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: color,
        value: value,
      ),
    );
  }
}
