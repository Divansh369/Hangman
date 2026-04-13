import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import '../data/words.dart';
import 'components/hangman_visual.dart';
import '../services/game_service.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import '../data/hints.dart';
import 'difficulty_level.dart';

class HangmanGame extends FlameGame {
  static const List<String> _screenOverlays = [
    'MainMenu',
    'Auth',
    'Lobby',
    'Settings',
    'Profile',
    'Levels',
    'Collectibles',
    'GameUI',
  ];

  late String secretWord;
  late List<String> revealedLetters;
  late List<String> guessedLetters;
  int wrongGuesses = 0;
  late int maxTries;
  DifficultyLevel difficulty = DifficultyLevel.medium;
  bool isGameOver = false;
  bool didWin = false;
  String currentCategory = 'Animals';
  String? currentLevelId;
  int minScoreForLevel = 20; // Customizable per level
  Timer? _afkTimer;
  bool hasForfeited = false;

  // Multiplayer fields
  bool isMultiplayer = false;
  String? currentRoomId;
  bool isHost = false;
  String? currentTurnId;
  String? hostId;
  String? opponentId;
  int currentRound = 1; 
  final GameService _gameService = GameService();

  final ValueNotifier<int> wrongGuessesNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> wordNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> gameOverNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> winNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<List<String>> guessedLettersNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<String?> turnNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isWaitingForWordNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> hintsNotifier = ValueNotifier<int>(3);
  final ValueNotifier<String?> hintNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> unlockedNotifier = ValueNotifier<String?>(null);
  // Scoring + UX
  int score = 0;
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> lastScoreGainNotifier = ValueNotifier<int>(0);
  int _comboCount = 0;
  DateTime _roundStartTime = DateTime.now();
  Timer? _clearLastScoreTimer;

  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && !isGameOver && !isWaitingForWordNotifier.value) {
      final String char = event.logicalKey.keyLabel.toLowerCase();
      if (char.length == 1 && RegExp(r'[a-z]').hasMatch(char)) {
        makeGuess(char);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(HangmanVisual()
      ..position = Vector2(size.x / 2 - 100, 50)
      ..size = Vector2(200, 250));
  }

  @override
  Color backgroundColor() => Colors.white;

  bool hasAwardedPoints = false;

  void showScreen(String overlay, {bool showNavBar = true}) {
    for (final name in _screenOverlays) {
      overlays.remove(name);
    }
    overlays.remove('GameOver');
    overlays.remove('Unlock');

    if (showNavBar) {
      overlays.add('NavBar');
    } else {
      overlays.remove('NavBar');
    }

    overlays.add(overlay);
  }

  void showMainMenu() {
    showScreen('MainMenu', showNavBar: true);
  }

  void startGame(String category, {String? customWord, bool multiplayer = false, String? roomId, bool host = false, String? hId, String? oId, String? levelId, DifficultyLevel? selectedDifficulty, int minScore = 20}) {
    isMultiplayer = multiplayer;
    currentRoomId = roomId;
    isHost = host;
    hostId = hId;
    opponentId = oId;
    currentCategory = category;
    currentLevelId = levelId;
    difficulty = selectedDifficulty ?? DifficultyLevel.medium;
    maxTries = difficulty.maxWrongGuesses;
    minScoreForLevel = minScore;
    currentRound = 1;
    hasAwardedPoints = false;
    hasForfeited = false;
    score = 0;
    scoreNotifier.value = 0;
    lastScoreGainNotifier.value = 0;
    _comboCount = 0;
    
    _initRound(customWord: customWord);

    if (isMultiplayer && isHost && roomId != null) {
      _gameService.updateRoom(roomId, {
        'status': 'playing',
        'turn': hostId, 
        'secretWord': '',
        'guessedLetters': [],
        'wrongGuesses': 0,
        'round': 1,
      });
    }

    _startAfkTimer();
    showScreen('GameUI', showNavBar: false);
  }

  void _initRound({String? customWord}) {
    if (isMultiplayer) {
      secretWord = ''; 
      isWaitingForWordNotifier.value = true;
      // Round 1: Host sets word. Round 2: Opponent sets word.
      currentTurnId = (currentRound == 1) ? hostId : opponentId;
    } else if (customWord != null) {
      secretWord = customWord;
      isWaitingForWordNotifier.value = false;
    } else {
      secretWord = getRandomWord(currentCategory);
      isWaitingForWordNotifier.value = false;
    }
    revealedLetters = List.filled(secretWord.length, '');
    guessedLetters = [];
    wrongGuesses = 0;
    isGameOver = false;
    didWin = false;
    hasAwardedPoints = false;
    // reset timing and combo for the new round
    _roundStartTime = DateTime.now();
    _comboCount = 0;
    _updateNotifiers();
  }

  void restartMultiplayer() {
    if (!isMultiplayer || currentRoomId == null || !isHost) {
      return;
    }
    
    // Swap rounds
    int nextRound = (currentRound == 1) ? 2 : 1;
    
    _gameService.updateRoom(currentRoomId!, {
      'status': 'playing',
      'turn': (nextRound == 1) ? hostId : opponentId,
      'secretWord': '',
      'guessedLetters': [],
      'wrongGuesses': 0,
      'round': nextRound,
    });
  }

  void setMultiplayerWord(String word) {
    if (!isMultiplayer || currentRoomId == null) {
      return;
    }
    
    final cleanWord = word.trim().toLowerCase();
    if (cleanWord.isEmpty || !RegExp(r'^[a-z]+$').hasMatch(cleanWord)) {
      return;
    }

    // After word is set, the OTHER person guesses
    String guesserId = (currentRound == 1) ? opponentId! : hostId!;
    
    _gameService.updateRoom(currentRoomId!, {
      'secretWord': cleanWord,
      'turn': guesserId, 
    });
  }

  Future<String?> useHint() async {
    if (hintsNotifier.value <= 0) return null;
    if (secretWord.isEmpty) return null;

    // Only allow hint for current guesser (or in single-player always)
    if (isMultiplayer && currentTurnId != AuthService().currentUser?.id) return null;

    String? hint = getHintForWord(secretWord);
    // fallback: give category + length hint
    hint ??= '$currentCategory • ${secretWord.length} letters';

    hintNotifier.value = hint;
    hintsNotifier.value = hintsNotifier.value - 1;
    return hint;
  }

  void makeGuess(String letter) {
    if (isGameOver || guessedLetters.contains(letter)) {
      return;
    }

    _resetAfkTimer();

    if (isMultiplayer) {
      if (currentTurnId != AuthService().currentUser?.id) {
        return;
      }
      
      final updatedGuessed = List<String>.from(guessedLetters)..add(letter);
      
      _gameService.updateRoom(currentRoomId!, {
        'guessedLetters': updatedGuessed,
      });
      return; 
    }

    guessedLetters.add(letter);
    _processGuess(letter, awardPoints: true);
    _checkGameOver();
    _updateNotifiers();
  }

  void _processGuess(String letter, {bool awardPoints = false}) {
    bool found = false;
    for (int i = 0; i < secretWord.length; i++) {
      if (secretWord[i] == letter) {
        revealedLetters[i] = letter;
        found = true;
      }
    }
    if (!found) {
      wrongGuesses++;
      // reset combo on miss
      _comboCount = 0;
    } else {
      // award points only when explicitly requested (single-player local guesses)
      if (awardPoints) {
        _comboCount++;
        // multiplier increases slightly with combo, capped
        double multiplier = 1.0 + (_comboCount - 1) * 0.25;
        if (multiplier > 2.0) multiplier = 2.0;
        const int basePoints = 10;
        // time bonus based on how quickly the guess was made since round start
        final int elapsed = DateTime.now().difference(_roundStartTime).inSeconds;
        int timeBonus = 0;
        if (elapsed <= 3) {
          timeBonus = 5;
        } else if (elapsed <= 10) {
          timeBonus = 2;
        }

        final int gained = (basePoints * multiplier).round() + timeBonus;
        score += gained;
        scoreNotifier.value = score;
        lastScoreGainNotifier.value = gained;
        _clearLastScoreTimer?.cancel();
        _clearLastScoreTimer = Timer(const Duration(milliseconds: 1400), () {
          lastScoreGainNotifier.value = 0;
        });
      }
      
    }
  }

  void syncFromRecord(RecordModel record) {
    if (!isMultiplayer) {
      return;
    }

    final String status = record.getStringValue('status');
    if (status != 'playing') {
      return;
    }

    final newSecret = record.getStringValue('secretWord');
    final newRound = record.getIntValue('round');
    
    // If a new round has started (or word reset)
    if (newRound != currentRound || (secretWord.isNotEmpty && newSecret.isEmpty)) {
      currentRound = newRound;
      _initRound();
      overlays.remove('GameOver');
    }

    secretWord = newSecret;
    guessedLetters = List<String>.from(record.getListValue<String>('guessedLetters'));
    currentTurnId = record.getStringValue('turn');
    hostId = record.getStringValue('host');
    opponentId = record.getStringValue('opponent');

    isWaitingForWordNotifier.value = secretWord.isEmpty;

    revealedLetters = List.filled(secretWord.length, '');
    wrongGuesses = 0;
    if (secretWord.isNotEmpty) {
      for (var letter in guessedLetters) {
        _processGuess(letter);
      }
    }

    _checkGameOver();
    _updateNotifiers();
  }

  void _checkGameOver() {
    if (secretWord.isEmpty || isGameOver) {
      return;
    }
    
    if (!revealedLetters.contains('')) {
      isGameOver = true;
      didWin = true;
      if (isMultiplayer) {
        _handleMultiplayerWin();
      } else {
        _recordGameStats(won: true);
        // single-player: mark level complete if a levelId was provided
        if (currentLevelId != null) {
          ProgressService().completeLevel(currentLevelId!);
        }
      }
      overlays.add('GameOver');
    } else if (wrongGuesses >= maxTries) {
      isGameOver = true;
      didWin = false;
      if (isMultiplayer) {
        _handleMultiplayerWin();
      } else {
        _recordGameStats(won: false);
      }
      overlays.add('GameOver');
    }
  }

  void _recordGameStats({required bool won}) {
    ProgressService().recordGameResult(won: won, score: score);
    if (won) {
      ProgressService().updatePlayStreak();
    }
  }

  void _handleMultiplayerWin() async {
    if (hasAwardedPoints) {
      return;
    }
    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      return;
    }

    bool shouldGetPoints = false;
    // Guessing turn was currentTurnId
    if (didWin && currentTurnId == currentUser.id) {
      shouldGetPoints = true;
    } else if (!didWin && currentTurnId != currentUser.id) {
      // If guesser failed, the other person (setter) gets points
      shouldGetPoints = true;
    }

    if (shouldGetPoints) {
       hasAwardedPoints = true;
       final currentScore = currentUser.getIntValue('score');
       final newScore = currentScore + 10;
       await AuthService().pb.collection('users').update(currentUser.id, body: {
         'score': newScore,
       });

       // Award collectibles for reaching score thresholds (one-time each)
       try {
         final progressRecord = await ProgressService().getOrCreateProgressRecord();
         if (progressRecord != null) {
           final existing = progressRecord.getListValue('collectibles');
           final thresholds = {50: 'badge_50', 100: 'badge_100', 200: 'badge_200'};
           for (final entry in thresholds.entries) {
             final threshold = entry.key;
             final badgeId = entry.value;
             if (currentScore < threshold && newScore >= threshold && !existing.contains(badgeId)) {
               final added = await ProgressService().addCollectible(badgeId);
               if (added) {
                 // notify UI and show unlock animation
                 unlockedNotifier.value = badgeId;
                 try {
                   overlays.add('Unlock');
                 } catch (_) {}
               }
             }
           }
         }
       } catch (e) {
         debugPrint('Error awarding collectible: $e');
       }
    }
  }

  void _updateNotifiers() {
    wrongGuessesNotifier.value = wrongGuesses;
    wordNotifier.value = revealedLetters.map((l) => l.isEmpty ? '_' : l).join(' ');
    gameOverNotifier.value = isGameOver;
    winNotifier.value = didWin;
    guessedLettersNotifier.value = List.from(guessedLetters);
  }

  // AFK timeout management
  void _startAfkTimer() {
    _afkTimer?.cancel();
    _afkTimer = Timer(const Duration(minutes: 2), () {
      if (!isGameOver) {
        _handleAfkTimeout();
      }
    });
  }

  void _resetAfkTimer() {
    _startAfkTimer();
  }

  void _handleAfkTimeout() {
    if (isGameOver) return;
    
    isGameOver = true;
    didWin = false;
    hasForfeited = true;
    
    overlays.add('GameOver');
    _updateNotifiers();
  }

  void surrender() {
    if (isGameOver || hasForfeited) return;
    
    isGameOver = true;
    didWin = false;
    hasForfeited = true;
    _afkTimer?.cancel();
    
    overlays.add('GameOver');
    _updateNotifiers();
  }

  int calculateStars() {
    if (!didWin || hasForfeited) return 0;
    return difficulty.calculateStars(score, minScoreForLevel);
  }

  Future<void> resetToMenu() async {
    if (isMultiplayer && currentRoomId != null) {
      try {
        await _gameService.leaveRoom(currentRoomId!);
      } catch (e) {
        debugPrint('Error leaving room on reset: $e');
      }
    }

    // Clear local multiplayer state
    isMultiplayer = false;
    currentRoomId = null;
    isHost = false;
    currentTurnId = null;
    hostId = null;
    opponentId = null;
    currentRound = 1;
    isWaitingForWordNotifier.value = false;

    showMainMenu();
  }
}
