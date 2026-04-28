import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';
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

  Future<void> _confirmSurrender() async {
    await showDialog<void>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Surrender Run?'),
        content: const Text('You will lose this round and end your current streak momentum.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dctx);
              widget.game.surrender();
            },
            child: const Text('Surrender'),
          ),
        ],
      ),
    );
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

  Widget _glassIconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cs.glassHighlight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: cs.textMuted),
        ),
      ),
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
    final width = context.isMobile ? (MediaQuery.of(context).size.width - 48.0) : 400.0;

    return Center(
      child: CardSurface(
        width: width,
        padding: const EdgeInsets.all(28),
        glowing: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlowBadge(
              icon: isMyTurnToSet ? Icons.edit_note_rounded : Icons.hourglass_top_rounded,
              color: cs.primary,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              isMyTurnToSet ? 'SET THE SECRET WORD' : 'WAITING FOR WORD...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1, color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text('Rules: Only A-Z letters allowed.', style: TextStyle(fontSize: 12, color: cs.textMuted)),
            const SizedBox(height: 20),
            if (isMyTurnToSet) ...[
              TextField(
                controller: _wordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Secret Word', hintText: 'Enter word for opponent', prefixIcon: Icon(Icons.lock_outline, size: 20)),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Confirm Word',
                icon: Icons.check_rounded,
                onPressed: () {
                  final txt = _wordController.text.trim();
                  if (txt.isNotEmpty) {
                    widget.game.setMultiplayerWord(txt);
                  }
                },
              ),
            ] else
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary),
              ),
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
          const SizedBox(height: 16),
          // Top bar with glass effect
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.glassBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.glassBorder),
                  ),
                  child: Row(
                    children: [
                      _glassIconBtn(Icons.pause_rounded, 'Pause', _showPauseDialog),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.game.isLocalDuel
                              ? '2P ${widget.game.duelStyle} \u2022 ${widget.game.difficulty.displayName}'
                              : widget.game.isThemeChallenge
                                  ? '${widget.game.currentThemeNotifier.value} \u2022 ${widget.game.difficulty.displayName}'
                                  : '${widget.game.currentCategory} \u2022 ${widget.game.difficulty.displayName}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700, color: cs.textMuted, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _glassIconBtn(Icons.flag_outlined, 'Surrender', _confirmSurrender),
                      const SizedBox(width: 4),
                      _glassIconBtn(Icons.home_rounded, 'Menu', () => widget.game.resetToMenu()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.game.isMultiplayer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.glassBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sports_esports, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Room ${widget.game.currentRoomId ?? '-'} \u2022 Round ${widget.game.currentRound}',
                            style: TextStyle(fontWeight: FontWeight.w700, color: cs.textPrimary),
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: widget.game.multiplayerTurnTimeLeftNotifier,
                          builder: (context, turnLeft, _) {
                            final mm = (turnLeft ~/ 60).toString().padLeft(2, '0');
                            final ss = (turnLeft % 60).toString().padLeft(2, '0');
                            final critical = turnLeft > 0 && turnLeft <= 8;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: critical ? cs.errorContainer : cs.glassHighlight,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: critical ? [BoxShadow(color: cs.errorGlow, blurRadius: 10)] : [],
                              ),
                              child: Text(
                                'Turn $mm:$ss',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: critical ? cs.onErrorContainer : cs.textPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (widget.game.isMultiplayer) const SizedBox(height: 8),
          if (widget.game.isThemeChallenge)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ValueListenableBuilder<int>(
                valueListenable: widget.game.wordProgressNotifier,
                builder: (context, current, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: widget.game.totalWordsNotifier,
                    builder: (context, total, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: cs.glassBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cs.glassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Theme Progress', style: TextStyle(fontWeight: FontWeight.w700, color: cs.textPrimary, fontSize: 13)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: cs.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('$current / $total', style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: total > 0 ? current / total : 0,
                                    minHeight: 6,
                                    backgroundColor: cs.glassHighlight,
                                    valueColor: AlwaysStoppedAnimation(cs.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          if (widget.game.isThemeChallenge) const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: widget.game.wrongGuessesNotifier,
                  builder: (context, wrong, _) {
                    final left = widget.game.maxTries - wrong;
                    final critical = left <= 1 && left >= 0;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: critical ? cs.errorContainer.withValues(alpha: 0.8) : cs.glassBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: critical ? cs.error.withValues(alpha: 0.3) : cs.glassBorder),
                        boxShadow: critical ? [BoxShadow(color: cs.errorGlow, blurRadius: 10)] : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 14,
                            color: critical ? cs.error : cs.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$left/${widget.game.maxTries}',
                            style: TextStyle(color: critical ? cs.onErrorContainer : cs.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<int>(
                  valueListenable: widget.game.roundTimeLeftNotifier,
                  builder: (context, secondsLeft, _) {
                    if (secondsLeft <= 0) return const SizedBox();
                    final mm = (secondsLeft ~/ 60).toString().padLeft(2, '0');
                    final ss = (secondsLeft % 60).toString().padLeft(2, '0');
                    final isCritical = secondsLeft <= 20;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCritical ? cs.errorContainer.withValues(alpha: 0.8) : cs.glassBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isCritical ? cs.error.withValues(alpha: 0.3) : cs.glassBorder),
                        boxShadow: isCritical ? [BoxShadow(color: cs.errorGlow, blurRadius: 10)] : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: isCritical ? cs.error : cs.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            '$mm:$ss',
                            style: TextStyle(color: isCritical ? cs.onErrorContainer : cs.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: cs.cardGradient),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: cs.glassBorder),
                                boxShadow: [BoxShadow(color: cs.primaryGlow, blurRadius: 8, spreadRadius: -4)],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 18, color: cs.primary),
                                  const SizedBox(width: 6),
                                  Text('$score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.textPrimary)),
                                ],
                              ),
                            ),
                            if (lastGain != 0)
                              Positioned(
                                top: -20,
                                right: -8,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.5, end: 1.0),
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutBack,
                                  builder: (context, scale, child) => Transform.scale(scale: scale, child: Opacity(opacity: scale.clamp(0.0, 1.0), child: child)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: lastGain > 0 ? cs.letterCorrect : cs.error,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(color: (lastGain > 0 ? cs.successGlow : cs.errorGlow), blurRadius: 8)],
                                    ),
                                    child: Text(
                                      lastGain > 0 ? '+$lastGain' : '$lastGain',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                widget.game.currentTurnId == AuthService().currentUser?.id ? "YOUR TURN" : "OPPONENT'S TURN",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1,
                  color: widget.game.currentTurnId == AuthService().currentUser?.id ? cs.letterCorrect : cs.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Hints section
          ValueListenableBuilder<int>(
            valueListenable: widget.game.hintsNotifier,
            builder: (context, hints, _) {
              final canUseHint = hints > 0 && (!widget.game.isMultiplayer || widget.game.currentTurnId == AuthService().currentUser?.id);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.glassBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cs.glassBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb_outline, size: 14, color: hints > 0 ? Colors.amber : cs.textMuted),
                            const SizedBox(width: 6),
                            Text('$hints hints', style: TextStyle(color: cs.textMuted, fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 38,
                        child: FilledButton.icon(
                          onPressed: canUseHint
                              ? () async {
                                  final hint = await widget.game.useHint();
                                  if (!context.mounted) return;
                                  if (hint == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to use hint')));
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (dctx) => AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(Icons.lightbulb, color: Colors.amber, size: 22),
                                            const SizedBox(width: 8),
                                            const Text('Hint'),
                                          ],
                                        ),
                                        content: Text(hint),
                                        actions: [TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Got it'))],
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.lightbulb_outline, size: 16),
                          label: const Text('Use Hint', style: TextStyle(fontSize: 12)),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Flexible(child: Text(hint, style: TextStyle(color: cs.textPrimary, fontSize: 13))),
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
          const SizedBox(height: 16),
          // Keyboard
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: ValueListenableBuilder<List<String>>(
              valueListenable: widget.game.guessedLettersNotifier,
              builder: (context, guessedLetters, _) {
                final isMyTurn = !widget.game.isMultiplayer || (widget.game.currentTurnId == AuthService().currentUser?.id);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: cs.glassBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.glassBorder),
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
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
