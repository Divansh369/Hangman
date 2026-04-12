import 'package:flutter/material.dart';
import '../hangman_game.dart';

class GameOver extends StatelessWidget {
  final HangmanGame game;
  const GameOver({super.key, required this.game});

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
            ValueListenableBuilder<bool>(
              valueListenable: game.winNotifier,
              builder: (context, won, _) {
                return Text(
                  won ? '🎉 YOU WON!' : '☠️ GAME OVER!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: won ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              'The word was: ${game.secretWord.toUpperCase()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (!game.isMultiplayer || game.isHost)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => game.isMultiplayer ? game.restartMultiplayer() : game.startGame(game.currentCategory),
                child: const Text('Play Again'),
              )
            else
              const Text('Waiting for host to restart...', style: TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => game.resetToMenu(),
              child: const Text('Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
