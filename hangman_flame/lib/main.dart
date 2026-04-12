import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/hangman_game.dart';
import 'game/overlays/main_menu.dart';
import 'game/overlays/game_ui.dart';
import 'game/overlays/game_over.dart';
import 'game/overlays/auth_overlay.dart';
import 'game/overlays/lobby_overlay.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman Flame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final HangmanGame _game;

  @override
  void initState() {
    super.initState();
    _game = HangmanGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<HangmanGame>(
        game: _game,
        overlayBuilderMap: {
          'MainMenu': (context, game) => MainMenu(game: game),
          'GameUI': (context, game) => GameUI(game: game),
          'GameOver': (context, game) => GameOver(game: game),
          'Auth': (context, game) => AuthOverlay(onAuthenticated: () {
            game.overlays.remove('Auth');
            game.overlays.add('Lobby');
          }),
          'Lobby': (context, game) => LobbyOverlay(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}
