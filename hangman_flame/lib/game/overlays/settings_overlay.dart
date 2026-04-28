import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import '../../utils/responsive_utils.dart';
import '../hangman_game.dart';
import '../widgets/ui_widgets.dart';
import '../../services/sfx_service.dart';
import '../../theme/app_colors.dart';

class SettingsOverlay extends StatelessWidget {
  final HangmanGame game;
  const SettingsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = context.isMobile ? 380.0 : (context.isTablet ? 440.0 : 500.0);
    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GlowBadge(icon: Icons.settings_rounded, color: cs.primary, size: 48),
        const SizedBox(height: 12),
        Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.textPrimary)),
        const SizedBox(height: 4),
        Text('Customize your experience', style: TextStyle(fontSize: 13, color: cs.textMuted)),
        const SizedBox(height: 20),

        // Theme mode
        _settingsCard(
          context,
          icon: Icons.palette_outlined,
          title: 'Appearance',
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService().themeMode,
            builder: (context, mode, _) {
              return SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Auto'), icon: Icon(Icons.brightness_auto, size: 16)),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode, size: 16)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode, size: 16)),
                ],
                selected: {mode},
                onSelectionChanged: (s) => ThemeService().setThemeMode(s.first),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Accent color
        _settingsCard(
          context,
          icon: Icons.color_lens_outlined,
          title: 'Accent Color',
          child: ValueListenableBuilder<Color>(
            valueListenable: ThemeService().accentColor,
            builder: (context, selectedAccent, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ThemeService.accentPalette.map((color) {
                  final isSelected = selectedAccent.toARGB32() == color.toARGB32();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => ThemeService().setAccentColor(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 40 : 34,
                        height: isSelected ? 40 : 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? cs.onSurface : Colors.transparent,
                            width: isSelected ? 2.5 : 0,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: -2)]
                              : [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Sound
        _settingsCard(
          context,
          icon: Icons.volume_up_outlined,
          title: 'Sound Effects',
          child: ValueListenableBuilder<bool>(
            valueListenable: SfxService().enabled,
            builder: (context, enabled, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(enabled ? 'Enabled' : 'Disabled', style: TextStyle(color: cs.textMuted)),
                  Switch(
                    value: enabled,
                    onChanged: (v) => SfxService().setEnabled(v),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Done',
          icon: Icons.check_rounded,
          onPressed: () => game.showMainMenu(),
        ),
      ]),
    );
  }

  Widget _settingsCard(BuildContext context, {required IconData icon, required String title, required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: cs.textPrimary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
