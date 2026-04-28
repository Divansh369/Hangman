import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LetterTile extends StatelessWidget {
  final String value;

  const LetterTile({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isHidden = value == '_';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      width: 44,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isHidden
            ? null
            : LinearGradient(
                colors: [cs.primaryContainer, cs.primaryContainer.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isHidden ? cs.glassBackground : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHidden ? cs.glassBorder : cs.primary.withValues(alpha: 0.3),
          width: isHidden ? 1 : 1.5,
        ),
        boxShadow: isHidden
            ? []
            : [
                BoxShadow(color: cs.primaryGlow, blurRadius: 12, offset: const Offset(0, 2)),
              ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(begin: math.pi / 2, end: 0.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          );
          return AnimatedBuilder(
            animation: rotate,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(rotate.value),
                child: Opacity(
                  opacity: animation.value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
        child: Text(
          value.toUpperCase(),
          key: ValueKey(value),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isHidden ? cs.onSurfaceVariant.withValues(alpha: 0.3) : cs.onPrimaryContainer,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
