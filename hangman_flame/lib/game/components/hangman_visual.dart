import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../hangman_game.dart';

class HangmanVisual extends PositionComponent with HasGameReference<HangmanGame> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final wrongGuesses = game.wrongGuesses;
    final isGameOver = game.isGameOver;
    final didWin = game.didWin;

    // Base Structure
    // Base
    canvas.drawLine(const Offset(20, 230), const Offset(180, 230), paint);
    // Vertical Pole
    canvas.drawLine(const Offset(50, 230), const Offset(50, 20), paint);
    // Horizontal Pole
    canvas.drawLine(const Offset(50, 20), const Offset(130, 20), paint);
    // Rope
    canvas.drawLine(const Offset(130, 20), const Offset(130, 50), paint..strokeWidth = 3);

    paint.strokeWidth = 4;
    // Head
    if (wrongGuesses >= 1) {
      canvas.drawCircle(const Offset(130, 75), 25, paint);
      if (isGameOver && !didWin) {
        // X eyes for loss
        final eyePaint = Paint()..color = Colors.red..strokeWidth = 2;
        canvas.drawLine(const Offset(120, 65), const Offset(125, 70), eyePaint);
        canvas.drawLine(const Offset(125, 65), const Offset(120, 70), eyePaint);
        canvas.drawLine(const Offset(135, 65), const Offset(140, 70), eyePaint);
        canvas.drawLine(const Offset(140, 65), const Offset(135, 70), eyePaint);
        // Sad mouth
        canvas.drawArc(Rect.fromLTWH(120, 80, 20, 10), 3.14, 3.14, false, eyePaint);
      } else if (isGameOver && didWin) {
        // Happy eyes
        final winPaint = Paint()..color = Colors.green..strokeWidth = 2;
        canvas.drawCircle(const Offset(122, 70), 2, winPaint);
        canvas.drawCircle(const Offset(138, 70), 2, winPaint);
        // Big smile
        canvas.drawArc(Rect.fromLTWH(120, 75, 20, 10), 0, 3.14, false, winPaint);
      }
    }
    // Body
    if (wrongGuesses >= 2) {
      canvas.drawLine(const Offset(130, 100), const Offset(130, 170), paint);
    }
    // Left Arm
    if (wrongGuesses >= 3) {
      canvas.drawLine(const Offset(130, 120), const Offset(100, 150), paint);
    }
    // Right Arm
    if (wrongGuesses >= 4) {
      canvas.drawLine(const Offset(130, 120), const Offset(160, 150), paint);
    }
    // Left Leg
    if (wrongGuesses >= 5) {
      canvas.drawLine(const Offset(130, 170), const Offset(100, 210), paint);
    }
    // Right Leg
    if (wrongGuesses >= 6) {
      canvas.drawLine(const Offset(130, 170), const Offset(160, 210), paint);
    }
  }
}
