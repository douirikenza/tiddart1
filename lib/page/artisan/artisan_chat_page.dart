import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../controllers/message_controller.dart';
import '../../models/message_model.dart';

class ArtisanChatPage extends StatefulWidget {
  final String artisanId;
  final String clientId;
  final String clientName;

  const ArtisanChatPage({
    Key? key,
    required this.artisanId,
    required this.clientId,
    required this.clientName,
  }) : super(key: key);

  @override
  State<ArtisanChatPage> createState() => _ArtisanChatPageState();
}

class _ArtisanChatPageState extends State<ArtisanChatPage> {
  final MessageController _messageController = Get.find<MessageController>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    // TODO: Implémenter l'envoi du message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppTheme.primaryBrown.withOpacity(0.1),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.clientName,
              style: TextStyle(
                color: AppTheme.primaryBrown,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'En ligne',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBrown),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageController.getMessages(widget.artisanId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur de chargement des messages',
                      style: TextStyle(color: AppTheme.primaryBrown),
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppTheme.primaryBrown.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun message',
                          style: TextStyle(
                            color: AppTheme.primaryBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.receiverId == widget.artisanId;

                    return Align(
                      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 8,
                          left: isMe ? 0 : 64,
                          right: isMe ? 64 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppTheme.primaryBrown
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  message.senderName,
                                  style: TextStyle(
                                    color: AppTheme.primaryBrown,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add_photo_alternate,
                          color: AppTheme.primaryBrown,
                        ),
                        onPressed: () {
                          // TODO: Implémenter l'ajout de photo
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _textController,
                          onChanged: (text) {
                            setState(() {
                              _isComposing = text.trim().isNotEmpty;
                            });
                          },
                          onSubmitted: _isComposing ? _handleSubmitted : null,
                          decoration: InputDecoration(
                            hintText: 'Écrivez votre message...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: _isComposing
                            ? AppTheme.primaryBrown
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      ),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
} 