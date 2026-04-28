import 'dart:ui';
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
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final cardWidth = w > 760 ? 760.0 : (w - 24.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14, left: 8, right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: cs.glassBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.glassBorder),
                boxShadow: [
                  BoxShadow(color: cs.shadow.withAlpha(15), blurRadius: 24, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, Icons.home_rounded, 'Home', () {
                    setState(() => _selected = 0);
                    widget.game.showMainMenu();
                  }),
                  _navItem(1, Icons.play_arrow_rounded, 'Play', () {
                    setState(() => _selected = 1);
                    _openPlaySheet(context);
                  }),
                  _navItem(2, Icons.public_rounded, 'Online', () {
                    setState(() => _selected = 2);
                    if (AuthService().isLoggedIn) {
                      widget.game.showScreen('Lobby');
                    } else {
                      widget.game.showScreen('Auth');
                    }
                  }),
                  _navItem(3, Icons.grid_view_rounded, 'Levels', () {
                    setState(() => _selected = 3);
                    widget.game.showScreen('Levels');
                  }),
                  _navItem(4, Icons.auto_awesome, 'Badges', () {
                    setState(() => _selected = 4);
                    widget.game.showScreen('Collectibles');
                  }),
                  _navItem(5, Icons.person_outline_rounded, 'Profile', () {
                    setState(() => _selected = 5);
                    if (isLoggedIn) {
                      widget.game.showScreen('Profile');
                    } else {
                      widget.game.showScreen('Auth');
                    }
                  }),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeService().themeMode,
                    builder: (context, mode, _) {
                      final isDark = mode == ThemeMode.dark ||
                          (mode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
                      return _navItem(6, isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, 'Theme', () {
                        setState(() => _selected = 6);
                        ThemeService().toggle();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    final bool active = _selected == index;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? cs.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 22,
                color: active ? cs.primary : cs.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? cs.primary : cs.textMuted,
              ),
            ),
            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 3),
              width: active ? 4 : 0,
              height: active ? 4 : 0,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                boxShadow: active
                    ? [BoxShadow(color: cs.primaryGlow, blurRadius: 6)]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPlaySheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final keys = categories.keys.toList();
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.glassBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: cs.glassBorder),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: cs.textMuted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Quick Play', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cs.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Pick a category and jump right in', style: TextStyle(fontSize: 13, color: cs.textMuted)),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Random Category',
                        icon: Icons.shuffle_rounded,
                        onPressed: () {
                          Navigator.pop(ctx);
                          widget.game.startGame(categories.keys.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
