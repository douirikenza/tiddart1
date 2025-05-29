import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import 'package:uuid/uuid.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'messages';

  // Envoyer un message
  Future<void> sendMessage(Message message) async {
    await _firestore.collection(_collection).doc(message.id).set(message.toMap());
  }

  // Envoyer un message avec image
  Future<void> sendImageMessage(String senderId, String receiverId, String imageUrl, DateTime timestamp) async {
    final message = Message(
      id: Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: imageUrl,
      timestamp: timestamp,
    );
    await sendMessage(message);
  }

  // Récupérer les messages entre deux utilisateurs
  Stream<List<Message>> getMessagesBetweenUsers(String userId1, String userId2) {
    return _firestore
        .collection(_collection)
        .where('senderId', whereIn: [userId1, userId2])
        .where('receiverId', whereIn: [userId1, userId2])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data()))
          .toList();
    });
  }

  // Marquer tous les messages comme lus
  Future<void> markMessagesAsRead(String currentUserId, String otherUserId) async {
    final messages = await _firestore
        .collection(_collection)
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // Marquer un message comme lu
  Future<void> markMessageAsRead(String messageId) async {
    await _firestore
        .collection(_collection)
        .doc(messageId)
        .update({'isRead': true});
  }

  // Supprimer un message
  Future<void> deleteMessage(String messageId) async {
    await _firestore.collection(_collection).doc(messageId).delete();
  }
} 