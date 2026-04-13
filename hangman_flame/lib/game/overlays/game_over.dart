import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../widgets/ui_widgets.dart';
import '../../theme/app_colors.dart';

class GameOver extends StatelessWidget {
  final HangmanGame game;
  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return OverlayScaffold(
      width: 380,
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: game.winNotifier,
            builder: (context, won, _) {
              return Column(
                children: [
                  Icon(
                    won ? Icons.celebration : Icons.sentiment_very_dissatisfied,
                    size: 44,
                    color: won ? cs.letterCorrect : cs.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    won ? 'YOU WON!' : 'GAME OVER',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: won ? cs.letterCorrect : cs.error,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'The word was',
                  style: TextStyle(color: cs.textMuted, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  game.secretWord.toUpperCase(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _StatChip(label: 'Score', value: '${game.score}'),
              _StatChip(label: 'Wrong', value: '${game.wrongGuesses}/${game.maxTries}'),
              _StatChip(label: 'Category', value: game.currentCategory),
            ],
          ),
          const SizedBox(height: 18),
          if (!game.isMultiplayer || game.isHost)
            PrimaryButton(
              label: 'Play Again',
              onPressed: () => game.isMultiplayer ? game.restartMultiplayer() : game.startGame(game.currentCategory),
            )
          else
            Text('Waiting for host to restart...', style: TextStyle(fontStyle: FontStyle.italic, color: cs.textMuted)),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Levels',
            onPressed: () => game.showScreen('Levels'),
          ),
          const SizedBox(height: 8),
          DangerButton(label: 'Main Menu', onPressed: () => game.resetToMenu()),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(color: cs.textMuted, fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
