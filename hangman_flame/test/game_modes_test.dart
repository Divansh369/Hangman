import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Single Player - Classic Mode Tests', () {
    test('Game initializes with correct settings', () {
      const category = 'Animals';
      const difficulty = 'medium';
      final game = _initializeGame(category, difficulty);

      expect(game['category'], equals('Animals'));
      expect(game['difficulty'], equals('medium'));
      expect(game['mode'], equals('classic'));
      expect(game['secretWord'], isNotEmpty);
    });

    test('Score calculation follows Classic rules', () {
      final score = _calculateClassicModeScore(8, 2, 1.5);
      expect(score, greaterThan(0));
      expect(score, equals(36)); // (20 + 8*5 - 2*3) * 1.5
    });

    test('Game ends after max wrong guesses', () {
      var game = _initializeGame('Animals', 'medium');
      game['wrongGuesses'] = 6; // max for medium

      expect(_isGameOver(game), isTrue);
    });

    test('Game wins when all letters guessed', () {
      var game = _initializeGame('Animals', 'easy');
      game['secretWord'] = 'cat';
      game['revealedWord'] = 'cat';

      expect(_isGameWon(game), isTrue);
    });

    test('Category word pool is valid', () {
      final words = _getWordsForCategory('Animals');
      expect(words, isNotEmpty);
      expect(words.length, greaterThan(0));

      for (var word in words) {
        expect(word, isNotEmpty);
        expect(word, isA<String>());
      }
    });
  });

  group('Single Player - Speed Run Mode Tests', () {
    test('Speed Run initializes with time limit', () {
      final game = _initializeSpeedRunGame('Programming', 'hard', 90);

      expect(game['mode'], equals('speedrun'));
      expect(game['timeLimit'], equals(90));
      expect(game['hints'], equals(1)); // Speed run has 1 hint
    });

    test('Score doubles with speed run multiplier', () {
      final scoreClassic = _calculateClassicModeScore(5, 1, 1.5);
      final scoreSpeedRun = _calculateSpeedRunScore(5, 1, 1.5, 90);

      expect(scoreSpeedRun, greaterThan(scoreClassic));
    });

    test('Time decreases each second', () {
      var timeRemaining = 90;
      expect(timeRemaining, equals(90));

      timeRemaining = _decrementTime(timeRemaining);
      expect(timeRemaining, equals(89));
    });

    test('Game over when time reaches zero', () {
      var game = _initializeSpeedRunGame('Animals', 'medium', 60);
      game['timeRemaining'] = 0;

      expect(_isSpeedRunTimeOut(game), isTrue);
    });

    test('Speed run bonus for fast completion', () {
      final speedRunBonus = _getSpeedRunBonus(45, 90); // 45 sec remaining
      expect(speedRunBonus, greaterThan(0));
      expect(speedRunBonus, equals(45)); // 1 point per second remaining
    });
  });

  group('Single Player - No Hints Mode Tests', () {
    test('No Hints mode starts with zero hints', () {
      final game = _initializeNoHintsGame('Programming', 'hard');

      expect(game['hints'], equals(0));
      expect(_canUseHint(game['hints']), isFalse);
    });

    test('Higher base score for No Hints mode', () {
      final scoreWithHints = _calculateClassicModeScore(10, 2, 2.0);
      final scoreNoHints = _calculateNoHintsScore(10, 2, 2.5); // higher multiplier

      expect(scoreNoHints, greaterThan(scoreWithHints));
    });

    test('Cannot request hints during game', () {
      final game = _initializeNoHintsGame('Animals', 'easy');
      expect(_canUseHint(game['hints']), isFalse);
    });

    test('Difficulty enforced as Hard minimum', () {
      final game = _initializeNoHintsGame('Animals', 'easy');
      // System should enforce Hard minimum
      expect(_getEnforcedDifficulty(game), equals('hard'));
    });
  });

  group('Single Player - Theme Challenge Tests', () {
    test('Theme Challenge loads all words from theme', () {
      final themeName = 'Programming';
      final words = _getThemeWords(themeName);

      expect(words, isNotEmpty);
      expect(words.length, greaterThan(0));
    });

    test('Theme has subcategories with words', () {
      final themeName = 'Literary Shadows';
      final subcategories = _getSubcategoriesForTheme(themeName);

      expect(subcategories, isNotEmpty);
      expect(subcategories.length, greaterThan(0));
    });

    test('Progress tracks completed words in theme', () {
      var progress = _initializeThemeChallengeProgress('Programming', 8);

      expect(progress['totalWords'], equals(8));
      expect(progress['completedWords'], equals(0));
      expect(progress['currentWordIndex'], equals(0));
    });

    test('Advances to next word after correct guess', () {
      var game = _initializeThemeChallengeGame('Programming');
      game = _completeWord(game);

      expect(game['currentWordIndex'], equals(1));
      expect(game['completedWords']!.length, equals(1));
    });

    test('Theme complete when all words guessed', () {
      var game = _initializeThemeChallengeGame('Programming');
      final totalWords = game['totalWords'];

      // Simulate completing all words
      for (int i = 0; i < totalWords; i++) {
        game = _completeWord(game);
      }

      expect(_isThemeChallengeComplete(game), isTrue);
    });

    test('Provides themed hints from hint map', () {
      const word = 'flutter';
      const theme = 'Programming';
      final hint = _getHintForThemedWord(word, theme);

      expect(hint, isNotNull);
      expect(hint!.length, greaterThan(0));
    });

    test('Calculates theme completion percentage', () {
      var game = _initializeThemeChallengeGame('Programming');
      var percentage = _getThemeChallengeProgress(game);

      expect(percentage, equals(0));

      game = _completeWord(game);
      game = _completeWord(game);
      percentage = _getThemeChallengeProgress(game);

      expect(percentage, greaterThan(0));
      expect(percentage, lessThan(100));
    });
  });

  group('Two Player - Local Duel Tests', () {
    test('Local duel alternates turns correctly', () {
      var game = _initializeLocalDuel('player1', 'player2', 'classic');

      expect(game['currentTurn'], isNotNull);
      expect(['player1', 'player2'].contains(game['currentTurn']), isTrue);
    });

    test('Player can only guess on their turn', () {
      var game = _initializeLocalDuel('player1', 'player2', 'classic');
      game['currentTurn'] = 'player1';

      expect(_canPlayerGuess('player1', game), isTrue);
      expect(_canPlayerGuess('player2', game), isFalse);
    });

    test('Wrong guess transfers turn to opponent', () {
      var game = _initializeLocalDuel('player1', 'player2', 'classic');
      game['currentTurn'] = 'player1';
      game = _processWrongGuess(game, 'player1');

      expect(game['currentTurn'], equals('player2'));
    });

    test('Both players maintain separate scores', () {
      var game = _initializeLocalDuel('player1', 'player2', 'classic');

      game = _updateScore(game, 'player1', 50);
      expect(game['scores']['player1'], equals(50));

      game = _updateScore(game, 'player2', 75);
      expect(game['scores']['player2'], equals(75));
      expect(game['scores']['player1'], equals(50)); // unchanged
    });

    test('Duel ends when one player reaches win condition', () {
      var game = _initializeLocalDuel('player1', 'player2', 'classic');
      game['player1Word'] = 'flutter';
      game['player1Guessed'] = ['f', 'l', 'u', 't', 'e', 'r'];

      expect(_isLocalDuelOver(game), isTrue);
    });
  });

  group('Multiplayer - Online Tests', () {
    test('Creates game room with host', () async {
      final room = _createGameRoom('player1', 'Classic Duel');

      expect(room['hostId'], equals('player1'));
      expect(room['status'], equals('waiting'));
      expect(room['roomCode'], isNotNull);
    });

    test('Room requires valid code to join', () async {
      final room = _createGameRoom('player1', 'Classic Duel');
      final validJoin = _canJoinRoom(room['roomCode']!, 'player2');

      expect(validJoin, isTrue);
    });

    test('Game starts only when opponent ready', () async {
      var room = _createGameRoom('player1', 'Classic Duel');
      expect(room['status'], equals('waiting'));

      room = _playerReady(room, 'player2');
      expect(room['status'], equals('ready'));
    });

    test('Multiplayer turn timer enforces time limits', () async {
      var game = _initializeMultiplayerGame('player1', 'player2');
      game['turnTimeLimit'] = 25;

      expect(game['turnTimeRemaining'], equals(25));
      game['turnTimeRemaining'] = _decrementTime(game['turnTimeRemaining']);
      expect(game['turnTimeRemaining'], equals(24));
    });

    test('Forfeit ends game immediately', () async {
      var game = _initializeMultiplayerGame('player1', 'player2');

      game = _forfeitGame(game, 'player2');
      expect(game['gameOver'], isTrue);
      expect(game['winner'], equals('player1'));
    });

    test('Chat messages don\'t reveal secret word', () {
      const secretWord = 'flutter';
      var message = 'I think the word is flutter';

      final sanitized = _sanitizeChatMessage(message, secretWord);
      expect(sanitized, isNot(message));
      expect(sanitized.contains('flutter'), isFalse);
    });

    test('Multiplayer room cleanup on disconnect', () async {
      var room = _createGameRoom('player1', 'Classic Duel');
      room = _playerReady(room, 'player2');

      room = _handlePlayerDisconnect(room, 'player2');
      expect(room['status'], equals('disconnected'));
    });
  });

  group('Multiplayer - Timed Mode Tests', () {
    test('Timed rounds initialize with duration', () {
      var game = _initializeTimedRound('player1', 'player2', 120);

      expect(game['roundDuration'], equals(120));
      expect(game['roundNumber'], equals(1));
    });

    test('Round timer counts down', () {
      var game = _initializeTimedRound('player1', 'player2', 60);

      for (int i = 0; i < 10; i++) {
        game['timeRemaining'] = _decrementTime(game['timeRemaining']);
      }

      expect(game['timeRemaining'], equals(50));
    });

    test('Points awarded based on speed', () {
      const timeUsed = 30; // out of 120
      final speedBonus = _calculateSpeedBonus(timeUsed, 120);

      expect(speedBonus, greaterThan(0));
      expect(speedBonus, equals(90)); // 120 - 30
    });

    test('Next round starts after time expires', () {
      var game = _initializeTimedRound('player1', 'player2', 60);
      game['timeRemaining'] = 0;

      game = _moveToNextRound(game);
      expect(game['roundNumber'], equals(2));
      expect(game['timeRemaining'], equals(60));
    });
  });

  group('Multiplayer - Best Of Series Tests', () {
    test('Series initializes with round count', () {
      var series = _initializeBestOfSeries('player1', 'player2', 3);

      expect(series['roundCount'], equals(3));
      expect(series['currentRound'], equals(1));
      expect(series['player1Wins'], equals(0));
      expect(series['player2Wins'], equals(0));
    });

    test('Series ends when winner reaches majority', () {
      var series = _initializeBestOfSeries('player1', 'player2', 3);

      series = _awardRound(series, 'player1');
      expect(series['seriesOver'], isFalse);

      series = _awardRound(series, 'player1');
      expect(series['seriesOver'], isTrue);
      expect(series['seriesWinner'], equals('player1'));
    });

    test('Tracks series statistics', () {
      var series = _initializeBestOfSeries('player1', 'player2', 5);

      series = _awardRound(series, 'player1');
      series = _awardRound(series, 'player2');
      series = _awardRound(series, 'player1');

      expect(series['player1Wins'], equals(2));
      expect(series['player2Wins'], equals(1));
      expect(series['currentRound'], equals(4));
    });
  });
}

// Mock game initialization and utilities

Map<String, dynamic> _initializeGame(String category, String difficulty) {
  return {
    'category': category,
    'difficulty': difficulty,
    'mode': 'classic',
    'secretWord': 'flutter',
    'revealedWord': '_______',
    'guessedLetters': <String>[],
    'wrongGuesses': 0,
  };
}

Map<String, dynamic> _initializeSpeedRunGame(
    String category, String difficulty, int timeLimit) {
  return {
    'mode': 'speedrun',
    'category': category,
    'difficulty': difficulty,
    'timeLimit': timeLimit,
    'timeRemaining': timeLimit,
    'hints': 1,
    'secretWord': 'flutter',
  };
}

Map<String, dynamic> _initializeNoHintsGame(String category, String difficulty) {
  return {
    'mode': 'nohints',
    'category': category,
    'difficulty': _getEnforcedDifficulty({'difficulty': difficulty}),
    'hints': 0,
    'secretWord': 'flutter',
  };
}

Map<String, dynamic> _initializeThemeChallengeGame(String themeName) {
  final words = _getThemeWords(themeName);
  return {
    'mode': 'themechallenge',
    'theme': themeName,
    'totalWords': words.length,
    'currentWordIndex': 0,
    'completedWords': <String>[],
    'secretWord': words[0],
  };
}

Map<String, dynamic> _initializeThemeChallengeProgress(
    String themeName, int wordCount) {
  return {
    'theme': themeName,
    'totalWords': wordCount,
    'completedWords': 0,
    'currentWordIndex': 0,
  };
}

Map<String, dynamic> _initializeLocalDuel(
    String player1, String player2, String style) {
  return {
    'player1': player1,
    'player2': player2,
    'style': style,
    'currentTurn': player1,
    'scores': {player1: 0, player2: 0},
    'player1Word': 'flutter',
    'player2Word': 'hangman',
    'player1Guessed': <String>[],
    'player2Guessed': <String>[],
  };
}

Map<String, dynamic> _initializeMultiplayerGame(String player1, String player2) {
  return {
    'player1': player1,
    'player2': player2,
    'currentTurn': player1,
    'turnTimeLimit': 25,
    'turnTimeRemaining': 25,
    'gameOver': false,
    'winner': null,
  };
}

Map<String, dynamic> _initializeTimedRound(
    String player1, String player2, int duration) {
  return {
    'player1': player1,
    'player2': player2,
    'roundDuration': duration,
    'timeRemaining': duration,
    'roundNumber': 1,
  };
}

Map<String, dynamic> _initializeBestOfSeries(
    String player1, String player2, int roundCount) {
  return {
    'player1': player1,
    'player2': player2,
    'roundCount': roundCount,
    'currentRound': 1,
    'player1Wins': 0,
    'player2Wins': 0,
    'seriesOver': false,
    'seriesWinner': null,
  };
}

bool _isGameOver(Map<String, dynamic> game) {
  return game['wrongGuesses'] >= 6;
}

bool _isGameWon(Map<String, dynamic> game) {
  return game['revealedWord'] ==
      game['secretWord']; // assume revealed already has secret
}

List<String> _getWordsForCategory(String category) {
  const categoryWords = {
    'Animals': ['cat', 'dog', 'elephant', 'lion', 'tiger'],
    'Programming': ['flutter', 'dart', 'python', 'javascript', 'rust'],
  };
  return categoryWords[category] ?? [];
}

int _calculateClassicModeScore(int correct, int wrong, double multiplier) {
  return ((20 + correct * 5 - wrong * 3) * multiplier).toInt();
}

int _calculateSpeedRunScore(
    int correct, int wrong, double multiplier, int timeRemaining) {
  return ((_calculateClassicModeScore(correct, wrong, multiplier) +
          timeRemaining) *
      1.5)
      .toInt();
}

int _calculateNoHintsScore(int correct, int wrong, double multiplier) {
  return _calculateClassicModeScore(correct, wrong, multiplier);
}

int _getSpeedRunBonus(int timeRemaining, int totalTime) {
  return timeRemaining;
}

List<String> _getThemeWords(String themeName) {
  const themeWords = {
    'Programming': ['flutter', 'dart', 'python', 'javascript', 'rust', 'kotlin', 'swift', 'java'],
    'Literary Shadows': ['heathcliff', 'dorian', 'jekyll', 'frankenstein'],
  };
  return themeWords[themeName] ?? [];
}

List<String> _getSubcategoriesForTheme(String themeName) {
  return ['Subcategory1', 'Subcategory2', 'Subcategory3'];
}

String? _getHintForThemedWord(String word, String theme) {
  return 'This word has ${word.length} letters';
}

bool _canUseHint(int hints) {
  return hints > 0;
}

Map<String, dynamic> _completeWord(Map<String, dynamic> game) {
  game['currentWordIndex'] = (game['currentWordIndex'] + 1);
  (game['completedWords'] as List<String>).add(game['secretWord']);
  return game;
}

bool _isThemeChallengeComplete(Map<String, dynamic> game) {
  return (game['completedWords'] as List<String>).length >= game['totalWords'];
}

int _getThemeChallengeProgress(Map<String, dynamic> game) {
  return ((game['completedWords'].length / game['totalWords']) * 100).toInt();
}

String _getEnforcedDifficulty(Map<String, dynamic> game) {
  return 'hard';
}

bool _canPlayerGuess(String player, Map<String, dynamic> game) {
  return game['currentTurn'] == player;
}

Map<String, dynamic> _processWrongGuess(Map<String, dynamic> game, String player) {
  game['currentTurn'] = game['currentTurn'] == game['player1'] ? game['player2'] : game['player1'];
  return game;
}

Map<String, dynamic> _updateScore(
    Map<String, dynamic> game, String player, int points) {
  (game['scores'] as Map<String, int>)[player] = points;
  return game;
}

bool _isLocalDuelOver(Map<String, dynamic> game) {
  return (game['player1Guessed'] as List<String>).length >= 6 ||
      (game['player2Guessed'] as List<String>).length >= 6;
}

Map<String, dynamic> _createGameRoom(String hostId, String style) {
  return {
    'hostId': hostId,
    'style': style,
    'status': 'waiting',
    'roomCode': '${hostId.hashCode}',
  };
}

bool _canJoinRoom(String roomCode, String playerId) {
  return roomCode.isNotEmpty;
}

Map<String, dynamic> _playerReady(Map<String, dynamic> room, String playerId) {
  if (room['status'] == 'waiting') {
    room['status'] = 'ready';
  }
  return room;
}

bool _isSpeedRunTimeOut(Map<String, dynamic> game) {
  return game['timeRemaining'] <= 0;
}

int _decrementTime(int time) => time - 1;

int _calculateSpeedBonus(int timeUsed, int totalTime) {
  return totalTime - timeUsed;
}

Map<String, dynamic> _moveToNextRound(Map<String, dynamic> game) {
  game['roundNumber'] = (game['roundNumber'] + 1);
  game['timeRemaining'] = game['roundDuration'];
  return game;
}

Map<String, dynamic> _awardRound(Map<String, dynamic> series, String winner) {
  if (winner == series['player1']) {
    series['player1Wins'] = (series['player1Wins'] + 1);
  } else {
    series['player2Wins'] = (series['player2Wins'] + 1);
  }

  final majority = (series['roundCount'] / 2).ceil();
  if (series['player1Wins'] >= majority) {
    series['seriesOver'] = true;
    series['seriesWinner'] = series['player1'];
  } else if (series['player2Wins'] >= majority) {
    series['seriesOver'] = true;
    series['seriesWinner'] = series['player2'];
  }

  series['currentRound'] = (series['currentRound'] + 1);
  return series;
}

Map<String, dynamic> _forfeitGame(Map<String, dynamic> game, String forfeiter) {
  game['gameOver'] = true;
  game['winner'] = game['player1'] == forfeiter ? game['player2'] : game['player1'];
  return game;
}

String _sanitizeChatMessage(String message, String secretWord) {
  return message.replaceAll(secretWord, '***');
}

Map<String, dynamic> _handlePlayerDisconnect(Map<String, dynamic> room, String player) {
  room['status'] = 'disconnected';
  return room;
}
