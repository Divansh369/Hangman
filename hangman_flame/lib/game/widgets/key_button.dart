import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum KeyButtonState {
  idle,
  correct,
  wrong,
  disabled,
}

class KeyButton extends StatefulWidget {
  final String letter;
  final KeyButtonState state;
  final VoidCallback? onPressed;

  const KeyButton({
    super.key,
    required this.letter,
    required this.state,
    required this.onPressed,
  });

  @override
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color background;
    Color foreground;

    switch (widget.state) {
      case KeyButtonState.correct:
        background = cs.letterCorrect;
        foreground = Colors.white;
        break;
      case KeyButtonState.wrong:
        background = cs.letterWrong;
        foreground = Colors.white;
        break;
      case KeyButtonState.disabled:
        background = cs.surfaceContainerHighest;
        foreground = cs.onSurfaceVariant;
        break;
      case KeyButtonState.idle:
        background = cs.primary;
        foreground = cs.onPrimary;
        break;
    }

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _scale = 0.9),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTapUp: (_) => setState(() => _scale = 1.0),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: SizedBox(
          width: 36,
          height: 42,
          child: FilledButton(
            onPressed: widget.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(widget.letter.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
      ),
    );
  }
}
