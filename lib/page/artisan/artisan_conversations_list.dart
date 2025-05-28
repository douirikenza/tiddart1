import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../controllers/message_controller.dart';
import '../../models/message_model.dart';
import 'artisan_chat_page.dart';

class ArtisanConversationsList extends StatelessWidget {
  final String artisanId;
  final MessageController _messageController = Get.find<MessageController>();

  ArtisanConversationsList({
    Key? key,
    required this.artisanId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppTheme.primaryBrown.withOpacity(0.1),
        title: Text(
          'Mes Conversations',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBrown),
          onPressed: () => Get.back(),
        ),
      ),
      body: StreamBuilder<List<Message>>(
        stream: _messageController.getMessages(artisanId),
        builder: (context, snapshot) {
          print('État de la connexion: ${snapshot.connectionState}');
          print('Données: ${snapshot.data}');
          if (snapshot.hasError) {
            print('Erreur détaillée: ${snapshot.error}');
            print('Stack trace: ${snapshot.stackTrace}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement des messages: ${snapshot.error}',
                    style: TextStyle(
                      color: AppTheme.primaryBrown,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                  const SizedBox(height: 8),
                  Text(
                    'Vos conversations apparaîtront ici',
                    style: TextStyle(
                      color: AppTheme.primaryBrown.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Grouper les messages par expéditeur
          final Map<String, Message> latestMessages = {};
          for (var message in messages) {
            final senderId = message.senderId;
            if (!latestMessages.containsKey(senderId) ||
                message.timestamp.isAfter(latestMessages[senderId]!.timestamp)) {
              latestMessages[senderId] = message;
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: latestMessages.length,
            itemBuilder: (context, index) {
              final message = latestMessages.values.toList()[index];
              final unreadCount = messages
                  .where((m) => m.senderId == message.senderId && !m.isRead)
                  .length;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Get.to(
                        () => ArtisanChatPage(
                          artisanId: artisanId,
                          clientId: message.senderId,
                          clientName: message.senderName,
                        ),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                            child: message.senderImage != null
                                ? ClipOval(
                                    child: Image.network(
                                      message.senderImage!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 32,
                                    color: AppTheme.primaryBrown,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      message.senderName,
                                      style: TextStyle(
                                        color: AppTheme.primaryBrown,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(message.timestamp),
                                      style: TextStyle(
                                        color: AppTheme.primaryBrown.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  message.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.textDark.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBrown,
        onPressed: () async {
          await _messageController.addTestMessage(artisanId);
          Get.snackbar(
            'Test',
            'Message de test ajouté',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );
        },
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }
} 