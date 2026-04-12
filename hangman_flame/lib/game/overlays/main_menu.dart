import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../../data/words.dart';
import '../../services/auth_service.dart';

class MainMenu extends StatefulWidget {
  final HangmanGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String selectedCategory = 'Animals';
  String mode = '1-Player';
  final TextEditingController _customWordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🪓 Hangman Game',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: mode,
              isExpanded: true,
              items: ['1-Player', '2-Player', 'Multiplayer'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  mode = val!;
                });
              },
            ),
            const SizedBox(height: 10),
            if (mode == '1-Player') ...[
              const Text('Choose Category:'),
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categories.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val!;
                  });
                },
              ),
            ] else if (mode == '2-Player') ...[
              TextField(
                controller: _customWordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Secret Word',
                  hintText: 'Player 1: Enter word',
                ),
              ),
            ] else if (mode == 'Multiplayer') ...[
              const Text('Play with others online!'),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (mode == '1-Player') {
                  widget.game.startGame(selectedCategory);
                } else if (mode == '2-Player') {
                  if (_customWordController.text.isNotEmpty) {
                    widget.game.startGame('Custom', customWord: _customWordController.text.toLowerCase());
                  }
                } else if (mode == 'Multiplayer') {
                  if (AuthService().isLoggedIn) {
                    widget.game.overlays.add('Lobby');
                    widget.game.overlays.remove('MainMenu');
                  } else {
                    widget.game.overlays.add('Auth');
                    widget.game.overlays.remove('MainMenu');
                  }
                }
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
