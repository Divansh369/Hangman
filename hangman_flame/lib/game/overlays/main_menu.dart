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

class _MainMenuState extends State<MainMenu> {
  String selectedCategory = categories.keys.first;
  String selectedTheme = themes.keys.first;
  String mode = '1-Player';
  String onePlayerMode = 'Classic'; // 'Classic' or 'Theme Challenge'
  DifficultyLevel selectedDifficulty = DifficultyLevel.medium;
  String singlePlayerStyle = 'Classic';
  String twoPlayerStyle = 'Classic Duel';
  final TextEditingController _customWordController = TextEditingController();

  @override
  void dispose() {
    _customWordController.dispose();
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

      // Check if theme challenge mode is selected
      if (onePlayerMode == 'Theme Challenge') {
        widget.game.startGame(
          selectedTheme,
          selectedDifficulty: selectedDifficulty,
          minScore: minScore,
          timeLimitSeconds: timeLimit,
          startingHints: hints,
          startFromTheme: true, // NEW: Load all words from theme
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
    return 'Daily ID: ${seed.substring(4)}';
  }

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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1 Player Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cs.textPrimary)),
              const SizedBox(height: 4),
              Text('Focus goals and quick starts for a brain-racking run.', style: TextStyle(fontSize: 12, color: cs.textMuted)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(context, 'Played', '$played'),
                  _chip(context, 'Win Rate', '$winRate%'),
                  _chip(context, 'Streak', '$streak'),
                  _chip(context, 'Best', '$bestScore'),
                ],
              ),
              const SizedBox(height: 12),
              _goalTile(
                context,
                title: 'Daily Puzzle',
                subtitle: '${_dailyChallengeTarget()} • Hard • 120s • 1 hint',
                completed: false,
                action: 'Play',
                onTap: () => widget.game.startDailyChallenge(),
              ),
              const SizedBox(height: 8),
              _goalTile(
                context,
                title: 'Streak Mission',
                subtitle: streakGoalDone ? 'Completed: 3+ day streak maintained' : 'Reach a 3-day streak to lock this mission',
                completed: streakGoalDone,
                action: 'Run',
                onTap: () {
                  setState(() {
                    selectedDifficulty = DifficultyLevel.medium;
                    singlePlayerStyle = 'Classic';
                  });
                  _onStartPressed();
                },
              ),
              const SizedBox(height: 8),
              _goalTile(
                context,
                title: 'Perfect Run',
                subtitle: perfectRunDone ? 'Completed: best score reached 40+' : 'Score 40+ in one run (No Hints + Hard)',
                completed: perfectRunDone,
                action: 'Try',
                onTap: () {
                  setState(() {
                    selectedDifficulty = DifficultyLevel.hard;
                    singlePlayerStyle = 'No Hints';
                  });
                  _onStartPressed();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(color: cs.textMuted, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _goalTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool completed,
    required String action,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.bolt,
            color: completed ? cs.letterCorrect : cs.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: cs.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: cs.textMuted)),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: mode,
          isExpanded: true,
          items: ['1-Player', '2-Player', 'Multiplayer'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (val) => setState(() => mode = val!),
        ),
      ),
    );
  }

  Widget _buildContextInputs() {
    final cs = Theme.of(context).colorScheme;
    if (mode == '1-Player') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Game Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.textMuted)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Classic', label: Text('Classic')),
              ButtonSegment(value: 'Theme Challenge', label: Text('Theme Challenge')),
            ],
            selected: {onePlayerMode},
            onSelectionChanged: (selection) {
              setState(() => onePlayerMode = selection.first);
            },
          ),
          const SizedBox(height: 12),
          Text(onePlayerMode == 'Theme Challenge' ? 'Theme' : 'Category', 
               style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.textMuted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cs.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: onePlayerMode == 'Theme Challenge' ? selectedTheme : selectedCategory,
                isExpanded: true,
                items: (onePlayerMode == 'Theme Challenge' ? themes.keys : categories.keys).map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    if (onePlayerMode == 'Theme Challenge') {
                      selectedTheme = val!;
                    } else {
                      selectedCategory = val!;
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (onePlayerMode == 'Theme Challenge')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${getAllWordsInTheme(selectedTheme).length} interconnected words with crossword-style hints. Master all subcategories to complete.',
                style: TextStyle(fontSize: 12, color: cs.textMuted, fontStyle: FontStyle.italic),
              ),
            ),
          Text('Difficulty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.textMuted)),
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
          const SizedBox(height: 12),
          Text('Style', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.textMuted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cs.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: singlePlayerStyle,
                isExpanded: true,
                items: const ['Classic', 'Speed Run', 'No Hints'].map((value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => singlePlayerStyle = val!),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            singlePlayerStyle == 'Classic'
                ? 'Balanced run: 3 hints, no time limit.'
                : singlePlayerStyle == 'Speed Run'
                    ? 'Brain pressure: 90s total timer and only 1 hint.'
                    : 'Pure puzzle mode: zero hints, higher star threshold.',
            style: TextStyle(fontSize: 12, color: cs.textMuted),
          ),
        ],
      );
    } else if (mode == '2-Player') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Duel Style', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.textMuted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cs.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: twoPlayerStyle,
                isExpanded: true,
                items: const ['Classic Duel', 'Blitz Duel', 'Mindgame'].map((value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => twoPlayerStyle = val!),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            twoPlayerStyle == 'Classic Duel'
                ? 'Balanced face-off: medium pressure, 2 hints.'
                : twoPlayerStyle == 'Blitz Duel'
                    ? 'Fast rivalry: 75s timer, 1 hint, hard scoring.'
                    : 'No mercy: 60s timer, no hints, hard mode.',
            style: TextStyle(fontSize: 12, color: cs.textMuted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customWordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Secret Word',
              hintText: 'Enter word for Player 2',
              filled: true,
              fillColor: cs.surface2,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      );
    } else {
      return Text(
        'Challenge players around the world!',
        textAlign: TextAlign.center,
        style: TextStyle(color: cs.textMuted),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final cs = Theme.of(context).colorScheme;
    // Responsive width: 380 on mobile, scale up to 500 on larger screens
    final width = context.isMobile ? 380.0 : (context.isTablet ? 420.0 : 500.0);

    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Header row: user info (left) and action icons (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              user != null
                  ? Row(children: [
                      CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Text((user.getStringValue('username').isNotEmpty) ? user.getStringValue('username')[0].toUpperCase() : '?'),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user.getStringValue('username'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${user.getIntValue('score')} Points', style: TextStyle(color: cs.textMuted, fontSize: 12)),
                      ]),
                    ])
                  : const SizedBox(),
              Row(children: [
                IconButton(
                  icon: Icon(Icons.person, size: 20, color: cs.textMuted),
                  onPressed: () {
                    if (user != null) {
                      widget.game.showScreen('Profile');
                    } else {
                      widget.game.showScreen('Auth');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, size: 20, color: cs.textMuted),
                  onPressed: () {
                    widget.game.showScreen('Settings');
                  },
                ),
              ])
            ],
          ),
          const Divider(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.surface2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🪓 HANGMAN',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Choose your mode and start playing', style: TextStyle(color: cs.textMuted)),
              ],
            ),
          ),
          Text(
            mode,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.primary),
          ),
          const SizedBox(height: 12),
          if (mode == '1-Player') _singlePlayerHub(),
          if (mode != '1-Player')
            PrimaryButton(
              label: 'PLAY 1 PLAYER',
              height: 56,
              onPressed: () {
                setState(() => mode = '1-Player');
              },
            ),
          const SizedBox(height: 12),
          _buildModeSelector(),
          const SizedBox(height: 12),
          _buildContextInputs(),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'START GAME',
            onPressed: _onStartPressed,
            height: 56,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _showLeaderboard,
            icon: const Icon(Icons.emoji_events),
            label: const Text('LEADERBOARD'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    widget.game.showScreen('Levels');
                  },
                  icon: const Icon(Icons.grid_view),
                  label: const Text('LEVELS'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    widget.game.showScreen('Collectibles');
                  },
                  icon: const Icon(Icons.star_border),
                  label: const Text('COLLECTIBLES'),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}
