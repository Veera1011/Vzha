import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/chat_service.dart';
import '../../services/ai_service.dart';
import '../../services/supabase_service.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom room;

  const ChatScreen({super.key, required this.room});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _aiService = AiService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  bool _sendingAi = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _focusNode.requestFocus();

    final isAiCommand = text.startsWith('@ai ') || text.startsWith('/ai ');

    // Post the user's message first
    await _chatService.sendMessage(roomId: widget.room.id, content: text);

    // If it's an @ai or /ai command, trigger the AI
    if (isAiCommand) {
      final query = text.replaceFirst(RegExp(r'^[@/]ai\s*'), '');
      setState(() => _sendingAi = true);
      try {
        final context = 'You are a developer assistant inside a chat room named #${widget.room.name} (type: ${widget.room.type}). Answer concisely and precisely.';
        final aiResponse = await _aiService.askAI(context, query);
        await _chatService.sendMessage(
          roomId: widget.room.id,
          content: aiResponse,
          isAi: true,
          aiEmail: 'AI Assistant',
        );
      } catch (e) {
        await _chatService.sendMessage(
          roomId: widget.room.id,
          content: '⚠️ AI error: $e',
          isAi: true,
          aiEmail: 'AI Assistant',
        );
      } finally {
        setState(() => _sendingAi = false);
      }
    }

    // Scroll after a short delay to allow stream update
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: Row(
          children: [
            Text('#', style: tt.titleLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
            Text(widget.room.name, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.room.description ?? '',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── AI hint banner ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: cs.secondaryContainer.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: cs.onSecondaryContainer),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tip: Type @ai <question> to get an inline AI response visible to everyone.',
                    style: tt.labelSmall?.copyWith(color: cs.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),

          // ── Message list ────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.messagesStream(widget.room.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snap.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 56, color: cs.outlineVariant),
                        const SizedBox(height: 12),
                        Text('No messages yet.\nBe the first to share your perspective!',
                            textAlign: TextAlign.center,
                            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.userId == _chatService.currentUserId;
                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),

          // ── AI loading indicator ────────────────────────────────────────
          if (_sendingAi)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: cs.primary),
                  const SizedBox(width: 8),
                  Text('AI is thinking...', style: tt.labelSmall?.copyWith(color: cs.primary)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                  ),
                ],
              ),
            ),

          // ── Input bar ───────────────────────────────────────────────────
          _InputBar(
            controller: _textController,
            focusNode: _focusNode,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  bool get _hasCodeBlock => message.content.contains('```');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isAi = message.isAi;
    final bubbleColor = isAi
        ? cs.tertiaryContainer
        : isMe
            ? cs.primaryContainer
            : cs.surfaceContainerHighest;
    final textColor = isAi
        ? cs.onTertiaryContainer
        : isMe
            ? cs.onPrimaryContainer
            : cs.onSurface;

    final initials = message.userEmail.isNotEmpty
        ? message.userEmail[0].toUpperCase()
        : '?';
    final time = _formatTime(message.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar (only for others / AI)
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isAi ? cs.tertiary : cs.secondary,
              child: isAi
                  ? Icon(Icons.auto_awesome, size: 14, color: cs.onTertiary)
                  : Text(initials, style: TextStyle(fontSize: 12, color: cs.onSecondary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showContextMenu(context),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender label
                    if (!isMe)
                      Text(
                        isAi ? '🤖 AI Assistant' : message.userEmail,
                        style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isAi ? cs.tertiary : cs.secondary,
                        ),
                      ),
                    if (!isMe) const SizedBox(height: 4),

                    // Message content (with code blocks)
                    _hasCodeBlock
                        ? _buildRichContent(context, message.content, textColor)
                        : Text(message.content, style: tt.bodyMedium?.copyWith(color: textColor)),

                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(time, style: tt.labelSmall?.copyWith(color: textColor.withOpacity(0.6))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: Text('Save Message', style: tt.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _saveMessage(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text('Copy Text', style: tt.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: message.content));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveMessage(BuildContext context) async {
    try {
      final supabaseService = SupabaseService();
      await supabaseService.saveItem('chat', message.id, {
        'content': message.content,
        'sender': message.userEmail,
        'is_ai': message.isAi,
        'room_id': message.roomId,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message saved!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  Widget _buildRichContent(BuildContext context, String content, Color textColor) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Split the content on ``` markers
    final parts = content.split('```');
    final widgets = <Widget>[];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Plain text
        if (parts[i].trim().isNotEmpty) {
          widgets.add(Text(parts[i].trim(), style: tt.bodyMedium?.copyWith(color: textColor)));
          widgets.add(const SizedBox(height: 6));
        }
      } else {
        // Code block — strip optional language label on the first line
        var code = parts[i];
        String language = 'dart'; // default
        final lines = code.split('\n');
        if (lines.isNotEmpty && lines[0].trim().isNotEmpty && !lines[0].contains(' ')) {
          language = lines[0].trim();
          code = lines.skip(1).join('\n');
        }

        widgets.add(
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: code.trim()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied to clipboard'), duration: Duration(seconds: 2)),
              );
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 6),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    color: cs.surfaceContainerHighest,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)),
                        Icon(Icons.copy, size: 14, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                  // Highlighted code
                  HighlightView(
                    code.trim(),
                    language: language,
                    theme: Theme.of(context).brightness == Brightness.dark ? draculaTheme : githubTheme,
                    padding: const EdgeInsets.all(12),
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Message #… or @ai <question>',
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onSend,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Send'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
