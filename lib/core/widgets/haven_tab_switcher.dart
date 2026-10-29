import 'package:flutter/material.dart';

/// A tab switcher inspired by native iOS navigation that provides a smooth,
/// restrained transition between primary destinations while preserving full
/// widget state, scroll positions, focus, and form drafts.
class HavenTabSwitcher extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const HavenTabSwitcher({
    super.key,
    required this.currentIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeInOutCubic,
  });

  @override
  State<HavenTabSwitcher> createState() => _HavenTabSwitcherState();
}

class _HavenTabSwitcherState extends State<HavenTabSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _currentIndex;
  late int _previousIndex;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
            _previousIndex = _currentIndex;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(HavenTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      final disableAnimations =
          MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      final oldIndex = _currentIndex;
      final newIndex = widget.currentIndex;

      if (disableAnimations) {
        setState(() {
          _previousIndex = newIndex;
          _currentIndex = newIndex;
          _isAnimating = false;
          _controller.value = 1.0;
        });
      } else {
        setState(() {
          _previousIndex = oldIndex;
          _currentIndex = newIndex;
          _isAnimating = true;
        });
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // When animations are disabled (reduced-motion preference) or static,
    // render all children in Stack using Offstage so state is 100% retained.
    if (disableAnimations || !_isAnimating) {
      return Stack(
        fit: StackFit.expand,
        children: List.generate(widget.children.length, (index) {
          final isCurrent = index == _currentIndex;
          return Offstage(
            offstage: !isCurrent,
            child: TickerMode(
              enabled: isCurrent,
              child: widget.children[index],
            ),
          );
        }),
      );
    }

    final bool isForward = _currentIndex > _previousIndex;
    // Restrained horizontal slide: ~3.5% screen offset (subtle, native-feeling)
    const double slideFraction = 0.035;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        final inSlide = isForward ? slideFraction : -slideFraction;
        final outSlide = isForward ? -slideFraction : slideFraction;

        return Stack(
          fit: StackFit.expand,
          children: List.generate(widget.children.length, (index) {
            final isCurrent = index == _currentIndex;
            final isPrevious = index == _previousIndex;

            if (!isCurrent && !isPrevious) {
              return Offstage(
                offstage: true,
                child: TickerMode(
                  enabled: false,
                  child: widget.children[index],
                ),
              );
            }

            if (isCurrent) {
              // Incoming page: subtle slide towards center + restrained fade in
              final offset = Offset(inSlide * (1.0 - t), 0.0);
              final opacity = t.clamp(0.0, 1.0);

              return FractionalTranslation(
                translation: offset,
                child: Opacity(
                  opacity: opacity,
                  child: TickerMode(
                    enabled: true,
                    child: widget.children[index],
                  ),
                ),
              );
            }

            // Outgoing page: subtle slide away from center + restrained fade out
            final offset = Offset(outSlide * t, 0.0);
            final opacity = (1.0 - t).clamp(0.0, 1.0);

            return IgnorePointer(
              ignoring: true,
              child: FractionalTranslation(
                translation: offset,
                child: Opacity(
                  opacity: opacity,
                  child: TickerMode(
                    enabled: true,
                    child: widget.children[index],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
