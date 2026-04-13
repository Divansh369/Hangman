import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../hangman_game.dart';
import '../../services/sfx_service.dart';

class UnlockOverlay extends StatefulWidget {
  final HangmanGame game;
  const UnlockOverlay({super.key, required this.game});

  @override
  State<UnlockOverlay> createState() => _UnlockOverlayState();
}

class _UnlockOverlayState extends State<UnlockOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  String? _id;

  @override
  void initState() {
    super.initState();
    _id = widget.game.unlockedNotifier.value;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 40),
    ]).animate(_controller);

    _controller.forward();
    SfxService().playUnlock();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) {
            return;
          }
          widget.game.unlockedNotifier.value = null;
          widget.game.overlays.remove('Unlock');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = _id ?? widget.game.unlockedNotifier.value;
    if (id == null) {
      return const SizedBox.shrink();
    }

    final asset = 'assets/svgs/$id.svg';

    return Center(
      child: Stack(alignment: Alignment.center, children: [
        const Positioned.fill(child: _Confetti(count: 28, duration: Duration(milliseconds: 1100))),
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 12)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Collectible Unlocked!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(height: 140, child: SvgPicture.asset(asset)),
              const SizedBox(height: 12),
              Text(id, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Confetti extends StatefulWidget {
  final int count;
  final Duration duration;
  const _Confetti({this.count = 28, this.duration = const Duration(milliseconds: 1100)});

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  late final List<_Particle> _particles;
  final Random _rnd = Random();

  static const List<Color> _palette = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _particles = List.generate(widget.count, (_) => _createParticle());
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        // keep the animation alive briefly then remove by letting parent close overlay
      }
    });
  }

  _Particle _createParticle() {
    final angle = (_rnd.nextDouble() * pi) - (pi / 2); // spread roughly up
    final speed = 0.6 + _rnd.nextDouble() * 1.2; // 0.6-1.8
    final vx = cos(angle) * speed;
    final vy = sin(angle) * speed * -1; // negative to arc upward initially
    final size = 6 + _rnd.nextDouble() * 10;
    final rotation = _rnd.nextDouble() * 2 * pi;
    final rotationSpeed = (_rnd.nextDouble() - 0.5) * 6; // -3..3
    final color = _palette[_rnd.nextInt(_palette.length)];
    return _Particle(vx: vx, vy: vy, size: size, rotation: rotation, rotationSpeed: rotationSpeed, color: color);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) => CustomPaint(painter: _ConfettiPainter(_particles, _anim.value)),
        ),
      ),
    );
  }
}

class _Particle {
  final double vx;
  final double vy;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;

  _Particle({required this.vx, required this.vy, required this.size, required this.rotation, required this.rotationSpeed, required this.color});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress; // 0..1

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 30);
    for (final p in particles) {
      final t = progress;
      final dx = center.dx + p.vx * t * size.width * 0.45;
      final dy = center.dy + (p.vy * t * size.height * 0.6) + 1.2 * t * t * size.height * 0.5;
      canvas.save();
      canvas.translate(dx, dy);
      final angle = p.rotation + p.rotationSpeed * t * 4.0;
      canvas.rotate(angle);
      final rect = Rect.fromCenter(center: Offset(0, 0), width: p.size, height: p.size * 0.6);
      final alpha = ((1 - t).clamp(0.0, 1.0) * 255).round();
      final paint = Paint()..color = p.color.withAlpha(alpha);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
