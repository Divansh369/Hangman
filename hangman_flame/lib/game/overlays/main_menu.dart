import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../difficulty_level.dart';
import '../../data/words.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../widgets/ui_widgets.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';

class MainMenu extends StatefulWidget {
  final HangmanGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  String selectedCategory = categories.keys.first;
  String selectedTheme = themes.keys.first;
  String mode = '1-Player';
  String onePlayerMode = 'Classic';
  DifficultyLevel selectedDifficulty = DifficultyLevel.medium;
  String singlePlayerStyle = 'Classic';
  String twoPlayerStyle = 'Classic Duel';
  final TextEditingController _customWordController = TextEditingController();
  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _customWordController.dispose();
    _heroCtrl.dispose();
    super.dispose();
  }

  void _showLeaderboard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leaderboard'),
        content: const Text('Leaderboard coming soon.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  void _onStartPressed() {
    if (mode == '1-Player') {
      int timeLimit = 0;
      int hints = 3;
      int minScore = 20;

      if (singlePlayerStyle == 'Speed Run') {
        timeLimit = 90;
        hints = 1;
        minScore = 28;
      } else if (singlePlayerStyle == 'No Hints') {
        timeLimit = 0;
        hints = 0;
        minScore = 35;
      }

      if (onePlayerMode == 'Theme Challenge') {
        widget.game.startGame(
          selectedTheme,
          selectedDifficulty: selectedDifficulty,
          minScore: minScore,
          timeLimitSeconds: timeLimit,
          startingHints: hints,
          startFromTheme: true,
        );
      } else {
        widget.game.startGame(
          selectedCategory,
          selectedDifficulty: selectedDifficulty,
          minScore: minScore,
          timeLimitSeconds: timeLimit,
          startingHints: hints,
        );
      }
    } else if (mode == '2-Player') {
      if (_customWordController.text.isNotEmpty) {
        int timeLimit = 0;
        int hints = 2;
        int minScore = 22;
        DifficultyLevel duelDifficulty = DifficultyLevel.medium;

        if (twoPlayerStyle == 'Blitz Duel') {
          timeLimit = 75;
          hints = 1;
          minScore = 28;
          duelDifficulty = DifficultyLevel.hard;
        } else if (twoPlayerStyle == 'Mindgame') {
          timeLimit = 60;
          hints = 0;
          minScore = 34;
          duelDifficulty = DifficultyLevel.hard;
        }

        widget.game.startGame(
          'Custom',
          customWord: _customWordController.text.toLowerCase(),
          selectedDifficulty: duelDifficulty,
          minScore: minScore,
          timeLimitSeconds: timeLimit,
          startingHints: hints,
          localDuel: true,
          localDuelStyle: twoPlayerStyle,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a secret word')));
      }
    } else if (mode == 'Multiplayer') {
      if (AuthService().isLoggedIn) {
        widget.game.showScreen('Lobby');
      } else {
        widget.game.showScreen('Auth');
      }
    }
  }

  String _dailyChallengeTarget() {
    final seed = ProgressService().generateDailyChallengeSeed();
    return 'Daily #${seed.substring(4)}';
  }

  // === HERO HEADER ===
  Widget _buildHero() {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _heroFade,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: cs.heroGradient,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '🪓',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: cs.primaryGradient,
                        ).createShader(bounds),
                        child: Text(
                          'HANGMAN',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Train your brain, one letter at a time',
                        style: TextStyle(color: cs.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === SINGLE PLAYER HUB ===
  Widget _singlePlayerHub() {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<Map<String, int>>(
      future: ProgressService().getGameStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? <String, int>{};
        final played = stats['gamesPlayed'] ?? 0;
        final won = stats['gamesWon'] ?? 0;
        final streak = stats['streak'] ?? 0;
        final bestScore = stats['bestScore'] ?? 0;
        final winRate = played == 0 ? 0 : ((won * 100) ~/ played);

        final streakGoalDone = streak >= 3;
        final perfectRunDone = bestScore >= 40;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.glassBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlowBadge(icon: Icons.person, color: cs.primary, size: 36),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cs.textPrimary)),
                      Text('Focus goals and brain-racking runs', style: TextStyle(fontSize: 12, color: cs.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatPill(label: 'Played', value: '$played', icon: Icons.sports_esports),
                  StatPill(label: 'Win', value: '$winRate%', icon: Icons.emoji_events),
                  StatPill(label: 'Streak', value: '$streak', icon: Icons.local_fire_department),
                  StatPill(label: 'Best', value: '$bestScore', icon: Icons.star),
                ],
              ),
              const SizedBox(height: 16),
              _goalCard(
                icon: Icons.today_rounded,
                iconColor: cs.tertiary,
                title: 'Daily Puzzle',
                subtitle: '${_dailyChallengeTarget()} \u2022 Hard \u2022 120s \u2022 1 hint',
                completed: false,
                actionLabel: 'Play',
                onTap: () => widget.game.startDailyChallenge(),
              ),
              const SizedBox(height: 10),
              _goalCard(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                title: 'Streak Mission',
                subtitle: streakGoalDone ? 'Completed: 3+ day streak!' : 'Reach a 3-day win streak',
                completed: streakGoalDone,
                actionLabel: 'Run',
                onTap: () {
                  setState(() { selectedDifficulty = DifficultyLevel.medium; singlePlayerStyle = 'Classic'; });
                  _onStartPressed();
                },
              ),
              const SizedBox(height: 10),
              _goalCard(
                icon: Icons.diamond_outlined,
                iconColor: Colors.purple,
                title: 'Perfect Run',
                subtitle: perfectRunDone ? 'Completed: score 40+!' : 'Score 40+ (No Hints + Hard)',
                completed: perfectRunDone,
                actionLabel: 'Try',
                onTap: () {
                  setState(() { selectedDifficulty = DifficultyLevel.hard; singlePlayerStyle = 'No Hints'; });
                  _onStartPressed();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _goalCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool completed,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.glassHighlight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (completed ? cs.letterCorrect : iconColor).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              completed ? Icons.check_circle_rounded : icon,
              color: completed ? cs.letterCorrect : iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: cs.textPrimary, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: cs.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: completed ? cs.letterCorrect.withValues(alpha: 0.15) : cs.primary,
                foregroundColor: completed ? cs.letterCorrect : cs.onPrimary,
              ),
              child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // === MODE SELECTOR ===
  Widget _buildModeSelector() {
    final cs = Theme.of(context).colorScheme;
    final modes = ['1-Player', '2-Player', 'Multiplayer'];
    final icons = [Icons.person, Icons.people, Icons.public];

    return Row(
      children: List.generate(modes.length, (i) {
        final selected = mode == modes[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => mode = modes[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? cs.primary.withValues(alpha: 0.15) : cs.glassBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? cs.primary.withValues(alpha: 0.5) : cs.glassBorder,
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: cs.primaryGlow, blurRadius: 12, spreadRadius: -4)]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[i], size: 22, color: selected ? cs.primary : cs.textMuted),
                    const SizedBox(height: 4),
                    Text(
                      modes[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? cs.primary : cs.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContextInputs() {
    final cs = Theme.of(context).colorScheme;
    if (mode == '1-Player') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Game Type'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Classic', label: Text('Classic')),
              ButtonSegment(value: 'Theme Challenge', label: Text('Theme')),
            ],
            selected: {onePlayerMode},
            onSelectionChanged: (selection) {
              setState(() => onePlayerMode = selection.first);
            },
          ),
          const SizedBox(height: 14),
          _sectionLabel(onePlayerMode == 'Theme Challenge' ? 'Theme' : 'Category'),
          const SizedBox(height: 8),
          _glassDropdown<String>(
            value: onePlayerMode == 'Theme Challenge' ? selectedTheme : selectedCategory,
            items: (onePlayerMode == 'Theme Challenge' ? themes.keys : categories.keys).toList(),
            onChanged: (val) {
              setState(() {
                if (onePlayerMode == 'Theme Challenge') { selectedTheme = val!; }
                else { selectedCategory = val!; }
              });
            },
          ),
          const SizedBox(height: 14),
          if (onePlayerMode == 'Theme Challenge')
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${getAllWordsInTheme(selectedTheme).length} interconnected words. Master all subcategories.',
                        style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _sectionLabel('Difficulty'),
          const SizedBox(height: 8),
          SegmentedButton<DifficultyLevel>(
            segments: const [
              ButtonSegment(value: DifficultyLevel.easy, label: Text('Easy')),
              ButtonSegment(value: DifficultyLevel.medium, label: Text('Medium')),
              ButtonSegment(value: DifficultyLevel.hard, label: Text('Hard')),
            ],
            selected: {selectedDifficulty},
            onSelectionChanged: (selection) {
              setState(() => selectedDifficulty = selection.first);
            },
          ),
          const SizedBox(height: 14),
          _sectionLabel('Style'),
          const SizedBox(height: 8),
          _glassDropdown<String>(
            value: singlePlayerStyle,
            items: const ['Classic', 'Speed Run', 'No Hints'],
            onChanged: (val) => setState(() => singlePlayerStyle = val!),
          ),
          const SizedBox(height: 8),
          _infoText(
            singlePlayerStyle == 'Classic'
                ? 'Balanced run \u2022 3 hints \u2022 no time limit'
                : singlePlayerStyle == 'Speed Run'
                    ? 'Brain pressure \u2022 90s timer \u2022 1 hint'
                    : 'Pure puzzle \u2022 zero hints \u2022 higher star threshold',
          ),
        ],
      );
    } else if (mode == '2-Player') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Duel Style'),
          const SizedBox(height: 8),
          _glassDropdown<String>(
            value: twoPlayerStyle,
            items: const ['Classic Duel', 'Blitz Duel', 'Mindgame'],
            onChanged: (val) => setState(() => twoPlayerStyle = val!),
          ),
          const SizedBox(height: 8),
          _infoText(
            twoPlayerStyle == 'Classic Duel'
                ? 'Balanced face-off \u2022 medium pressure \u2022 2 hints'
                : twoPlayerStyle == 'Blitz Duel'
                    ? 'Fast rivalry \u2022 75s timer \u2022 1 hint'
                    : 'No mercy \u2022 60s timer \u2022 no hints',
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _customWordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Secret Word',
              hintText: 'Enter word for Player 2',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
            ),
          ),
        ],
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.public, size: 36, color: cs.primary),
            const SizedBox(height: 8),
            Text(
              'Challenge players worldwide!',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time turns \u2022 In-game chat \u2022 Collectible badges',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }
  }

  Widget _sectionLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.textMuted, letterSpacing: 0.5));
  }

  Widget _infoText(String text) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.info_outline, size: 14, color: cs.textMuted),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: cs.textMuted))),
      ],
    );
  }

  Widget _glassDropdown<T>({required T value, required List<T> items, required ValueChanged<T?> onChanged}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cs.glassBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: cs.brightness == Brightness.dark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          items: items.map((T v) {
            return DropdownMenuItem<T>(value: v, child: Text('$v', style: const TextStyle(fontWeight: FontWeight.w500)));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final cs = Theme.of(context).colorScheme;
    final width = context.isMobile ? 400.0 : (context.isTablet ? 440.0 : 520.0);

    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(22),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (user != null)
                  Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: cs.primaryGradient),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          (user.getStringValue('username').isNotEmpty) ? user.getStringValue('username')[0].toUpperCase() : '?',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user.getStringValue('username'), style: TextStyle(fontWeight: FontWeight.w700, color: cs.textPrimary)),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: cs.primary),
                          const SizedBox(width: 4),
                          Text('${user.getIntValue('score')} pts', style: TextStyle(color: cs.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ]),
                  ])
                else
                  const SizedBox(),
                Row(children: [
                  _iconBtn(Icons.person_outline, 'Profile', () {
                    if (user != null) { widget.game.showScreen('Profile'); }
                    else { widget.game.showScreen('Auth'); }
                  }),
                  const SizedBox(width: 4),
                  _iconBtn(Icons.settings_outlined, 'Settings', () => widget.game.showScreen('Settings')),
                ]),
              ],
            ),
            const SizedBox(height: 16),

            // Hero
            _buildHero(),
            const SizedBox(height: 16),

            // Mode selector
            _buildModeSelector(),
            const SizedBox(height: 16),

            // Hub (only for 1-Player)
            if (mode == '1-Player') ...[
              _singlePlayerHub(),
              const SizedBox(height: 16),
            ],

            // Context inputs
            _buildContextInputs(),
            const SizedBox(height: 20),

            // Start button
            PrimaryButton(
              label: mode == 'Multiplayer' ? 'ENTER LOBBY' : 'START GAME',
              icon: Icons.play_arrow_rounded,
              onPressed: _onStartPressed,
              height: 56,
            ),
            const SizedBox(height: 12),

            // Bottom row
            Row(
              children: [
                Expanded(
                  child: _menuCard(
                    icon: Icons.emoji_events_outlined,
                    label: 'Leaderboard',
                    onTap: _showLeaderboard,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _menuCard(
                    icon: Icons.grid_view_rounded,
                    label: 'Levels',
                    onTap: () => widget.game.showScreen('Levels'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _menuCard(
                    icon: Icons.auto_awesome,
                    label: 'Badges',
                    onTap: () => widget.game.showScreen('Collectibles'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.glassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.glassBorder),
          ),
          child: Icon(icon, size: 20, color: cs.textMuted),
        ),
      ),
    );
  }

  Widget _menuCard({required IconData icon, required String label, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.glassBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: cs.primary),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.textMuted)),
          ],
        ),
      ),
    );
  }
}
