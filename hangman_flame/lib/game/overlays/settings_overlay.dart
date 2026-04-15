import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import '../../utils/responsive_utils.dart';
import '../hangman_game.dart';
import '../widgets/ui_widgets.dart';
import '../../services/sfx_service.dart';

class SettingsOverlay extends StatelessWidget {
  final HangmanGame game;
  const SettingsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final width = context.isMobile ? 360.0 : (context.isTablet ? 420.0 : 480.0);
    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService().themeMode,
          builder: (context, mode, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: Column(key: ValueKey(mode), children: [
                ListTile(
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: mode,
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (v) => ThemeService().setThemeMode(v ?? ThemeMode.system),
                  ),
                ),
              ]),
            );
          },
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<Color>(
          valueListenable: ThemeService().accentColor,
          builder: (context, selectedAccent, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Accent Color', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ThemeService.accentPalette.map((color) {
                    final isSelected = selectedAccent.toARGB32() == color.toARGB32();
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => ThemeService().setAccentColor(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: isSelected ? 38 : 34,
                        height: isSelected ? 38 : 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<bool>(
          valueListenable: SfxService().enabled,
          builder: (context, enabled, _) {
            return SwitchListTile(
              title: const Text('Sound Effects'),
              value: enabled,
              onChanged: (v) => SfxService().setEnabled(v),
            );
          },
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Done',
          onPressed: () {
            game.showMainMenu();
          },
        ),
      ]),
    );
  }
}
