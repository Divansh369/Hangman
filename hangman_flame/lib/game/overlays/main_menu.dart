import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../../data/words.dart';
import '../../services/auth_service.dart';
import '../widgets/ui_widgets.dart';
import '../../theme/app_colors.dart';

class MainMenu extends StatefulWidget {
  final HangmanGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String selectedCategory = categories.keys.first;
  String mode = '1-Player';
  final TextEditingController _customWordController = TextEditingController();

  @override
  void dispose() {
    _customWordController.dispose();
    super.dispose();
  }

  void _showLeaderboard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leaderboard'),
        content: const Text('Leaderboard coming soon.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  void _onStartPressed() {
    if (mode == '1-Player') {
      widget.game.startGame(selectedCategory);
    } else if (mode == '2-Player') {
      if (_customWordController.text.isNotEmpty) {
        widget.game.startGame('Custom', customWord: _customWordController.text.toLowerCase());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a secret word')));
      }
    } else if (mode == 'Multiplayer') {
      if (AuthService().isLoggedIn) {
        widget.game.showScreen('Lobby');
      } else {
        widget.game.showScreen('Auth');
      }
    }
  }

  Widget _buildModeSelector() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: mode,
          isExpanded: true,
          items: ['1-Player', '2-Player', 'Multiplayer'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (val) => setState(() => mode = val!),
        ),
      ),
    );
  }

  Widget _buildContextInputs() {
    final cs = Theme.of(context).colorScheme;
    if (mode == '1-Player') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.textMuted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cs.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categories.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
            ),
          ),
        ],
      );
    } else if (mode == '2-Player') {
      return TextField(
        controller: _customWordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Secret Word',
          hintText: 'Enter word for Player 2',
          filled: true,
          fillColor: cs.surface2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );
    } else {
      return Text(
        'Challenge players around the world!',
        textAlign: TextAlign.center,
        style: TextStyle(color: cs.textMuted),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final cs = Theme.of(context).colorScheme;

    return OverlayScaffold(
      width: 380,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: user info (left) and action icons (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              user != null
                  ? Row(children: [
                      CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Text((user.getStringValue('username').isNotEmpty) ? user.getStringValue('username')[0].toUpperCase() : '?'),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user.getStringValue('username'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${user.getIntValue('score')} Points', style: TextStyle(color: cs.textMuted, fontSize: 12)),
                      ]),
                    ])
                  : const SizedBox(),
              Row(children: [
                IconButton(
                  icon: Icon(Icons.person, size: 20, color: cs.textMuted),
                  onPressed: () {
                    if (user != null) {
                      widget.game.showScreen('Profile');
                    } else {
                      widget.game.showScreen('Auth');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings, size: 20, color: cs.textMuted),
                  onPressed: () {
                    widget.game.showScreen('Settings');
                  },
                ),
              ])
            ],
          ),
          const Divider(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.surface2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🪓 HANGMAN',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Choose your mode and start playing', style: TextStyle(color: cs.textMuted)),
              ],
            ),
          ),
          Text(
            mode,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.primary),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'PLAY 1 PLAYER',
            height: 56,
            onPressed: () {
              widget.game.showScreen('Levels');
            },
          ),
          const SizedBox(height: 12),
          _buildModeSelector(),
          const SizedBox(height: 12),
          _buildContextInputs(),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'START GAME',
            onPressed: _onStartPressed,
            height: 56,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _showLeaderboard,
            icon: const Icon(Icons.emoji_events),
            label: const Text('LEADERBOARD'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    widget.game.showScreen('Levels');
                  },
                  icon: const Icon(Icons.grid_view),
                  label: const Text('LEVELS'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    widget.game.showScreen('Collectibles');
                  },
                  icon: const Icon(Icons.star_border),
                  label: const Text('COLLECTIBLES'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
