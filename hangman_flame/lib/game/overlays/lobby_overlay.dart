import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../hangman_game.dart';
import '../../services/game_service.dart';
import '../../services/auth_service.dart';
import 'dart:async';

class LobbyOverlay extends StatefulWidget {
  final HangmanGame game;
  const LobbyOverlay({super.key, required this.game});

  @override
  State<LobbyOverlay> createState() => _LobbyOverlayState();
}

class _LobbyOverlayState extends State<LobbyOverlay> {
  final _gameService = GameService();
  final _codeController = TextEditingController();
  RecordModel? _currentRoom;
  StreamSubscription? _roomSubscription;
  bool _isLoading = false;

  Future<void> _createRoom() async {
    setState(() => _isLoading = true);
    final room = await _gameService.createRoom();
    setState(() {
      _currentRoom = room;
      _isLoading = false;
    });
    _subscribeToRoom(room.id);
  }

  Future<void> _joinRoom() async {
    setState(() => _isLoading = true);
    final room = await _gameService.joinRoom(_codeController.text);
    setState(() => _isLoading = false);
    
    if (room != null) {
      setState(() => _currentRoom = room);
      _subscribeToRoom(room.id);
      if (room.getStringValue('status') == 'playing') {
        widget.game.startGame('Multiplayer', 
          roomId: room.id, 
          multiplayer: true, 
          host: false,
          hId: room.getStringValue('host'),
          oId: room.getStringValue('opponent'),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room not found or full')));
    }
  }

  void _subscribeToRoom(String roomId) {
    _roomSubscription?.cancel();
    _roomSubscription = _gameService.subscribeToRoom(roomId).listen((record) {
      if (!mounted) return;
      setState(() => _currentRoom = record);
      
      if (widget.game.isMultiplayer && widget.game.currentRoomId == roomId) {
        widget.game.syncFromRecord(record);
      }

      if (record.getStringValue('status') == 'playing' && !widget.game.isMultiplayer) {
        widget.game.startGame('Multiplayer', 
          roomId: roomId, 
          multiplayer: true, 
          host: false, // You joined, you are not the host
          hId: record.getStringValue('host'),
          oId: record.getStringValue('opponent'),
        );
      }
    });
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: _currentRoom == null ? _buildJoinCreate() : _buildWaitingRoom(),
      ),
    );
  }

  Widget _buildJoinCreate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Multiplayer Lobby', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _createRoom,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          child: const Text('Create Room'),
        ),
        const SizedBox(height: 10),
        const Text('OR'),
        const SizedBox(height: 10),
        TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Enter Room Code')),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isLoading ? null : _joinRoom,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          child: const Text('Join Room'),
        ),
      ],
    );
  }

  Widget _buildWaitingRoom() {
    final code = _currentRoom?.getStringValue('code') ?? '';
    final opponent = _currentRoom?.getStringValue('opponent') ?? '';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Waiting for Opponent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text('Room Code: $code', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 20),
        if (opponent.isEmpty)
          const CircularProgressIndicator()
        else ...[
          const Text('Opponent Joined!', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 20),
          if (_currentRoom?.getStringValue('host') == AuthService().currentUser?.id)
            ElevatedButton(
              onPressed: () => widget.game.startGame('Multiplayer', 
                roomId: _currentRoom!.id, 
                multiplayer: true, 
                host: true,
                hId: _currentRoom!.getStringValue('host'),
                oId: _currentRoom!.getStringValue('opponent'),
              ),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Start Game'),
            ),
        ],
        TextButton(onPressed: () => setState(() => _currentRoom = null), child: const Text('Cancel')),
      ],
    );
  }
}
