import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';
import '../hangman_game.dart';
import '../widgets/ui_widgets.dart';

class ProfileOverlay extends StatelessWidget {
  final HangmanGame game;
  const ProfileOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final cs = Theme.of(context).colorScheme;
    final width = context.isMobile ? 380.0 : (context.isTablet ? 440.0 : 500.0);

    return OverlayScaffold(
      width: width,
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GlowBadge(icon: Icons.person_outline, color: cs.primary, size: 48),
        const SizedBox(height: 12),
        Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.textPrimary)),
        const SizedBox(height: 16),
        if (user != null) ...[
          Builder(builder: (ctx) {
            final uname = user.getStringValue('username');
            final initial = uname.isNotEmpty ? uname[0].toUpperCase() : '?';
            return Column(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: cs.primaryGradient),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: cs.primaryGlow, blurRadius: 16)],
                ),
                child: Center(
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28)),
                ),
              ),
              const SizedBox(height: 12),
              Text(uname.isNotEmpty ? uname : 'Unknown', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: cs.textPrimary)),
            ]);
          }),
          const SizedBox(height: 8),
          StatPill(label: 'Score', value: '${user.getIntValue('score')}', icon: Icons.star),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>?>(
            future: ProgressService().getProgress(),
            builder: (context, snapshot) {
              Widget content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = SizedBox(height: 48, child: Center(child: CircularProgressIndicator(color: cs.primary)));
              } else if (!snapshot.hasData || snapshot.data == null) {
                content = Column(children: [
                  Text('No progress yet.', style: TextStyle(color: cs.textMuted)),
                  const SizedBox(height: 12),
                  PrimaryButton(label: 'Initialize Progress', icon: Icons.add_circle_outline, onPressed: () async {
                    final rec = await ProgressService().getOrCreateProgressRecord();
                    if (!context.mounted) return;
                    if (rec != null) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress created')));
                  }),
                ]);
              } else {
                final data = snapshot.data!;
                final levels = (data['levelsCompleted'] as List<dynamic>?) ?? [];
                final collectibles = (data['collectibles'] as List<dynamic>?) ?? [];
                final currency = (data['currency'] as int?) ?? 0;

                content = Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.glassBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.glassBorder),
                  ),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _miniStat(cs, Icons.grid_view_rounded, '${levels.length}', 'Levels'),
                        _miniStat(cs, Icons.auto_awesome, '${collectibles.length}', 'Badges'),
                        _miniStat(cs, Icons.monetization_on_outlined, '$currency', 'Currency'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SecondaryButton(label: 'Sync Progress', onPressed: () async {
                      await ProgressService().getOrCreateProgressRecord();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress synced')));
                    }),
                  ]),
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: content),
              );
            },
          ),
          const SizedBox(height: 14),
          DangerButton(label: 'Logout', onPressed: () {
            AuthService().logout();
            game.showMainMenu();
          }),
        ] else ...[
          Icon(Icons.lock_person_rounded, size: 48, color: cs.textMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('Not signed in', style: TextStyle(color: cs.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Sign In', icon: Icons.login_rounded, onPressed: () => game.showScreen('Auth')),
        ],
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => game.showMainMenu(),
          child: Text('Back', style: TextStyle(color: cs.textMuted)),
        ),
      ]),
    );
  }

  Widget _miniStat(ColorScheme cs, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: cs.primary),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: cs.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: cs.textMuted)),
      ],
    );
  }
}
