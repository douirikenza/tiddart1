import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import 'chat_page.dart';
import '../controllers/auth_controller.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final AuthController _authController = Get.find<AuthController>();

  // Liste de test des conversations
  final List<Map<String, dynamic>> _allConversations = [
    {
      'vendorName': 'Artisan Fatma',
      'vendorId': 'vendor_1',
      'lastMessage': 'Bonjour, est-ce que le produit est disponible ?',
      'time': '14:30',
      'unread': 2,
      'isOnline': true,
    },
    {
      'vendorName': 'Artisan Amira',
      'vendorId': 'vendor_2',
      'lastMessage': 'Merci pour votre commande !',
      'time': '12:45',
      'unread': 0,
      'isOnline': false,
    },
    {
      'vendorName': 'Artisan Khadija',
      'vendorId': 'vendor_3',
      'lastMessage': 'Le produit sera disponible la semaine prochaine',
      'time': '10:15',
      'unread': 1,
      'isOnline': true,
    },
  ];

  List<Map<String, dynamic>> _filteredConversations = [];

  @override
  void initState() {
    super.initState();
    _filteredConversations = List.from(_allConversations);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConversations = _allConversations.where((conversation) {
        final vendorName = conversation['vendorName'].toString().toLowerCase();
        final lastMessage = conversation['lastMessage'].toString().toLowerCase();
        return vendorName.contains(query) || lastMessage.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Rechercher une conversation...',
                  hintStyle: TextStyle(
                    color: AppTheme.primaryBrown.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: AppTheme.primaryBrown,
                  fontSize: 16,
                ),
                autofocus: true,
              )
            : Text(
                'Messages',
                style: AppTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
        centerTitle: true,
        leading: _isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.primaryBrown),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _filteredConversations = List.from(_allConversations);
                  });
                },
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppTheme.primaryBrown,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredConversations = List.from(_allConversations);
                } else {
                  _searchFocusNode.requestFocus();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pour votre sécurité, veuillez utiliser uniquement la messagerie de Tiddart pour communiquer avec les artisans.',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredConversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _filteredConversations[index];
                      return _buildConversationCard(conversation, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrown.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSearching ? Icons.search_off : Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.primaryBrown.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isSearching ? 'Aucun résultat trouvé' : 'Aucune conversation',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryBrown.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Essayez avec d\'autres mots-clés'
                : 'Commencez à discuter avec nos artisans',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryBrown.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppTheme.primaryBrown.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            final currentUser = _authController.firebaseUser.value;
            if (currentUser != null) {
              Get.to(() => ChatPage(
                currentUserId: currentUser.uid,
                otherUserId: conversation['vendorId'] ?? 'unknown', // TODO: Add vendorId to conversation data
                otherUserName: conversation['vendorName'],
              ));
            } else {
              Get.snackbar(
                'Erreur',
                'Vous devez être connecté pour accéder aux messages',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.brown,
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                      child: Text(
                        conversation['vendorName'][0],
                        style: TextStyle(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    if (conversation['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                            conversation['vendorName'],
                            style: AppTheme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            conversation['time'],
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryBrown.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation['lastMessage'],
                              style: AppTheme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryBrown.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation['unread'] > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBrown,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                conversation['unread'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 