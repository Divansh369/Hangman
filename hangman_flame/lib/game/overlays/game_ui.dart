import 'package:flutter/material.dart';
import '../hangman_game.dart';
import '../../services/auth_service.dart';
import 'chat_overlay.dart';

class GameUI extends StatefulWidget {
  final HangmanGame game;
  const GameUI({super.key, required this.game});

  @override
  State<GameUI> createState() => _GameUIState();
}

class _GameUIState extends State<GameUI> {
  final TextEditingController _wordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.game.isWaitingForWordNotifier,
            builder: (context, isWaiting, _) {
              if (isWaiting) {
                return _buildWordEntryScreen();
              }
              return _buildGameScreen();
            },
          ),
        ),
        if (widget.game.isMultiplayer)
          ChatOverlay(game: widget.game),
      ],
    );
  }

  Widget _buildWordEntryScreen() {
    bool isMyTurnToSet = widget.game.currentTurnId == AuthService().currentUser?.id;

    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMyTurnToSet ? 'SET THE SECRET WORD' : 'WAITING FOR WORD...',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Rules: Only A-Z letters allowed.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            if (isMyTurnToSet) ...[
              TextField(
                controller: _wordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Secret Word', hintText: 'Enter word for opponent'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_wordController.text.isNotEmpty) {
                    widget.game.setMultiplayerWord(_wordController.text);
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Confirm Word'),
              ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Spacer(),
        ValueListenableBuilder<String>(
          valueListenable: widget.game.wordNotifier,
          builder: (context, word, _) {
            return Text(
              word,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
            );
          },
        ),
        const SizedBox(height: 10),
        if (widget.game.isMultiplayer)
          Text(
            widget.game.currentTurnId == AuthService().currentUser?.id ? "YOUR TURN" : "OPPONENT'S TURN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.game.currentTurnId == AuthService().currentUser?.id ? Colors.green : Colors.grey,
            ),
          ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ValueListenableBuilder<List<String>>(
            valueListenable: widget.game.guessedLettersNotifier,
            builder: (context, guessedLetters, _) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: 'abcdefghijklmnopqrstuvwxyz'.split('').map((letter) {
                  final bool isGuessed = guessedLetters.contains(letter);
                  bool isMyTurn = !widget.game.isMultiplayer || 
                                 (widget.game.currentTurnId == AuthService().currentUser?.id);

                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: isGuessed ? Colors.grey : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (isGuessed || !isMyTurn) ? null : () => widget.game.makeGuess(letter),
                      child: Text(letter.toUpperCase()),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
