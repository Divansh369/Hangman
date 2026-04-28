import 'package:flutter/material.dart';
import 'dart:ui';
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
        if (!mounted) return;
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
    final width = context.isMobile ? 280.0 : 350.0;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: cs.glassBackground,
            border: Border(left: BorderSide(color: cs.glassBorder)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: cs.glassBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.chat_bubble_outline, size: 16, color: cs.primary),
                    ),
                    const SizedBox(width: 10),
                    Text('GAME CHAT', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5, color: cs.textPrimary, fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.letterCorrect.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: cs.letterCorrect)),
                    ),
                  ],
                ),
              ),
              // Messages
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.forum_outlined, size: 36, color: cs.textMuted.withValues(alpha: 0.3)),
                            const SizedBox(height: 8),
                            Text('No messages yet', style: TextStyle(color: cs.textMuted.withValues(alpha: 0.5), fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
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
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: cs.glassHighlight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  msg.getStringValue('text'),
                                  style: TextStyle(fontSize: 11, color: cs.textMuted, fontStyle: FontStyle.italic),
                                ),
                              ),
                            );
                          }

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(maxWidth: width * 0.75),
                              decoration: BoxDecoration(
                                gradient: isMe
                                    ? LinearGradient(colors: cs.primaryGradient)
                                    : null,
                                color: isMe ? null : cs.glassHighlight,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft: Radius.circular(isMe ? 14 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 14),
                                ),
                              ),
                              child: Text(
                                msg.getStringValue('text'),
                                style: TextStyle(
                                  color: isMe ? Colors.white : cs.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Input
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: cs.glassBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.glassHighlight,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          onSubmitted: (_) => _send(),
                          style: TextStyle(color: cs.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: cs.textMuted.withValues(alpha: 0.5)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: cs.primaryGradient),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: cs.primaryGlow, blurRadius: 8)],
                      ),
                      child: IconButton(
                        onPressed: _send,
                        icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
