import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(HangmanVisual()
      ..position = Vector2(size.x / 2 - 100, 50)
      ..size = Vector2(200, 250));
  }

  @override
  Color backgroundColor() => Colors.white;

  void startGame(String category, {String? customWord, bool multiplayer = false, String? roomId, bool host = false, String? hId, String? oId}) {
    isMultiplayer = multiplayer;
    currentRoomId = roomId;
    isHost = host;
    hostId = hId;
    opponentId = oId;
    currentCategory = category;
    currentRound = 1;
    
    _initRound();

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
  }

  void _initRound() {
    if (isMultiplayer) {
      secretWord = ''; 
      isWaitingForWordNotifier.value = true;
      // Round 1: Host sets word. Round 2: Opponent sets word.
      currentTurnId = (currentRound == 1) ? hostId : opponentId;
    } else {
      secretWord = getRandomWord(currentCategory);
      isWaitingForWordNotifier.value = false;
    }
    revealedLetters = List.filled(secretWord.length, '');
    guessedLetters = [];
    wrongGuesses = 0;
    isGameOver = false;
    didWin = false;
    _updateNotifiers();
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
    final newSecret = record.getStringValue('secretWord');
    secretWord = newSecret;
    guessedLetters = List<String>.from(record.getListValue<String>('guessedLetters'));
    currentTurnId = record.getStringValue('turn');
    hostId = record.getStringValue('host');
    opponentId = record.getStringValue('opponent');
    int newRound = record.getIntValue('round');
    
    if (newRound != currentRound) {
      currentRound = newRound;
      // Logic for round transition could be added here
    }

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
    if (secretWord.isEmpty) return;
    
    if (!revealedLetters.contains('')) {
      isGameOver = true;
      didWin = true;
      if (isMultiplayer) _handleMultiplayerWin();
      overlays.add('GameOver');
    } else if (wrongGuesses >= maxTries) {
      isGameOver = true;
      didWin = false;
      overlays.add('GameOver');
    }
  }

  void _handleMultiplayerWin() async {
    final currentUser = AuthService().currentUser;
    if (currentUser != null && didWin) {
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
