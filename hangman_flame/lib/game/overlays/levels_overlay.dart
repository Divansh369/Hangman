import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../../services/progress_service.dart';
import '../../data/levels.dart';
import '../../theme/app_colors.dart';
import '../widgets/ui_widgets.dart';
import '../../utils/responsive_utils.dart';

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
    final cs = Theme.of(context).colorScheme;
    final width = context.isMobile ? 400.0 : (context.isTablet ? 460.0 : 560.0);
    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GlowBadge(icon: Icons.grid_view_rounded, color: cs.primary, size: 48),
        const SizedBox(height: 12),
        Text('Levels', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.textPrimary)),
        const SizedBox(height: 4),
        Text('Progress through challenges', style: TextStyle(fontSize: 13, color: cs.textMuted)),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, dynamic>?>(
          future: ProgressService().getProgress(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(height: 60, child: Center(child: CircularProgressIndicator(color: cs.primary)));
            }
            final completed = <String>{};
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              final levels = (data['levelsCompleted'] as List<dynamic>?) ?? [];
              for (final l in levels) { completed.add(l.toString()); }
            }

            int nextIndex = 0;
            for (int i = 0; i < gameLevels.length; i++) {
              if (!completed.contains(gameLevels[i]['id']!)) { nextIndex = i; break; }
            }

            // Progress bar
            final progressRatio = completed.length / gameLevels.length;

            if (!_showAll) {
              final lvl = gameLevels[nextIndex];
              final id = lvl['id']!;
              final bool isCompleted = completed.contains(id);
              final bool isUnlocked = nextIndex == 0 || completed.contains(gameLevels[nextIndex - 1]['id']);

              return Column(mainAxisSize: MainAxisSize.min, children: [
                // Progress bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.glassBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.glassBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.w700, color: cs.textPrimary, fontSize: 13)),
                          Text('${completed.length}/${gameLevels.length}', style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 6,
                          backgroundColor: cs.glassHighlight,
                          valueColor: AlwaysStoppedAnimation(cs.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Next level card
                _levelCard(lvl, isCompleted: isCompleted, isUnlocked: isUnlocked, isNext: true),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _showAll = true),
                  child: Text('Show all ${gameLevels.length} levels', style: TextStyle(color: cs.primary)),
                ),
              ]);
            }

            return SizedBox(
              height: 360,
              child: ListView.separated(
                itemCount: gameLevels.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final lvl = gameLevels[i];
                  final id = lvl['id']!;
                  final bool isCompleted = completed.contains(id);
                  final bool isUnlocked = i == 0 || completed.contains(gameLevels[i - 1]['id']);
                  return _levelCard(lvl, isCompleted: isCompleted, isUnlocked: isUnlocked, isNext: i == nextIndex);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: PrimaryButton(
              label: 'Back',
              onPressed: () => widget.game.showMainMenu(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SecondaryButton(
              label: _showAll ? 'Show Next' : 'Show All',
              onPressed: () => setState(() => _showAll = !_showAll),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _levelCard(Map<String, String> lvl, {required bool isCompleted, required bool isUnlocked, required bool isNext}) {
    final cs = Theme.of(context).colorScheme;
    final id = lvl['id']!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNext ? cs.primary.withValues(alpha: 0.08) : cs.glassBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNext ? cs.primary.withValues(alpha: 0.3) : cs.glassBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted
                  ? cs.letterCorrect.withValues(alpha: 0.15)
                  : isUnlocked
                      ? cs.primary.withValues(alpha: 0.15)
                      : cs.glassHighlight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : isUnlocked
                      ? Icons.play_circle_outline
                      : Icons.lock_rounded,
              color: isCompleted ? cs.letterCorrect : isUnlocked ? cs.primary : cs.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${lvl['title']}', style: TextStyle(fontWeight: FontWeight.w700, color: cs.textPrimary, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${lvl['category']} \u2022 ${lvl['description'] ?? ''}',
                    style: TextStyle(fontSize: 11, color: cs.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cs.letterCorrect.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Done', style: TextStyle(color: cs.letterCorrect, fontWeight: FontWeight.w700, fontSize: 11)),
            )
          else if (isUnlocked)
            SizedBox(
              height: 34,
              child: FilledButton(
                onPressed: () => widget.game.startGame(lvl['category']!, levelId: id),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Play', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            )
          else
            Text('Locked', style: TextStyle(color: cs.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
