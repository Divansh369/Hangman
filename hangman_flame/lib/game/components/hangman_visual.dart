import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../hangman_game.dart';

class HangmanVisual extends PositionComponent with HasGameReference<HangmanGame> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Base Structure (always visible)
    canvas.drawLine(const Offset(20, 230), const Offset(180, 230), paint);
    canvas.drawLine(const Offset(50, 230), const Offset(50, 20), paint);
    canvas.drawLine(const Offset(50, 20), const Offset(130, 20), paint);
    canvas.drawLine(const Offset(130, 20), const Offset(130, 50), paint);

    final wrongGuesses = game.wrongGuesses;

    // Head
    if (wrongGuesses >= 1) {
      canvas.drawCircle(const Offset(130, 70), 20, paint);
    }
    // Body
    if (wrongGuesses >= 2) {
      canvas.drawLine(const Offset(130, 90), const Offset(130, 160), paint);
    }
    // Left Arm
    if (wrongGuesses >= 3) {
      canvas.drawLine(const Offset(130, 110), const Offset(100, 140), paint);
    }
    // Right Arm
    if (wrongGuesses >= 4) {
      canvas.drawLine(const Offset(130, 110), const Offset(160, 140), paint);
    }
    // Left Leg
    if (wrongGuesses >= 5) {
      canvas.drawLine(const Offset(130, 160), const Offset(100, 200), paint);
    }
    // Right Leg
    if (wrongGuesses >= 6) {
      canvas.drawLine(const Offset(130, 160), const Offset(160, 200), paint);
    }
  }
}
