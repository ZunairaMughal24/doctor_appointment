import 'dart:async';
import 'package:flutter/material.dart';

/// Reusable animation wrappers. UI files compose these instead of managing
/// their own AnimationControllers — keeping illustration/page code clean.
///
/// Usage:
///   FloatingWidget(child: myWidget)            // gentle continuous bob
///   PulseWidget(child: myBadge)                // subtle scale pulse
///   FadeSlideIn(delay: ..., child: myText)     // one-shot entrance

// ── Continuous vertical float (bob) ───────────────────────────────────────────

class FloatingWidget extends StatefulWidget {
  final Widget child;

  /// Total vertical travel in logical pixels.
  final double distance;
  final Duration duration;

  /// Stagger start so multiple floats don't move in unison.
  final Duration delay;

  const FloatingWidget({
    super.key,
    required this.child,
    this.distance = 12,
    this.duration = const Duration(milliseconds: 2200),
    this.delay = Duration.zero,
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: -widget.distance / 2,
      end: widget.distance / 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.delay == Duration.zero) {
      _controller.repeat(reverse: true);
    } else {
      _startTimer = Timer(widget.delay, () {
        if (mounted) _controller.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _animation.value), child: child),
      child: widget.child,
    );
  }
}

// ── Continuous scale pulse ────────────────────────────────────────────────────

class PulseWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;
  final Duration delay;

  const PulseWidget({
    super.key,
    required this.child,
    this.minScale = 0.94,
    this.maxScale = 1.06,
    this.duration = const Duration(milliseconds: 1400),
    this.delay = Duration.zero,
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: widget.minScale, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.delay == Duration.zero) {
      _controller.repeat(reverse: true);
    } else {
      _startTimer = Timer(widget.delay, () {
        if (mounted) _controller.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

// ── One-shot entrance: fade + slide up ────────────────────────────────────────

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  /// Vertical start offset as a fraction of the child's height.
  final double slideFrom;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 550),
    this.delay = Duration.zero,
    this.slideFrom = 0.25,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideFrom),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _startTimer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Expanding rings (radar / heartbeat pulse) ─────────────────────────────────

/// Concentric rings that continuously expand outward from [child] and fade
/// as they grow — a radar-ping / heartbeat-pulse effect. Rings are staggered
/// evenly across one animation cycle so there's always one mid-expansion.
class PulseRings extends StatefulWidget {
  final Widget child;
  final Color color;
  final double maxSize;
  final int ringCount;
  final Duration duration;

  const PulseRings({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.maxSize = 160,
    this.ringCount = 3,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<PulseRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < widget.ringCount; i++) _ring(i),
          child!,
        ],
      ),
      child: widget.child,
    );
  }

  Widget _ring(int index) {
    final progress = (_controller.value + index / widget.ringCount) % 1.0;
    return Container(
      width: widget.maxSize * progress,
      height: widget.maxSize * progress,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.color.withValues(alpha: (1 - progress) * 0.5),
          width: 1.5,
        ),
      ),
    );
  }
}
