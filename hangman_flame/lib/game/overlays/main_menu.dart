import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../hangman_game.dart';
import '../../data/words.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';

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
  final GameService _gameService = GameService();

  void _showLeaderboard() {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<RecordModel>>(
        future: _gameService.getLeaderboard(),
        builder: (context, snapshot) {
          return AlertDialog(
            title: const Text('🏆 Top Players', textAlign: TextAlign.center),
            content: SizedBox(
              width: double.maxFinite,
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : snapshot.hasError
                      ? const Text('Error loading leaderboard')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, i) {
                            final user = snapshot.data![i];
                            return ListTile(
                              leading: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              title: Text(user.getStringValue('username')),
                              trailing: Text('${user.getIntValue('score')} pts', 
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        (user.getStringValue('username').isNotEmpty) 
                          ? user.getStringValue('username')[0].toUpperCase() 
                          : '?'
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.getStringValue('username'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${user.getIntValue('score')} Points', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
                      onPressed: () {
                        AuthService().logout();
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const Divider(height: 32),
              ],
              Text(
                '🪓 HANGMAN',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 24),
              _buildModeSelector(),
              const SizedBox(height: 20),
              _buildContextInputs(),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _onStartPressed,
                child: const Text('START GAME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showLeaderboard,
                icon: const Icon(Icons.emoji_events),
                label: const Text('LEADERBOARD'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: mode,
          isExpanded: true,
          items: ['1-Player', '2-Player', 'Multiplayer'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (val) => setState(() => mode = val!),
        ),
      ),
    );
  }

  Widget _buildContextInputs() {
    if (mode == '1-Player') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categories.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
            ),
          ),
        ],
      );
    } else if (mode == '2-Player') {
      return TextField(
        controller: _customWordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Secret Word',
          hintText: 'Enter word for Player 2',
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );
    } else {
      return const Text(
        'Challenge players around the world!',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      );
    }
  }

  void _onStartPressed() {
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
  }
}
