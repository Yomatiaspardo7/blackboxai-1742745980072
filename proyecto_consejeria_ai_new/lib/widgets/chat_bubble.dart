import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const ChatBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildBubble(context),
                const SizedBox(height: 2),
                _buildTimestamp(context),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildStatus(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.psychology_outlined,
          size: 20,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: _getBubbleColor(context),
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomLeft: message.isUser ? null : const Radius.circular(4),
          bottomRight: message.isUser ? const Radius.circular(4) : null,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.voice) _buildVoiceContent(),
                if (message.type != MessageType.voice)
                  Text(
                    message.content,
                    style: TextStyle(
                      color: _getTextColor(context),
                      height: 1.3,
                    ),
                  ),
                if (message.type == MessageType.error && onRetry != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ),
              ],
            ),
          ),
          if (message.status == MessageStatus.sending)
            Positioned(
              right: 4,
              bottom: 4,
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTextColor(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mic,
          size: 18,
          color: message.isUser ? Colors.white : Colors.deepPurple,
        ),
        const SizedBox(width: 8),
        Text(
          message.voiceDuration?.toString().split('.').first ?? '0:00',
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        DateFormat('HH:mm').format(message.timestamp),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.6),
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _buildStatus() {
    if (message.status == MessageStatus.error) {
      return const Icon(
        Icons.error_outline,
        size: 16,
        color: Colors.red,
      );
    }
    return const Icon(
      Icons.check,
      size: 16,
      color: Colors.grey,
    );
  }

  Color _getBubbleColor(BuildContext context) {
    if (message.type == MessageType.error) {
      return Colors.red.shade50;
    }
    if (message.isUser) {
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).cardColor;
  }

  Color _getTextColor(BuildContext context) {
    if (message.type == MessageType.error) {
      return Colors.red;
    }
    if (message.isUser) {
      return Colors.white;
    }
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }
}