import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../../services/progress_service.dart';
import '../../utils/responsive_utils.dart';
import '../widgets/ui_widgets.dart';

class CollectiblesOverlay extends StatelessWidget {
  final HangmanGame game;
  const CollectiblesOverlay({super.key, required this.game});

  IconData _iconForId(String id) {
    if (id.contains('50')) return Icons.emoji_events;
    if (id.contains('100')) return Icons.stars;
    if (id.contains('200')) return Icons.shield;
    return Icons.star_border;
  }

  String _nameForId(String id) {
    if (id == 'badge_50') return 'Rising Star';
    if (id == 'badge_100') return 'Shining Star';
    if (id == 'badge_200') return 'Champion Shield';
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final width = context.isMobile ? 380.0 : (context.isTablet ? 450.0 : 550.0);
    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 360,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Collectibles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, dynamic>?>(
            future: ProgressService().getProgress(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
              if (!snapshot.hasData || snapshot.data == null) return const Text('You have no collectibles yet.');
              final data = snapshot.data!;
              final collectibles = (data['collectibles'] as List<dynamic>?) ?? [];
              if (collectibles.isEmpty) return const Text('You have no collectibles yet.');

              return Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: GridView.count(
                    key: ValueKey(collectibles.length),
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: collectibles.map<Widget>((c) {
                      final id = c.toString();
                      return GestureDetector(
                        onTap: () {
                          showDialog(context: context, builder: (ctx) {
                            return AlertDialog(
                              title: Text(_nameForId(id)),
                              content: Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_iconForId(id), size: 72, color: Colors.amber),
                                const SizedBox(height: 12),
                                const Text('A special collectible unlocked by reaching milestones.'),
                              ]),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
                              ],
                            );
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).cardColor),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(_iconForId(id), size: 36, color: Colors.amber),
                            const SizedBox(height: 8),
                            Text(_nameForId(id), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Back', onPressed: () {
            game.showMainMenu();
          })
        ]),
      ),
    );
  }
}
