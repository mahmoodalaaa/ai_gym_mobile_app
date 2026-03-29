import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatMessage {
  final String text;
  final bool isAi;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isAi,
    required this.timestamp,
  });
}

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initial AI message
    _messages.add(ChatMessage(
      text:
          "Hello! I'm GYM AI, your personal fitness coach. How can I help you today?",
      isAi: true,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isAi: false, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(text);
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(text: response, isAi: true, timestamp: DateTime.now()),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "Sorry, I encountered an error: $e",
              isAi: true,
              timestamp: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GYM AI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Chat',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text:
                      "Hello! I'm GYM AI, your personal coach. Ready to go again?",
                  isAi: true,
                  timestamp: DateTime.now(),
                ));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMessageBubble(
                    context,
                    message: message.text,
                    isAi: message.isAi,
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'GYM AI is typing...',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(24).copyWith(bottom: 120),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withOpacity(0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: 'Ask GYM AI anything...',
                      border: InputBorder.none,
                      hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: Theme.of(context).colorScheme.surface,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context, {
    required String message,
    required bool isAi,
  }) {
    return Row(
      mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAi) ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.2),
            child: Icon(
              Icons.smart_toy,
              size: 20,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          const SizedBox(width: 12),
        ],

        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isAi
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isAi ? 4 : 20),
                bottomRight: Radius.circular(isAi ? 20 : 4),
              ),
            ),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isAi
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.surface,
                height: 1.4,
              ),
            ),
          ),
        ),

        if (!isAi)
          const SizedBox(
            width: 44,
          ), // To balance the avatar width on the other side
      ],
    );
  }
}
