import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../widgets/ui_widgets.dart';
import '../../theme/app_colors.dart';

class GameOver extends StatefulWidget {
  final HangmanGame game;
  const GameOver({super.key, required this.game});

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.05).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 40),
    ]).animate(_ctrl);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
              if (nextWord.isEmpty) return;
              Navigator.pop(dctx);
              widget.game.startGame(
                'Custom',
                customWord: nextWord,
                selectedDifficulty: widget.game.difficulty,
                minScore: widget.game.minScoreForLevel,
                timeLimitSeconds: widget.game.roundTimeLimitSeconds,
                startingHints: widget.game.startingHintsPerRound,
                localDuel: true,
                localDuelStyle: widget.game.duelStyle,
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
    final game = widget.game;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: OverlayScaffold(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: game.winNotifier,
                builder: (context, won, _) {
                  final titleText = game.isMultiplayer
                      ? (won ? 'ROUND WON' : 'ROUND LOST')
                      : game.isThemeChallenge
                          ? (won ? 'THEME MASTERED' : 'THEME FALLEN')
                          : (won ? 'VICTORY!' : 'GAME OVER');
                  final color = won ? cs.letterCorrect : cs.statusError;
                  return Column(
                    children: [
                      // Glowing icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.12),
                          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 32, spreadRadius: -4)],
                        ),
                        child: Icon(
                          won
                              ? (game.isThemeChallenge ? Icons.auto_awesome : Icons.emoji_events_rounded)
                              : Icons.heart_broken_rounded,
                          size: 36,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: won
                              ? [cs.letterCorrect, cs.primary]
                              : [cs.statusError, cs.error],
                        ).createShader(bounds),
                        child: Text(
                          titleText,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      if (game.isMultiplayer)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            won ? 'Clutch finish. Keep momentum!' : 'Breathe, adapt, hit revenge.',
                            style: TextStyle(color: cs.textMuted, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else if (game.isThemeChallenge && won)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'All ${game.themeWordsToGuess.length} words conquered!',
                            style: TextStyle(color: cs.textMuted, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),

              // Word reveal / theme progress
              if (game.isThemeChallenge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.glassBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.glassBorder),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${game.completedWords.length} / ${game.themeWordsToGuess.length} Words',
                        style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: game.completedWords
                            .map((word) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(word.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary)),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.glassBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.glassBorder),
                  ),
                  child: Column(
                    children: [
                      Text('The word was', style: TextStyle(color: cs.textMuted, fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        game.secretWord.toUpperCase(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3, color: cs.textPrimary),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Stats row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  StatPill(label: 'Score', value: '${game.score}', icon: Icons.star),
                  StatPill(label: 'Wrong', value: '${game.wrongGuesses}/${game.maxTries}', icon: Icons.close),
                  StatPill(label: 'Stars', value: '${game.calculateStars()}/3', icon: Icons.auto_awesome),
                  StatPill(label: game.difficulty.displayName, value: '', icon: Icons.speed),
                  if (game.isLocalDuel) StatPill(label: 'Duel', value: game.duelStyle),
                  if (game.isThemeChallenge)
                    StatPill(label: 'Theme', value: game.currentThemeName ?? '')
                  else
                    StatPill(label: '', value: game.currentCategory, icon: Icons.category),
                ],
              ),
              const SizedBox(height: 22),

              // Actions
              if (game.isLocalDuel)
                PrimaryButton(
                  label: 'REVENGE MATCH',
                  icon: Icons.replay_rounded,
                  onPressed: () => _showRevengeMatchDialog(context),
                )
              else if (!game.isMultiplayer || game.isHost)
                PrimaryButton(
                  label: 'PLAY AGAIN',
                  icon: Icons.refresh_rounded,
                  onPressed: () => game.isMultiplayer ? game.restartMultiplayer() : game.startGame(game.currentCategory),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.glassBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary)),
                      const SizedBox(width: 10),
                      Text('Waiting for host...', style: TextStyle(fontStyle: FontStyle.italic, color: cs.textMuted)),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              SecondaryButton(label: 'Levels', onPressed: () => game.showScreen('Levels')),
              const SizedBox(height: 8),
              DangerButton(label: 'Main Menu', onPressed: () => game.resetToMenu()),
            ],
          ),
        ),
      ),
    );
  }
}
