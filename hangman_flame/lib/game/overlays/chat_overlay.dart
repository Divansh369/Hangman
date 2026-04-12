import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/game_service.dart';
import '../../services/auth_service.dart';
import '../hangman_game.dart';
import 'dart:async';

class ChatOverlay extends StatefulWidget {
  final HangmanGame game;
  const ChatOverlay({super.key, required this.game});

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  final _gameService = GameService();
  final _messageController = TextEditingController();
  final List<RecordModel> _messages = [];
  StreamSubscription? _chatSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.game.currentRoomId != null) {
      _chatSubscription = _gameService.subscribeToChat(widget.game.currentRoomId!).listen((msg) {
        if (!mounted) return;
        setState(() => _messages.add(msg));
      });
    }
  }

  void _send() {
    if (_messageController.text.isEmpty) return;
    String text = _messageController.text;
    
    // Filter out the secret word
    if (widget.game.secretWord.isNotEmpty && text.toLowerCase().contains(widget.game.secretWord)) {
      text = text.replaceAll(RegExp(widget.game.secretWord, caseSensitive: false), '****');
    }
    
    _gameService.sendMessage(widget.game.currentRoomId!, text);
    _messageController.clear();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey.withValues(alpha: 0.1),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('LIVE CHAT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final bool isMe = msg.getStringValue('user') == AuthService().currentUser?.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(msg.getStringValue('text')),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(hintText: 'Type...', isDense: true),
                  ),
                ),
                IconButton(onPressed: _send, icon: const Icon(IconData(0xe571, fontFamily: 'MaterialIcons'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
