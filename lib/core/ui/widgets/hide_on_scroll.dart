import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Hides the [HideOnScrollButton] below it while the page scrolls down, and
/// shows it again on the way up.
class HideOnScroll extends StatefulWidget {
  const HideOnScroll({required this.child, super.key});

  final Widget child;

  @override
  State<HideOnScroll> createState() => _HideOnScrollState();
}

class _HideOnScrollState extends State<HideOnScroll> {
  final _visible = ValueNotifier(true);

  @override
  void dispose() {
    _visible.dispose();
    super.dispose();
  }

  bool _onScroll(UserScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;
    switch (notification.direction) {
      case ScrollDirection.forward:
        _visible.value = true;
      case ScrollDirection.reverse:
        // A page too short to scroll keeps its button.
        if (metrics.maxScrollExtent > 0) _visible.value = false;
      case ScrollDirection.idle:
        if (metrics.pixels <= metrics.minScrollExtent) _visible.value = true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return _Visibility(
      notifier: _visible,
      child: NotificationListener<UserScrollNotification>(
        onNotification: _onScroll,
        child: widget.child,
      ),
    );
  }
}

class _Visibility extends InheritedNotifier<ValueNotifier<bool>> {
  const _Visibility({required super.notifier, required super.child});
}

class HideOnScrollButton extends StatelessWidget {
  const HideOnScrollButton({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final visible =
        context
            .dependOnInheritedWidgetOfExactType<_Visibility>()
            ?.notifier
            ?.value ??
        true;
    const duration = Duration(milliseconds: 220);
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 1.6),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: duration,
            child: child,
          ),
        ),
      ),
    );
  }
}
