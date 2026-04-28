import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../../services/progress_service.dart';
import '../../utils/responsive_utils.dart';
import '../widgets/ui_widgets.dart';
import '../../theme/app_colors.dart';

class CollectiblesOverlay extends StatelessWidget {
  final HangmanGame game;
  const CollectiblesOverlay({super.key, required this.game});

  IconData _iconForId(String id) {
    if (id.contains('50')) return Icons.emoji_events;
    if (id.contains('100')) return Icons.auto_awesome;
    if (id.contains('200')) return Icons.shield;
    return Icons.star_border;
  }

  String _nameForId(String id) {
    if (id == 'badge_50') return 'Rising Star';
    if (id == 'badge_100') return 'Shining Star';
    if (id == 'badge_200') return 'Champion Shield';
    return id;
  }

  Color _colorForId(String id) {
    if (id.contains('50')) return Colors.amber;
    if (id.contains('100')) return Colors.purple;
    if (id.contains('200')) return Colors.cyan;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = context.isMobile ? 400.0 : (context.isTablet ? 460.0 : 560.0);
    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 400,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          GlowBadge(icon: Icons.auto_awesome, color: Colors.amber, size: 48),
          const SizedBox(height: 12),
          Text('Collectibles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.textPrimary)),
          const SizedBox(height: 4),
          Text('Achievements unlocked by reaching milestones', style: TextStyle(fontSize: 13, color: cs.textMuted)),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, dynamic>?>(
            future: ProgressService().getProgress(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(height: 60, child: Center(child: CircularProgressIndicator(color: cs.primary)));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return _emptyState(cs);
              }
              final data = snapshot.data!;
              final collectibles = (data['collectibles'] as List<dynamic>?) ?? [];
              if (collectibles.isEmpty) return _emptyState(cs);

              return Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: collectibles.map<Widget>((c) {
                    final id = c.toString();
                    final color = _colorForId(id);
                    return GestureDetector(
                      onTap: () => _showBadgeDetail(context, id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.glassBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12, spreadRadius: -4)],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.15),
                              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12)],
                            ),
                            child: Icon(_iconForId(id), size: 24, color: color),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _nameForId(id),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.textPrimary),
                          ),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Back', onPressed: () => game.showMainMenu()),
        ]),
      ),
    );
  }

  Widget _emptyState(ColorScheme cs) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: cs.textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No collectibles yet', style: TextStyle(fontWeight: FontWeight.w700, color: cs.textMuted)),
            const SizedBox(height: 4),
            Text('Play multiplayer and reach score milestones!', style: TextStyle(fontSize: 12, color: cs.textMuted.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, String id) {
    final cs = Theme.of(context).colorScheme;
    final color = _colorForId(id);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 24)],
              ),
              child: Icon(_iconForId(id), size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(_nameForId(id), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cs.textPrimary)),
            const SizedBox(height: 8),
            Text('Unlocked by reaching score milestones in multiplayer.',
                textAlign: TextAlign.center, style: TextStyle(color: cs.textMuted, fontSize: 13)),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
        );
      },
    );
  }
}
