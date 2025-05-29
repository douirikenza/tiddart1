import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import 'chat_page.dart';
import '../theme/app_theme.dart';

class ConversationsPage extends StatelessWidget {
  final String currentUserId;
  final bool isArtisan;

  const ConversationsPage({
    Key? key,
    required this.currentUserId,
    required this.isArtisan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewConversationDialog(context);
        },
        backgroundColor: AppTheme.primaryBrown,
        child: Icon(Icons.message),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where(isArtisan ? 'receiverId' : 'senderId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Une erreur est survenue'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!.docs;
          final conversations = <String, Map<String, dynamic>>{};

          for (var doc in messages) {
            final message = Message.fromMap(doc.data() as Map<String, dynamic>);
            final otherUserId = isArtisan ? message.senderId : message.receiverId;
            
            if (!conversations.containsKey(otherUserId)) {
              conversations[otherUserId] = {
                'lastMessage': message,
                'unreadCount': 0,
              };
            }
            
            if (!message.isRead && message.receiverId == currentUserId) {
              conversations[otherUserId]!['unreadCount']++;
            }
          }

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune conversation',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final otherUserId = conversations.keys.elementAt(index);
              final conversation = conversations[otherUserId]!;
              final lastMessage = conversation['lastMessage'] as Message;
              final unreadCount = conversation['unreadCount'] as int;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection(isArtisan ? 'clients' : 'artisans')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                        child: Icon(Icons.person, color: AppTheme.primaryBrown),
                      ),
                      title: Text('Chargement...'),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['name'] ?? 'Utilisateur';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                      child: Text(
                        userName[0].toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      userName,
                      style: TextStyle(
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unreadCount > 0 ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    trailing: unreadCount > 0
                        ? Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Text(
                            _formatTimestamp(lastMessage.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            currentUserId: currentUserId,
                            otherUserId: otherUserId,
                            otherUserName: userName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle conversation'),
        content: Container(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(isArtisan ? 'clients' : 'artisans')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  final userName = userData['name'] ?? 'Utilisateur';
                  final userId = users[index].id;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                      child: Text(
                        userName[0].toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(userName),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            currentUserId: currentUserId,
                            otherUserId: userId,
                            otherUserName: userName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }
} 