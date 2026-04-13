import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../widgets/ui_widgets.dart';
import '../../theme/app_colors.dart';

class GameOver extends StatelessWidget {
  final HangmanGame game;
  const GameOver({super.key, required this.game});

  Future<void> _showRevengeMatchDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Revenge Match'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Secret Word',
            hintText: 'Enter word for opponent',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final nextWord = controller.text.trim().toLowerCase();
              if (nextWord.isEmpty) {
                return;
              }
              Navigator.pop(dctx);
              game.startGame(
                'Custom',
                customWord: nextWord,
                selectedDifficulty: game.difficulty,
                minScore: game.minScoreForLevel,
                timeLimitSeconds: game.roundTimeLimitSeconds,
                startingHints: game.startingHintsPerRound,
                localDuel: true,
                localDuelStyle: game.duelStyle,
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

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
              final titleText = game.isMultiplayer
                  ? (won ? 'ROUND WON' : 'ROUND LOST')
                  : game.isThemeChallenge
                      ? (won ? 'THEME MASTERED ✦' : 'THEME FALLEN')
                      : (won ? 'YOU WON!' : 'GAME OVER');
              return Column(
                children: [
                  Icon(
                    won
                        ? (game.isThemeChallenge ? Icons.star : Icons.celebration)
                        : Icons.sentiment_very_dissatisfied,
                    size: 44,
                    color: won ? cs.letterCorrect : cs.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: won ? cs.letterCorrect : cs.error,
                    ),
                  ),
                  if (game.isMultiplayer)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        won ? 'Clutch finish. Keep momentum for the rematch.' : 'Breathe, adapt, and hit revenge match.',
                        style: TextStyle(color: cs.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (game.isThemeChallenge && won)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'All ${game.themeWordsToGuess.length} words conquered across multiple subcategories.',
                        style: TextStyle(color: cs.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          if (game.isThemeChallenge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${game.completedWords.length} / ${game.themeWordsToGuess.length} Words Completed',
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: game.completedWords
                        .map((word) => Chip(
                              label: Text(word.toUpperCase(), style: const TextStyle(fontSize: 12)),
                              backgroundColor: cs.primary.withValues(alpha: 0.2),
                            ))
                        .toList(),
                  ),
                ],
              ),
            )
          else
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
              _StatChip(label: 'Difficulty', value: game.difficulty.displayName),
              _StatChip(label: 'Stars', value: '${game.calculateStars()} / 3'),
              if (game.isLocalDuel) _StatChip(label: 'Duel', value: game.duelStyle),
              if (game.isThemeChallenge)
                _StatChip(label: 'Theme', value: game.currentThemeName ?? 'Unknown')
              else
                _StatChip(label: 'Category', value: game.currentCategory),
            ],
          ),
          const SizedBox(height: 18),
          if (game.isLocalDuel)
            PrimaryButton(
              label: 'Revenge Match',
              onPressed: () => _showRevengeMatchDialog(context),
            )
          else if (!game.isMultiplayer || game.isHost)
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
