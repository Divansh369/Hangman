import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketbase/pocketbase.dart';
import '../data/words.dart';
import 'components/hangman_visual.dart';
import '../services/game_service.dart';
import '../services/auth_service.dart';

class HangmanGame extends FlameGame {
  late String secretWord;
  late List<String> revealedLetters;
  late List<String> guessedLetters;
  int wrongGuesses = 0;
  final int maxTries = 6;
  bool isGameOver = false;
  bool didWin = false;
  String currentCategory = 'Animals';

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

  void startGame(String category, {String? customWord, bool multiplayer = false, String? roomId, bool host = false, String? hId, String? oId}) {
    isMultiplayer = multiplayer;
    currentRoomId = roomId;
    isHost = host;
    hostId = hId;
    opponentId = oId;
    currentCategory = category;
    currentRound = 1;
    hasAwardedPoints = false;
    
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

    overlays.remove('MainMenu');
    overlays.remove('Lobby');
    overlays.remove('GameOver');
    overlays.add('GameUI');
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
    _updateNotifiers();
  }

  void restartMultiplayer() {
    if (!isMultiplayer || currentRoomId == null || !isHost) return;
    
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
    if (!isMultiplayer || currentRoomId == null) return;
    
    final cleanWord = word.trim().toLowerCase();
    if (cleanWord.isEmpty || !RegExp(r'^[a-z]+$').hasMatch(cleanWord)) return;

    // After word is set, the OTHER person guesses
    String guesserId = (currentRound == 1) ? opponentId! : hostId!;
    
    _gameService.updateRoom(currentRoomId!, {
      'secretWord': cleanWord,
      'turn': guesserId, 
    });
  }

  void makeGuess(String letter) {
    if (isGameOver || guessedLetters.contains(letter)) return;

    if (isMultiplayer) {
      if (currentTurnId != AuthService().currentUser?.id) return;
      
      final updatedGuessed = List<String>.from(guessedLetters)..add(letter);
      
      _gameService.updateRoom(currentRoomId!, {
        'guessedLetters': updatedGuessed,
      });
      return; 
    }

    guessedLetters.add(letter);
    _processGuess(letter);
    _checkGameOver();
    _updateNotifiers();
  }

  void _processGuess(String letter) {
    bool found = false;
    for (int i = 0; i < secretWord.length; i++) {
      if (secretWord[i] == letter) {
        revealedLetters[i] = letter;
        found = true;
      }
    }
    if (!found) {
      wrongGuesses++;
    }
  }

  void syncFromRecord(RecordModel record) {
    if (!isMultiplayer) return;

    final String status = record.getStringValue('status');
    if (status != 'playing') return;

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
    if (secretWord.isEmpty || isGameOver) return;
    
    if (!revealedLetters.contains('')) {
      isGameOver = true;
      didWin = true;
      if (isMultiplayer) _handleMultiplayerWin();
      overlays.add('GameOver');
    } else if (wrongGuesses >= maxTries) {
      isGameOver = true;
      didWin = false;
      if (isMultiplayer) _handleMultiplayerWin();
      overlays.add('GameOver');
    }
  }

  void _handleMultiplayerWin() async {
    if (hasAwardedPoints) return;
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return;

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
       await AuthService().pb.collection('users').update(currentUser.id, body: {
         'score': currentScore + 10,
       });
    }
  }

  void _updateNotifiers() {
    wrongGuessesNotifier.value = wrongGuesses;
    wordNotifier.value = revealedLetters.map((l) => l.isEmpty ? '_' : l).join(' ');
    gameOverNotifier.value = isGameOver;
    winNotifier.value = didWin;
    guessedLettersNotifier.value = List.from(guessedLetters);
  }

  void resetToMenu() {
    overlays.remove('GameUI');
    overlays.remove('GameOver');
    overlays.add('MainMenu');
  }
}
