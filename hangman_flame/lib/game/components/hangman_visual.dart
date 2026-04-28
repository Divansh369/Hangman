import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../hangman_game.dart';

/// Floating ambient particles rendered in the Flame game background
class AmbientParticles extends PositionComponent with HasGameReference<HangmanGame> {
  final List<_FloatingParticle> _particles = [];
  final math.Random _rng = math.Random();
  double _elapsed = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (int i = 0; i < 35; i++) {
      _particles.add(_FloatingParticle(
        x: _rng.nextDouble() * 2000,
        y: _rng.nextDouble() * 2000,
        radius: 1.5 + _rng.nextDouble() * 3.5,
        speedX: (_rng.nextDouble() - 0.5) * 0.4,
        speedY: -0.15 - _rng.nextDouble() * 0.35,
        opacity: 0.08 + _rng.nextDouble() * 0.18,
        phase: _rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    for (final p in _particles) {
      p.x += p.speedX * 60 * dt;
      p.y += p.speedY * 60 * dt;
      // gentle sine wave drift
      p.x += math.sin(_elapsed * 0.5 + p.phase) * 0.15;
      // wrap around
      if (p.y < -20) p.y = game.size.y + 20;
      if (p.x < -20) p.x = game.size.x + 20;
      if (p.x > game.size.x + 20) p.x = -20;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final p in _particles) {
      final alpha = (p.opacity * 255).round().clamp(0, 255);
      final glow = (p.opacity * 0.3 * 255).round().clamp(0, 255);
      // Outer glow
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * 3,
        Paint()..color = Color.fromARGB(glow, 150, 150, 255)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Core
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius,
        Paint()..color = Color.fromARGB(alpha, 200, 200, 255),
      );
    }
  }
}

class _FloatingParticle {
  double x, y, radius, speedX, speedY, opacity, phase;
  _FloatingParticle({required this.x, required this.y, required this.radius, required this.speedX, required this.speedY, required this.opacity, required this.phase});
}

class HangmanVisual extends PositionComponent with HasGameReference<HangmanGame> {
  double _animProgress = 0.0;
  int _lastWrongGuesses = 0;
  double _breathe = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _breathe += dt;
    final currentWrong = game.wrongGuesses;
    if (currentWrong > _lastWrongGuesses) {
      _animProgress = 0.0;
      _lastWrongGuesses = currentWrong;
    }
    if (_animProgress < 1.0) {
      _animProgress = (_animProgress + dt * 3.0).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final wrongGuesses = game.wrongGuesses;
    final isGameOver = game.isGameOver;
    final didWin = game.didWin;

    // Breathing offset for idle animation
    final breatheOffset = math.sin(_breathe * 1.8) * 1.5;

    // Gallows paint - thicker with rounded caps
    final gallowsPaint = Paint()
      ..color = const Color(0xFF4A5568)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Person paint
    final personPaint = Paint()
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (isGameOver && didWin) {
      personPaint.color = const Color(0xFF4ADE80);
    } else if (isGameOver && !didWin) {
      personPaint.color = const Color(0xFFF87171);
    } else {
      personPaint.color = const Color(0xFF94A3B8);
    }

    // Gallows structure with subtle shadow
    final shadowPaint = Paint()
      ..color = const Color(0x15000000)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Shadow
    canvas.drawLine(const Offset(22, 232), const Offset(182, 232), shadowPaint);
    canvas.drawLine(const Offset(52, 232), const Offset(52, 22), shadowPaint);

    // Base
    canvas.drawLine(const Offset(20, 230), const Offset(180, 230), gallowsPaint);
    // Support brace
    canvas.drawLine(const Offset(20, 228), const Offset(70, 228), gallowsPaint..strokeWidth = 3);
    // Vertical Pole
    canvas.drawLine(const Offset(50, 230), const Offset(50, 20), gallowsPaint..strokeWidth = 4);
    // Horizontal Pole
    canvas.drawLine(const Offset(50, 20), const Offset(130, 20), gallowsPaint);
    // Small diagonal brace
    canvas.drawLine(const Offset(50, 45), const Offset(75, 20), gallowsPaint..strokeWidth = 2.5);
    // Rope with slight curve
    final ropePath = Path()
      ..moveTo(130, 20)
      ..quadraticBezierTo(130 + breatheOffset * 0.3, 35, 130, 50);
    canvas.drawPath(ropePath, gallowsPaint..strokeWidth = 2.5);

    gallowsPaint.strokeWidth = 4;

    // Animated body parts
    double partAlpha(int partIndex) {
      if (wrongGuesses > partIndex + 1) return 1.0;
      if (wrongGuesses == partIndex + 1) return _animProgress;
      return 0.0;
    }

    // Head
    if (wrongGuesses >= 1) {
      final alpha = partAlpha(0);
      final headPaint = Paint()
        ..color = personPaint.color.withValues(alpha: alpha)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;

      // Head glow on death
      if (isGameOver && !didWin) {
        canvas.drawCircle(
          Offset(130, 75 + breatheOffset * 0.5),
          28,
          Paint()..color = const Color(0xFFF87171).withValues(alpha: 0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
      }

      final headCenter = Offset(130, 75 + breatheOffset * 0.5);
      canvas.drawCircle(headCenter, 25, headPaint);

      if (isGameOver && !didWin && alpha >= 1.0) {
        // X eyes
        final eyePaint = Paint()..color = const Color(0xFFF87171).withValues(alpha: alpha)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(119, 65 + breatheOffset * 0.5), Offset(125, 71 + breatheOffset * 0.5), eyePaint);
        canvas.drawLine(Offset(125, 65 + breatheOffset * 0.5), Offset(119, 71 + breatheOffset * 0.5), eyePaint);
        canvas.drawLine(Offset(135, 65 + breatheOffset * 0.5), Offset(141, 71 + breatheOffset * 0.5), eyePaint);
        canvas.drawLine(Offset(141, 65 + breatheOffset * 0.5), Offset(135, 71 + breatheOffset * 0.5), eyePaint);
        // Sad mouth
        canvas.drawArc(Rect.fromLTWH(120, 80 + breatheOffset * 0.5, 20, 10), 3.14, 3.14, false, eyePaint..strokeWidth = 2);
      } else if (isGameOver && didWin && alpha >= 1.0) {
        // Happy eyes
        final winPaint = Paint()..color = const Color(0xFF4ADE80).withValues(alpha: alpha)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
        canvas.drawCircle(Offset(122, 70 + breatheOffset * 0.5), 2.5, winPaint..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(138, 70 + breatheOffset * 0.5), 2.5, winPaint);
        // Big smile
        canvas.drawArc(Rect.fromLTWH(118, 73 + breatheOffset * 0.5, 24, 14), 0, 3.14, false, winPaint..style = PaintingStyle.stroke..strokeWidth = 2);
      } else if (!isGameOver && alpha >= 1.0) {
        // Neutral eyes — dots
        final eyePaint = Paint()..color = personPaint.color.withValues(alpha: 0.7)..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(122, 72 + breatheOffset * 0.5), 2, eyePaint);
        canvas.drawCircle(Offset(138, 72 + breatheOffset * 0.5), 2, eyePaint);
        // Slight flat mouth
        canvas.drawLine(
          Offset(124, 82 + breatheOffset * 0.5),
          Offset(136, 82 + breatheOffset * 0.5),
          Paint()..color = personPaint.color.withValues(alpha: 0.5)..strokeWidth = 1.5..strokeCap = StrokeCap.round,
        );
      }
    }

    // Body
    if (wrongGuesses >= 2) {
      final alpha = partAlpha(1);
      final bodyPaint = Paint()..color = personPaint.color.withValues(alpha: alpha)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(130, 100 + breatheOffset * 0.5), Offset(130, 170 + breatheOffset * 0.3), bodyPaint);
    }
    // Left Arm
    if (wrongGuesses >= 3) {
      final alpha = partAlpha(2);
      final armPaint = Paint()..color = personPaint.color.withValues(alpha: alpha)..strokeWidth = 3..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(130, 120 + breatheOffset * 0.4), Offset(100, 148 + breatheOffset * 0.2), armPaint);
    }
    // Right Arm
    if (wrongGuesses >= 4) {
      final alpha = partAlpha(3);
      final armPaint = Paint()..color = personPaint.color.withValues(alpha: alpha)..strokeWidth = 3..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(130, 120 + breatheOffset * 0.4), Offset(160, 148 + breatheOffset * 0.2), armPaint);
    }
    // Left Leg
    if (wrongGuesses >= 5) {
      final alpha = partAlpha(4);
      final legPaint = Paint()..color = personPaint.color.withValues(alpha: alpha)..strokeWidth = 3..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(130, 170 + breatheOffset * 0.3), Offset(100, 208 + breatheOffset * 0.1), legPaint);
    }
    // Right Leg
    if (wrongGuesses >= 6) {
      final alpha = partAlpha(5);
      final legPaint = Paint()..color = personPaint.color.withValues(alpha: alpha)..strokeWidth = 3..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(130, 170 + breatheOffset * 0.3), Offset(160, 208 + breatheOffset * 0.1), legPaint);
    }
  }
}
