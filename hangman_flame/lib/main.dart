import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/hangman_game.dart';
import 'game/overlays/main_menu.dart';
import 'game/overlays/nav_bar.dart';
import 'game/overlays/game_ui.dart';
import 'game/overlays/game_over.dart';
import 'game/overlays/auth_overlay.dart';
import 'game/overlays/lobby_overlay.dart';
import 'game/overlays/settings_overlay.dart';
import 'game/overlays/profile_overlay.dart';
import 'game/overlays/levels_overlay.dart';
import 'game/overlays/collectibles_overlay.dart';
import 'game/overlays/unlock_overlay.dart';
import 'game/overlays/animated_overlay.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/sfx_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  await ThemeService().init();
  await SfxService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeMode,
      builder: (context, mode, child) {
        return ValueListenableBuilder<Color>(
          valueListenable: ThemeService().accentColor,
          builder: (context, accent, _) {
            return MaterialApp(
              title: 'Hangman Flame',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(accent),
              darkTheme: AppTheme.dark(accent),
              themeMode: mode,
              home: const GamePage(),
            );
          },
        );
      },
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
          'MainMenu': (context, game) => AnimatedOverlay(child: MainMenu(game: game)),
          'GameUI': (context, game) => AnimatedOverlay(child: GameUI(game: game)),
          'GameOver': (context, game) => AnimatedOverlay(child: GameOver(game: game)),
          'Auth': (context, game) => AnimatedOverlay(child: AuthOverlay(onAuthenticated: () {
            game.showMainMenu();
          })),
          'Lobby': (context, game) => AnimatedOverlay(child: LobbyOverlay(game: game)),
          'Settings': (context, game) => AnimatedOverlay(child: SettingsOverlay(game: game)),
          'Profile': (context, game) => AnimatedOverlay(child: ProfileOverlay(game: game)),
          'Levels': (context, game) => AnimatedOverlay(child: LevelsOverlay(game: game)),
          'Collectibles': (context, game) => AnimatedOverlay(child: CollectiblesOverlay(game: game)),
          'Unlock': (context, game) => AnimatedOverlay(child: UnlockOverlay(game: game)),
          'NavBar': (context, game) => AnimatedOverlay(child: NavBar(game: game)),
        },
        initialActiveOverlays: const ['MainMenu','NavBar'],
      ),
    );
  }
}
