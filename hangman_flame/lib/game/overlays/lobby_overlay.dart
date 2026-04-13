import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/services.dart';
import '../hangman_game.dart';
import '../../services/game_service.dart';
import '../../services/auth_service.dart';
import 'dart:async';
import '../widgets/ui_widgets.dart';
import '../../theme/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _tryRecoverRoom();
  }

  Future<void> _tryRecoverRoom() async {
    final user = AuthService().currentUser;
    if (user == null) {
      return;
    }
    final room = await _gameService.findActiveRoomForUser(user.id);
    if (room != null) {
      if (!mounted) {
        return;
      }
      setState(() => _currentRoom = room);
      _subscribeToRoom(room.id);
      if (room.getStringValue('status') == 'playing') {
        widget.game.startGame('Multiplayer', 
          roomId: room.id, 
          multiplayer: true, 
          host: room.getStringValue('host') == user.id,
          hId: room.getStringValue('host'),
          oId: room.getStringValue('opponent'),
        );
      }
    }
  }

  Future<void> _createRoom() async {
    setState(() => _isLoading = true);
    final room = await _gameService.createRoom();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentRoom = room;
      _isLoading = false;
    });
    _subscribeToRoom(room.id);
  }

  Future<void> _quickMatch() async {
    // Quick match creates a room and immediately readies host for instant sharing.
    await _createRoom();
    if (!mounted || _currentRoom == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: _currentRoom!.getStringValue('code')));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick Match ready. Room code copied to clipboard.')),
    );
  }

  Future<void> _joinRoom() async {
    setState(() => _isLoading = true);
    final room = await _gameService.joinRoom(_codeController.text);
    if (!mounted) {
      return;
    }
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
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room not found or full')));
    }
  }

  void _subscribeToRoom(String roomId) {
    _roomSubscription?.cancel();
    _roomSubscription = _gameService.subscribeToRoom(roomId).listen((record) {
      if (!mounted) {
        return;
      }
      setState(() => _currentRoom = record);
      
      if (widget.game.isMultiplayer && widget.game.currentRoomId == roomId) {
        widget.game.syncFromRecord(record);
      }

      if (record.getStringValue('status') == 'playing' && !widget.game.isMultiplayer) {
        widget.game.startGame('Multiplayer', 
          roomId: roomId, 
          multiplayer: true, 
          host: record.getStringValue('host') == AuthService().currentUser?.id,
          hId: record.getStringValue('host'),
          oId: record.getStringValue('opponent'),
        );
      }
    });
  }

  Future<void> _leaveRoomAndClose() async {
    if (_currentRoom != null) {
      try {
        await _gameService.leaveRoom(_currentRoom!.id);
      } catch (e) {
        debugPrint('Error leaving room: $e');
      }
      _roomSubscription?.cancel();
    }
    setState(() => _currentRoom = null);
    widget.game.showMainMenu();
  }

  Future<void> _resyncRoom() async {
    if (_currentRoom == null) {
      return;
    }
    final fresh = await _gameService.resyncRoom(_currentRoom!.id);
    if (fresh != null) {
      setState(() => _currentRoom = fresh);
      if (fresh.getStringValue('status') == 'playing') {
        widget.game.startGame('Multiplayer', 
          roomId: fresh.id, 
          multiplayer: true, 
          host: fresh.getStringValue('host') == AuthService().currentUser?.id,
          hId: fresh.getStringValue('host'),
          oId: fresh.getStringValue('opponent'),
        );
      }
    } else {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to reconnect to room')));
    }
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardSurface(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: _currentRoom == null ? _buildJoinCreate() : _buildWaitingRoom(),
        ),
      ),
    );
  }

  Widget _buildJoinCreate() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Multiplayer Arena', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surface2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.flash_on, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ranked-style pressure: live turns, forced timeout misses, and rematch loops.',
                  style: TextStyle(color: cs.textPrimary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SecondaryButton(label: 'Quick Match', onPressed: _isLoading ? null : _quickMatch),
        const SizedBox(height: 10),
        PrimaryButton(label: 'Create Room', onPressed: _isLoading ? null : _createRoom),
        const SizedBox(height: 10),
        const Text('OR'),
        const SizedBox(height: 10),
        TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Enter Room Code')),
        const SizedBox(height: 10),
        PrimaryButton(label: 'Join Room', onPressed: _isLoading ? null : _joinRoom),
        const SizedBox(height: 10),
        TextButton(onPressed: widget.game.showMainMenu, child: const Text('Back to Home')),
      ],
    );
  }

  Widget _buildWaitingRoom() {
    final cs = Theme.of(context).colorScheme;
    final code = _currentRoom?.getStringValue('code') ?? '';
    final opponent = _currentRoom?.getStringValue('opponent') ?? '';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Waiting for Opponent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Room Code: $code', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: cs.primary)),
            IconButton(
              tooltip: 'Copy Code',
              icon: Icon(Icons.copy_rounded, size: 20, color: cs.primary),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied')));
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (opponent.isEmpty)
          Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text('Share code and get ready for a tense duel.', style: TextStyle(color: cs.textMuted)),
            ],
          )
        else ...[
          Text('Opponent Joined! Arena locked.', style: TextStyle(color: cs.letterCorrect, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          if (_currentRoom?.getStringValue('host') == AuthService().currentUser?.id)
            PrimaryButton(
              label: 'Start Match',
              onPressed: () => widget.game.startGame('Multiplayer', 
                roomId: _currentRoom!.id, 
                multiplayer: true, 
                host: true,
                hId: _currentRoom!.getStringValue('host'),
                oId: _currentRoom!.getStringValue('opponent'),
              ),
              height: 52,
            ),
        ],
        Row(
          children: [
            Expanded(
              child: TextButton(onPressed: _resyncRoom, child: const Text('Reconnect')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(onPressed: _leaveRoomAndClose, child: const Text('Quit')),
            ),
          ],
        ),
      ],
    );
  }
}
