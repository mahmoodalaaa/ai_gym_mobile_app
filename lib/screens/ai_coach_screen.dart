import 'package:flutter/material.dart';

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GYM AI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _buildSystemMessage(context, 'Today at 08:30'),
                const SizedBox(height: 24),
                _buildMessageBubble(
                  context,
                  message:
                      'Good morning, John. Your squat 1RM went up by 5kg this month! Ready to tackle today\'s hypertrophy session?',
                  isAi: true,
                ),
                const SizedBox(height: 16),
                _buildMessageBubble(
                  context,
                  message:
                      'Yeah, feeling great. But my lower back is a bit tight from deadlifts two days ago.',
                  isAi: false,
                ),
                const SizedBox(height: 16),
                _buildMessageBubble(
                  context,
                  message:
                      'Understood. Let\'s swap out Barbell Rows for Chest-Supported Machine Rows to completely remove the lower back tax while still hitting the lats hard. Would you like me to update today\'s plan?',
                  isAi: true,
                ),
                const SizedBox(height: 16),
                _buildMessageBubble(
                  context,
                  message: 'Yes, please update it.',
                  isAi: false,
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
                    decoration: InputDecoration(
                      hintText: 'Ask GYM AI anything...',
                      border: InputBorder.none,
                      hintStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                Container(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context, String text) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
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
