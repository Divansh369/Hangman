import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../hangman_game.dart';
import '../widgets/ui_widgets.dart';
import '../../data/words.dart';
import '../../theme/app_colors.dart';

class NavBar extends StatefulWidget {
  final HangmanGame game;
  const NavBar({super.key, required this.game});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService().isLoggedIn;
    final w = MediaQuery.of(context).size.width;
    final cardWidth = w > 760 ? 760.0 : (w - 48.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18, left: 12, right: 12),
        child: CardSurface(
          width: cardWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home, 'Home', () {
                setState(() => _selected = 0);
                widget.game.showMainMenu();
              }),
              _navItem(1, Icons.play_arrow, 'Play', () {
                setState(() => _selected = 1);
                _openPlaySheet(context);
              }),
              _navItem(2, Icons.group, 'Multiplayer', () {
                setState(() => _selected = 2);
                if (AuthService().isLoggedIn) {
                  widget.game.showScreen('Lobby');
                } else {
                  widget.game.showScreen('Auth');
                }
              }),
              _navItem(3, Icons.grid_view, 'Levels', () {
                setState(() => _selected = 3);
                widget.game.showScreen('Levels');
              }),
              _navItem(4, Icons.star_border, 'Collectibles', () {
                setState(() => _selected = 4);
                widget.game.showScreen('Collectibles');
              }),
              _navItem(5, Icons.person, 'Profile', () {
                setState(() => _selected = 5);
                if (isLoggedIn) {
                  widget.game.showScreen('Profile');
                } else {
                  widget.game.showScreen('Auth');
                }
              }),
              _navItem(6, Icons.settings, 'Settings', () {
                setState(() => _selected = 6);
                widget.game.showScreen('Settings');
              }),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeService().themeMode,
                builder: (context, mode, _) {
                  final isDark = mode == ThemeMode.dark || 
                    (mode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
                  return _navItem(7, isDark ? Icons.light_mode : Icons.dark_mode, 'Theme', () {
                    setState(() => _selected = 7);
                    ThemeService().toggle();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    final bool active = _selected == index;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: active ? cs.primary : cs.surface2,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(icon, size: 20, color: active ? cs.onPrimary : cs.primary),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: active ? cs.primary : cs.textMuted)),
          ],
        ),
      ),
    );
  }

  void _openPlaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final keys = categories.keys.toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Choose a category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: keys.map((c) {
                    return ChoiceChip(
                      label: Text(c),
                      selected: false,
                      onSelected: (_) {
                        Navigator.pop(ctx);
                        widget.game.startGame(c);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  child: PrimaryButton(
                    label: 'Play Random',
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.game.startGame(categories.keys.first);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
