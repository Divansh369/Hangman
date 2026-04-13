import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../hangman_game.dart';
import '../widgets/ui_widgets.dart';

class ProfileOverlay extends StatelessWidget {
  final HangmanGame game;
  const ProfileOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return OverlayScaffold(
      width: 360,
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (user != null) ...[
          Builder(builder: (ctx) {
            final uname = user.getStringValue('username');
            final initial = uname.isNotEmpty ? uname[0].toUpperCase() : '?';
            return Column(children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.blue[100], child: Text(initial)),
              const SizedBox(height: 8),
              Text(uname.isNotEmpty ? uname : 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]);
          }),
          const SizedBox(height: 8),
          Text('${user.getIntValue('score')} Points', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, dynamic>?>(
            future: ProgressService().getProgress(),
            builder: (context, snapshot) {
              Widget content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
              } else if (!snapshot.hasData || snapshot.data == null) {
                content = Column(children: [
                  const Text('No progress yet.'),
                  const SizedBox(height: 8),
                  PrimaryButton(label: 'Initialize Progress', onPressed: () async {
                    final rec = await ProgressService().getOrCreateProgressRecord();
                    if (!context.mounted) {
                      return;
                    }
                    if (rec != null) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress created')));
                  }),
                ]);
              } else {
                final data = snapshot.data!;
                final levels = (data['levelsCompleted'] as List<dynamic>?) ?? [];
                final collectibles = (data['collectibles'] as List<dynamic>?) ?? [];
                final currency = (data['currency'] as int?) ?? 0;

                content = Column(children: [
                  Text('Levels completed: ${levels.length}'),
                  Text('Collectibles: ${collectibles.length}'),
                  Text('Currency: $currency'),
                  const SizedBox(height: 8),
                  PrimaryButton(label: 'Sync Progress', onPressed: () async {
                    await ProgressService().getOrCreateProgressRecord();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress synced')));
                  }),
                ]);
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: content),
              );
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Logout', onPressed: () {
            AuthService().logout();
            game.showMainMenu();
          })
        ] else ...[
          const Text('Not signed in'),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Sign in', onPressed: () {
            game.showScreen('Auth');
          })
        ],
        const SizedBox(height: 8),
        TextButton(onPressed: () {
          game.showMainMenu();
        }, child: const Text('Back'))
      ]),
    );
  }
}
