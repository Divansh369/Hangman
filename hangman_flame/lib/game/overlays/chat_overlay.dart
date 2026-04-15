import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/game_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive_utils.dart';
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
  final ScrollController _scrollController = ScrollController();
  final List<RecordModel> _messages = [];
  StreamSubscription? _chatSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.game.currentRoomId != null) {
      _chatSubscription = _gameService.subscribeToChat(widget.game.currentRoomId!).listen((msg) {
        if (!mounted) {
          return;
        }
        setState(() => _messages.add(msg));
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    if (_messageController.text.trim().isEmpty) return;
    String text = _messageController.text.trim();
    
    if (widget.game.secretWord.isNotEmpty && text.toLowerCase().contains(widget.game.secretWord.toLowerCase())) {
      text = '*** [Blocked Word] ***';
    }
    
    _gameService.sendMessage(widget.game.currentRoomId!, text);
    _messageController.clear();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Chat width: responsive, max 300 on mobile, 350 on tablet+
    final width = context.isMobile ? 280.0 : 350.0;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(left: BorderSide(color: cs.outlineVariant)),
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: cs.chatHeaderBackground,
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text('GAME CHAT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: cs.chatHeaderText)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final userId = msg.getStringValue('user');
                final bool isMe = userId == AuthService().currentUser?.id;
                final bool isSystem = userId.isEmpty;

                if (isSystem) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        msg.getStringValue('text'),
                        style: TextStyle(fontSize: 12, color: cs.chatSystemMessageText, fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                    decoration: BoxDecoration(
                      color: isMe ? cs.chatBubbleOwn : cs.chatBubbleOther,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                    ),
                    child: Text(
                      msg.getStringValue('text'),
                      style: TextStyle(color: isMe ? cs.chatBubbleTextOwn : cs.chatBubbleTextOther),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: cs.surfaceContainerLow,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send, size: 20),
                  style: IconButton.styleFrom(backgroundColor: cs.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
