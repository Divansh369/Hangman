import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../hangman_game.dart';
import '../widgets/key_button.dart';
import '../widgets/letter_tile.dart';
import '../widgets/ui_widgets.dart';
import 'chat_overlay.dart';

class GameUI extends StatefulWidget {
  final HangmanGame game;
  const GameUI({super.key, required this.game});

  @override
  State<GameUI> createState() => _GameUIState();
}

class _GameUIState extends State<GameUI> with SingleTickerProviderStateMixin {
  final TextEditingController _wordController = TextEditingController();
  late final AnimationController _shakeController;
  late int _lastWrongGuesses;

  static const List<String> _keyboardRows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _lastWrongGuesses = widget.game.wrongGuessesNotifier.value;
    widget.game.wrongGuessesNotifier.addListener(_handleWrongGuessChange);
  }

  @override
  void dispose() {
    widget.game.wrongGuessesNotifier.removeListener(_handleWrongGuessChange);
    _shakeController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  void _handleWrongGuessChange() {
    final current = widget.game.wrongGuessesNotifier.value;
    if (current > _lastWrongGuesses) {
      _shakeController.forward(from: 0);
    }
    _lastWrongGuesses = current;
  }

  Future<void> _showPauseDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('Game Paused'),
          content: const Text('Take a break or continue your run.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Resume')),
            TextButton(
              onPressed: () {
                Navigator.pop(dctx);
                widget.game.showScreen('Settings');
              },
              child: const Text('Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dctx);
                widget.game.resetToMenu();
              },
              child: const Text('Quit to Menu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.game.isWaitingForWordNotifier,
            builder: (context, isWaiting, _) {
              if (isWaiting) {
                return _buildWordEntryScreen();
              }
              return _buildGameScreen();
            },
          ),
        ),
        if (widget.game.isMultiplayer) ChatOverlay(game: widget.game),
      ],
    );
  }

  Widget _buildWordEntryScreen() {
    final cs = Theme.of(context).colorScheme;
    final isMyTurnToSet = widget.game.currentTurnId == AuthService().currentUser?.id;

    return Center(
      child: CardSurface(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMyTurnToSet ? 'SET THE SECRET WORD' : 'WAITING FOR WORD...',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Rules: Only A-Z letters allowed.', style: TextStyle(fontSize: 12, color: cs.textMuted)),
            const SizedBox(height: 20),
            if (isMyTurnToSet) ...[
              TextField(
                controller: _wordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Secret Word', hintText: 'Enter word for opponent'),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Confirm Word',
                onPressed: () {
                  final txt = _wordController.text.trim();
                  if (txt.isNotEmpty) {
                    widget.game.setMultiplayerWord(txt);
                  }
                },
              ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final cs = Theme.of(context).colorScheme;
    final bottomSafe = MediaQuery.of(context).padding.bottom + 96.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSafe),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _showPauseDialog,
                  icon: const Icon(Icons.pause_rounded),
                  tooltip: 'Pause',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.game.currentCategory,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, color: cs.textMuted),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => widget.game.resetToMenu(),
                  icon: const Icon(Icons.home_rounded),
                  tooltip: 'Main Menu',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                ValueListenableBuilder<int>(
                  valueListenable: widget.game.scoreNotifier,
                  builder: (context, score, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: widget.game.lastScoreGainNotifier,
                      builder: (context, lastGain, _) {
                        return Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: cs.surface2,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emoji_events, size: 18, color: cs.primary),
                                  const SizedBox(width: 8),
                                  Text('$score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            if (lastGain > 0)
                              Positioned(
                                top: -18,
                                right: -6,
                                child: AnimatedOpacity(
                                  opacity: 1,
                                  duration: const Duration(milliseconds: 220),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.7, end: 1.0),
                                    duration: const Duration(milliseconds: 300),
                                    builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: cs.letterCorrect, borderRadius: BorderRadius.circular(12)),
                                      child: Text('+$lastGain', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<String>(
            valueListenable: widget.game.wordNotifier,
            builder: (context, word, _) {
              final letters = word.split(' ');
              return AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final dx = math.sin(_shakeController.value * math.pi * 6) * 6;
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: letters.map((letter) => LetterTile(value: letter)).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          if (widget.game.isMultiplayer)
            Text(
              widget.game.currentTurnId == AuthService().currentUser?.id ? "YOUR TURN" : "OPPONENT'S TURN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.game.currentTurnId == AuthService().currentUser?.id ? cs.letterCorrect : cs.textMuted,
              ),
            ),
          const SizedBox(height: 12),
          ValueListenableBuilder<int>(
            valueListenable: widget.game.hintsNotifier,
            builder: (context, hints, _) {
              final canUseHint = hints > 0 && (!widget.game.isMultiplayer || widget.game.currentTurnId == AuthService().currentUser?.id);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Hints: $hints', style: TextStyle(color: cs.textMuted)),
                      const SizedBox(width: 12),
                      PrimaryButton(
                        label: 'Use Hint',
                        minWidth: 120,
                        height: 40,
                        onPressed: canUseHint
                            ? () async {
                                final hint = await widget.game.useHint();
                                if (!context.mounted) {
                                  return;
                                }
                                if (hint == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to use hint')));
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (dctx) => AlertDialog(
                                      title: const Text('Hint'),
                                      content: Text(hint),
                                      actions: [TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('OK'))],
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String?>(
                    valueListenable: widget.game.hintNotifier,
                    builder: (context, hint, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 360),
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(animation);
                          return FadeTransition(opacity: animation, child: SlideTransition(position: offset, child: child));
                        },
                        child: hint == null
                            ? const SizedBox.shrink(key: ValueKey('hint_empty'))
                            : Container(
                                key: ValueKey('hint_$hint'),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(color: cs.surface2, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lightbulb_outline, size: 16, color: cs.primary),
                                    const SizedBox(width: 6),
                                    Flexible(child: Text('Hint: $hint', style: TextStyle(color: cs.textPrimary))),
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ValueListenableBuilder<List<String>>(
              valueListenable: widget.game.guessedLettersNotifier,
              builder: (context, guessedLetters, _) {
                final isMyTurn = !widget.game.isMultiplayer || (widget.game.currentTurnId == AuthService().currentUser?.id);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surface1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    children: _keyboardRows.map((row) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: row.split('').map((letter) {
                            final isGuessed = guessedLetters.contains(letter);
                            final inWord = widget.game.secretWord.contains(letter);
                            final state = isGuessed
                                ? (inWord ? KeyButtonState.correct : KeyButtonState.wrong)
                                : (isMyTurn ? KeyButtonState.idle : KeyButtonState.disabled);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: KeyButton(
                                letter: letter,
                                state: state,
                                onPressed: (isGuessed || !isMyTurn) ? null : () => widget.game.makeGuess(letter),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
