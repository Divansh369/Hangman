import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../../services/progress_service.dart';
import '../../data/levels.dart';
import '../widgets/ui_widgets.dart';

class LevelsOverlay extends StatefulWidget {
  final HangmanGame game;
  const LevelsOverlay({super.key, required this.game});

  @override
  State<LevelsOverlay> createState() => _LevelsOverlayState();
}

class _LevelsOverlayState extends State<LevelsOverlay> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return OverlayScaffold(
      width: 420,
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Levels', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        FutureBuilder<Map<String, dynamic>?>(
          future: ProgressService().getProgress(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final completed = <String>{};
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              final levels = (data['levelsCompleted'] as List<dynamic>?) ?? [];
              for (final l in levels) {
                completed.add(l.toString());
              }
            }

            // find next level index (first not completed)
            int nextIndex = 0;
            for (int i = 0; i < gameLevels.length; i++) {
              final id = gameLevels[i]['id']!;
              if (!completed.contains(id)) {
                nextIndex = i;
                break;
              }
            }

            // If showing only next level
            if (!_showAll) {
              final lvl = gameLevels[nextIndex];
              final id = lvl['id']!;
              final bool isCompleted = completed.contains(id);
              final bool isUnlocked = nextIndex == 0 || completed.contains(gameLevels[nextIndex - 1]['id']);

              return Column(mainAxisSize: MainAxisSize.min, children: [
                CardSurface(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(lvl['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(lvl['description'] ?? ''),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: isUnlocked ? (isCompleted ? 'Replay' : 'Play') : 'Locked',
                      onPressed: isUnlocked
                          ? () {
                              game.startGame(lvl['category']!, levelId: id);
                            }
                          : null,
                      height: 48,
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => setState(() => _showAll = true), child: const Text('Show all levels')),
                  ]),
                ),
              ]);
            }

            // Show full level list
            return SizedBox(
              height: 340,
              child: ListView.builder(
                itemCount: gameLevels.length,
                itemBuilder: (context, i) {
                  final lvl = gameLevels[i];
                  final id = lvl['id']!;
                  final bool isCompleted = completed.contains(id);
                  final bool isUnlocked = i == 0 || completed.contains(gameLevels[i - 1]['id']);

                  return ListTile(
                    leading: isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : (isUnlocked ? const Icon(Icons.checklist_rtl, color: Colors.blue) : const Icon(Icons.lock, color: Colors.grey)),
                    title: Text('${lvl['title']} • ${lvl['category']}'),
                    subtitle: Text(lvl['description'] ?? ''),
                    trailing: isCompleted
                        ? const Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                        : (isUnlocked
                            ? PrimaryButton(
                                label: 'Play',
                                minWidth: 90,
                                height: 40,
                                onPressed: () {
                                  game.startGame(lvl['category']!, levelId: id);
                                },
                              )
                            : const Text('Locked', style: TextStyle(color: Colors.grey))),
                    onTap: isUnlocked
                        ? () {
                            game.startGame(lvl['category']!, levelId: id);
                          }
                        : null,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: PrimaryButton(
              label: 'Back',
              onPressed: () {
                widget.game.showMainMenu();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _showAll = !_showAll),
              child: Text(_showAll ? 'Show Next' : 'Show All'),
            ),
          ),
        ])
      ]),
    );
  }
}
