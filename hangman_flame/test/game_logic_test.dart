import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_flame/game/difficulty_level.dart';

void main() {
  group('Game Logic Tests', () {
    group('Word Display Logic', () {
      test('Correctly reveals guessed letters', () {
        const secretWord = 'flutter';
        final guessedLetters = ['f', 'l', 't'];
        
        final revealed = _getRevealedWord(secretWord, guessedLetters);
        expect(revealed, equals('f_ll__'));
      });

      test('Shows all underscores for no guesses', () {
        const secretWord = 'hangman';
        final guessedLetters = <String>[];
        
        final revealed = _getRevealedWord(secretWord, guessedLetters);
        expect(revealed, equals('_______'));
      });

      test('Shows full word when all letters guessed', () {
        const secretWord = 'game';
        final guessedLetters = ['g', 'a', 'm', 'e'];
        
        final revealed = _getRevealedWord(secretWord, guessedLetters);
        expect(revealed, equals('game'));
      });

      test('Handles case-insensitive matching', () {
        const secretWord = 'Flutter';
        final guessedLetters = ['f', 'L', 't'];
        
        final revealed = _getRevealedWord(secretWord, guessedLetters);
        expect(revealed.toLowerCase(), contains('f'));
      });
    });

    group('Scoring Logic', () {
      test('Calculates score correctly for correct guesses', () {
        final correctGuesses = 5;
        final wrongGuesses = 1;
        const baseScore = 20;
        const multiplier = 1.5;

        const expectedScore = 20 + (5 * 5) - (1 * 3);
        final score = _calculateScore(
          correctGuesses,
          wrongGuesses,
          baseScore,
          multiplier,
        );
        expect(score.toInt(), equals(expectedScore));
      });

      test('Applies difficulty multiplier', () {
        final scoreEasy = _calculateScore(10, 2, 20, 1.0);
        final scoreHard = _calculateScore(10, 2, 20, 2.0);
        
        expect(scoreHard, greaterThan(scoreEasy));
      });

      test('Score never goes below zero', () {
        final score = _calculateScore(0, 10, 5, 1.0);
        expect(score, greaterThanOrEqualTo(0));
      });

      test('Scoring increases with more correct guesses', () {
        final score1 = _calculateScore(5, 0, 20, 1.0);
        final score2 = _calculateScore(10, 0, 20, 1.0);
        
        expect(score2, greaterThan(score1));
      });
    });

    group('Game State Logic', () {
      test('Game is won when all letters are guessed correctly', () {
        const secretWord = 'dart';
        final guessedLetters = ['d', 'a', 'r', 't'];
        final revealed = _getRevealedWord(secretWord, guessedLetters);
        
        expect(_isGameWon(revealed, secretWord), isTrue);
      });

      test('Game is not won when letters remain unguessed', () {
        const secretWord = 'dart';
        final guessedLetters = ['d', 'a', 'r'];
        final revealed = _getRevealedWord(secretWord, guessedLetters);
        
        expect(_isGameWon(revealed, secretWord), isFalse);
      });

      test('Game is over when wrong guesses exceed max', () {
        const maxWrongGuesses = 6;
        const wrongGuesses = 7;
        
        expect(_isGameOver(wrongGuesses, maxWrongGuesses), isTrue);
      });

      test('Game continues when wrong guesses within limit', () {
        const maxWrongGuesses = 6;
        const wrongGuesses = 5;
        
        expect(_isGameOver(wrongGuesses, maxWrongGuesses), isFalse);
      });
    });

    group('Letter Validation', () {
      test('Correctly identifies if letter is in word', () {
        const secretWord = 'hangman';
        expect(_isLetterInWord('a', secretWord), isTrue);
        expect(_isLetterInWord('h', secretWord), isTrue);
        expect(_isLetterInWord('z', secretWord), isFalse);
        expect(_isLetterInWord('x', secretWord), isFalse);
      });

      test('Case-insensitive letter checking', () {
        const secretWord = 'Flutter';
        expect(_isLetterInWord('f', secretWord.toLowerCase()), isTrue);
        expect(_isLetterInWord('F', secretWord.toLowerCase()), isTrue);
      });

      test('Validates letter format', () {
        expect(_isValidLetterGuess('a'), isTrue);
        expect(_isValidLetterGuess('z'), isTrue);
        expect(_isValidLetterGuess('1'), isFalse);
        expect(_isValidLetterGuess('ab'), isFalse);
        expect(_isValidLetterGuess(''), isFalse);
      });

      test('Prevents duplicate guesses', () {
        final guessedLetters = ['a', 'b', 'c'];
        expect(_isValidNewGuess('a', guessedLetters), isFalse);
        expect(_isValidNewGuess('d', guessedLetters), isTrue);
      });
    });

    group('Hints Logic', () {
      test('Provides hint for word in theme', () {
        const word = 'flutter';
        const theme = 'Programming';
        final hint = _getHintForWord(word, theme);
        
        expect(hint, isNotNull);
        expect(hint, isNotEmpty);
      });

      test('Returns null for unknown word', () {
        const word = 'unknownword123';
        const theme = 'Programming';
        final hint = _getHintForWord(word, theme);
        
        expect(hint, isNull);
      });

      test('Hint count decreases after usage', () {
        var hintsRemaining = 3;
        expect(hintsRemaining, equals(3));
        
        hintsRemaining = _useHint(hintsRemaining);
        expect(hintsRemaining, equals(2));
      });

      test('Cannot use hint if none remaining', () {
        var hintsRemaining = 0;
        final result = _canUseHint(hintsRemaining);
        
        expect(result, isFalse);
      });
    });

    group('Game Mode Logic', () {
      test('Single player mode initialization', () {
        const mode = 'Classic';
        expect(_isSinglePlayerMode(mode), isTrue);
      });

      test('Multiplayer mode initialization', () {
        const mode = 'Multiplayer';
        expect(_isSinglePlayerMode(mode), isFalse);
      });

      test('Theme challenge mode loaded correctly', () {
        const themeName = 'Programming';
        final wordList = _getThemeWords(themeName);
        
        expect(wordList, isNotEmpty);
        expect(wordList.length, greaterThan(0));
      });
    });

    group('Time Limit Logic', () {
      test('Game should end when time runs out', () {
        const timeRemaining = 0;
        expect(_isTimeExpired(timeRemaining), isTrue);
      });

      test('Game continues when time remaining', () {
        const timeRemaining = 30;
        expect(_isTimeExpired(timeRemaining), isFalse);
      });

      test('Time decreases correctly', () {
        var timeRemaining = 60;
        timeRemaining = _decreaseTime(timeRemaining);
        
        expect(timeRemaining, lessThan(60));
      });
    });

    group('Multiplayer Game Logic', () {
      test('Turn switches correctly between players', () {
        var currentTurnId = 'player1';
        const player2Id = 'player2';
        
        currentTurnId = _switchTurn(currentTurnId, player2Id);
        expect(currentTurnId, equals(player2Id));
      });

      test('Correctly identifies if its player turn', () {
        const currentTurnId = 'player1';
        const playerId = 'player1';
        
        expect(_isPlayerTurn(currentTurnId, playerId), isTrue);
      });

      test('Opponent cannot guess on other player turn', () {
        const currentTurnId = 'player1';
        const opponentId = 'player2';
        
        expect(_isPlayerTurn(currentTurnId, opponentId), isFalse);
      });
    });

    group('Score Multiplier Application', () {
      test('Easy difficulty applies 1.0x multiplier', () {
        final score = (100 * DifficultyLevel.easy.scoreMultiplier).toInt();
        expect(score, equals(100));
      });

      test('Medium difficulty applies 1.5x multiplier', () {
        final score = (100 * DifficultyLevel.medium.scoreMultiplier).toInt();
        expect(score, equals(150));
      });

      test('Hard difficulty applies 2.0x multiplier', () {
        final score = (100 * DifficultyLevel.hard.scoreMultiplier).toInt();
        expect(score, equals(200));
      });
    });
  });
}

// Helper functions for game logic
String _getRevealedWord(String secretWord, List<String> guessedLetters) {
  return secretWord
      .toLowerCase()
      .split('')
      .map((letter) => guessedLetters.contains(letter) ? letter : '_')
      .join('');
}

int _calculateScore(int correct, int wrong, int base, double multiplier) {
  final scoreFromCorrect = base + (correct * 5);
  final penalty = wrong * 3;
  return ((scoreFromCorrect - penalty) * multiplier).toInt();
}

bool _isGameWon(String revealed, String secretWord) {
  return revealed == secretWord.toLowerCase();
}

bool _isGameOver(int wrongGuesses, int maxWrongGuesses) {
  return wrongGuesses >= maxWrongGuesses;
}

bool _isLetterInWord(String letter, String word) {
  return word.toLowerCase().contains(letter.toLowerCase());
}

bool _isValidLetterGuess(String letter) {
  return letter.length == 1 && RegExp(r'^[a-zA-Z]$').hasMatch(letter);
}

bool _isValidNewGuess(String letter, List<String> guessedLetters) {
  return !guessedLetters.contains(letter.toLowerCase());
}

String? _getHintForWord(String word, String theme) {
  // This would typically fetch from the hints map
  // For testing purposes, return a dummy hint
  return 'This word has ${word.length} letters';
}

int _useHint(int hintsRemaining) {
  return hintsRemaining > 0 ? hintsRemaining - 1 : 0;
}

bool _canUseHint(int hintsRemaining) {
  return hintsRemaining > 0;
}

bool _isSinglePlayerMode(String mode) {
  return mode == 'Classic' ||
      mode == 'Speed Run' ||
      mode == 'No Hints' ||
      mode == 'Theme Challenge';
}

List<String> _getThemeWords(String theme) {
  // Mock implementation - would fetch from themes map
  return ['word1', 'word2', 'word3'];
}

bool _isTimeExpired(int timeRemaining) {
  return timeRemaining <= 0;
}

int _decreaseTime(int timeRemaining) {
  return timeRemaining - 1;
}

String _switchTurn(String currentTurnId, String opponentId) {
  return currentTurnId == opponentId ? currentTurnId : opponentId;
}

bool _isPlayerTurn(String currentTurnId, String playerId) {
  return currentTurnId == playerId;
}
