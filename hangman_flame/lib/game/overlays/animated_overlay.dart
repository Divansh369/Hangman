import 'package:flutter/material.dart';

class AnimatedOverlay extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;

  const AnimatedOverlay({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 360),
    this.curve = Curves.easeOut,
    this.beginOffset = const Offset(0, 0.06),
  });

  @override
  State<AnimatedOverlay> createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<AnimatedOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(_fade);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
