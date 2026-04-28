import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/services.dart';
import '../hangman_game.dart';
import '../../services/game_service.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive_utils.dart';
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
    final width = context.isMobile ? (MediaQuery.of(context).size.width - 48.0) : 520.0;
    return Center(
      child: CardSurface(
        width: width,
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
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
        GlowBadge(icon: Icons.sports_esports_rounded, color: cs.primary, size: 48),
        const SizedBox(height: 12),
        Text('Multiplayer Arena', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: cs.textPrimary)),
        const SizedBox(height: 4),
        Text('Challenge a friend in real-time', style: TextStyle(fontSize: 13, color: cs.textMuted)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.flash_on_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Live turns, forced timeout misses, and rematch loops.',
                  style: TextStyle(color: cs.textPrimary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: PrimaryButton(label: 'Create Room', icon: Icons.add_circle_outline, onPressed: _isLoading ? null : _createRoom)),
          const SizedBox(width: 10),
          Expanded(child: SecondaryButton(label: 'Quick Match', onPressed: _isLoading ? null : _quickMatch)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Divider(color: cs.glassBorder)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or join', style: TextStyle(fontSize: 12, color: cs.textMuted)),
          ),
          Expanded(child: Divider(color: cs.glassBorder)),
        ]),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cs.glassBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.glassBorder),
          ),
          child: TextField(
            controller: _codeController,
            style: TextStyle(color: cs.textPrimary, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 4),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'ROOM CODE',
              hintStyle: TextStyle(color: cs.textMuted.withValues(alpha: 0.4), letterSpacing: 4),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(label: 'Join Room', icon: Icons.login_rounded, onPressed: _isLoading ? null : _joinRoom),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: widget.game.showMainMenu,
          child: Text('Back to Home', style: TextStyle(color: cs.textMuted)),
        ),
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
        GlowBadge(
          icon: opponent.isEmpty ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
          color: opponent.isEmpty ? Colors.amber : cs.letterCorrect,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          opponent.isEmpty ? 'Waiting for Opponent' : 'Opponent Joined!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cs.textPrimary),
        ),
        const SizedBox(height: 16),
        // Room code display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.glassBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
          ),
          child: Column(children: [
            Text('Room Code', style: TextStyle(fontSize: 11, color: cs.textMuted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(code, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: cs.primary, letterSpacing: 6)),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Copy Code',
                  icon: Icon(Icons.copy_rounded, size: 18, color: cs.primary),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied')));
                  },
                ),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 16),
        if (opponent.isEmpty)
          Column(children: [
            SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.primary),
            ),
            const SizedBox(height: 10),
            Text('Share the code and wait...', style: TextStyle(color: cs.textMuted, fontSize: 13)),
          ])
        else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.letterCorrect.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.letterCorrect.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 18, color: cs.letterCorrect),
                const SizedBox(width: 8),
                Text('Arena locked. Ready to battle!', style: TextStyle(color: cs.letterCorrect, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_currentRoom?.getStringValue('host') == AuthService().currentUser?.id)
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Start Match',
                icon: Icons.play_arrow_rounded,
                onPressed: () => widget.game.startGame('Multiplayer', 
                  roomId: _currentRoom!.id, 
                  multiplayer: true, 
                  host: true,
                  hId: _currentRoom!.getStringValue('host'),
                  oId: _currentRoom!.getStringValue('opponent'),
                ),
              ),
            ),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextButton.icon(
              onPressed: _resyncRoom,
              icon: Icon(Icons.refresh_rounded, size: 16, color: cs.textMuted),
              label: Text('Reconnect', style: TextStyle(color: cs.textMuted)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton.icon(
              onPressed: _leaveRoomAndClose,
              icon: Icon(Icons.exit_to_app_rounded, size: 16, color: cs.error),
              label: Text('Quit', style: TextStyle(color: cs.error)),
            ),
          ),
        ]),
      ],
    );
  }
}
