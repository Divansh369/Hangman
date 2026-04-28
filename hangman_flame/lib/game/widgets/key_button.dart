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

class _KeyButtonState extends State<KeyButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late final AnimationController _revealCtrl;
  late final Animation<double> _revealAnim;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _revealAnim = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOutBack);
  }

  @override
  void didUpdateWidget(covariant KeyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == KeyButtonState.idle &&
        (widget.state == KeyButtonState.correct || widget.state == KeyButtonState.wrong)) {
      _revealCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color background;
    Color foreground;
    List<BoxShadow> shadows = [];

    switch (widget.state) {
      case KeyButtonState.correct:
        background = cs.letterCorrect;
        foreground = Colors.white;
        shadows = [BoxShadow(color: cs.successGlow, blurRadius: 12, spreadRadius: -2)];
        break;
      case KeyButtonState.wrong:
        background = cs.letterWrong.withValues(alpha: 0.7);
        foreground = Colors.white.withValues(alpha: 0.8);
        break;
      case KeyButtonState.disabled:
        background = cs.surfaceContainerHighest.withValues(alpha: 0.3);
        foreground = cs.onSurfaceVariant.withValues(alpha: 0.4);
        break;
      case KeyButtonState.idle:
        background = cs.glassBackground;
        foreground = cs.textPrimary;
        shadows = [BoxShadow(color: cs.shadow.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))];
        break;
    }

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _scale = 0.88),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed?.call();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _scale,
        child: AnimatedBuilder(
          animation: _revealAnim,
          builder: (context, child) {
            final extraScale = (widget.state == KeyButtonState.correct || widget.state == KeyButtonState.wrong)
                ? 0.85 + 0.15 * _revealAnim.value
                : 1.0;
            return Transform.scale(scale: extraScale, child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 36,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
              border: widget.state == KeyButtonState.idle
                  ? Border.all(color: cs.glassBorder)
                  : null,
              boxShadow: shadows,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.letter.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: foreground,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
