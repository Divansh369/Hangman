import 'package:flutter/material.dart';

class LetterTile extends StatelessWidget {
  final String value;

  const LetterTile({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isHidden = value == '_';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 42,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHidden ? cs.surfaceContainerLow : cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Text(
          value.toUpperCase(),
          key: ValueKey(value),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isHidden ? cs.onSurfaceVariant : cs.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
