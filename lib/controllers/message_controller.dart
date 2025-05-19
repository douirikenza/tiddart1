import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Message> messages = <Message>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('MessageController initialisé');
  }

  // Méthode pour ajouter un message de test
  Future<void> addTestMessage(String artisanId) async {
    try {
      print('Ajout d\'un message de test pour artisanId: $artisanId');
      final message = {
        'senderId': 'client_test_1',
        'receiverId': artisanId,
        'content': 'Bonjour, je suis intéressé par vos produits.',
        'timestamp': Timestamp.now(),
        'isRead': false,
        'senderName': 'Client Test',
        'senderImage': null,
      };

      final docRef = await _firestore.collection('messages').add(message);
      print('Message de test ajouté avec succès. ID: ${docRef.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout du message de test: $e');
      rethrow;
    }
  }

  // Obtenir tous les messages pour un artisan
  Stream<List<Message>> getMessages(String artisanId) {
    print('Récupération des messages pour artisanId: $artisanId');
    try {
      return _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: artisanId)
          .snapshots()
          .map((snapshot) {
            print('Snapshot reçu: ${snapshot.docs.length} documents');
            final messages = snapshot.docs.map((doc) {
              print('Document ID: ${doc.id}');
              print('Document data: ${doc.data()}');
              return Message.fromFirestore(doc);
            }).toList();
            messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            return messages;
          })
          .handleError((error) {
            print('Erreur dans le stream: $error');
            throw error;
          });
    } catch (e) {
      print('Erreur lors de la création du stream: $e');
      rethrow;
    }
  }

  // Obtenir les conversations uniques pour un artisan
  Stream<List<Message>> getConversations(String artisanId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: artisanId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final allMessages = snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
          
          // Grouper par expéditeur et prendre le dernier message
          final Map<String, Message> latestMessages = {};
          for (var message in allMessages) {
            if (!latestMessages.containsKey(message.senderId) ||
                message.timestamp.isAfter(latestMessages[message.senderId]!.timestamp)) {
              latestMessages[message.senderId] = message;
            }
          }
          
          print('Conversations trouvées: ${latestMessages.length}'); // Debug log
          return latestMessages.values.toList();
        });
  }

  // Obtenir le nombre de messages non lus
  Stream<int> getUnreadCount(String artisanId) {
    print('Récupération du nombre de messages non lus pour artisanId: $artisanId');
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: artisanId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Marquer un message comme lu
  Future<void> markAsRead(String messageId) async {
    try {
      print('Marquage du message comme lu: $messageId');
      await _firestore.collection('messages').doc(messageId).update({
        'isRead': true,
      });
      print('Message marqué comme lu avec succès');
    } catch (e) {
      print('Erreur lors du marquage du message comme lu: $e');
      rethrow;
    }
  }

  // Envoyer un nouveau message
  Future<void> sendMessage(Message message) async {
    try {
      await _firestore.collection('messages').add(message.toMap());
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      rethrow;
    }
  }

  // Supprimer un message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du message: $e');
      rethrow;
    }
  }
} 