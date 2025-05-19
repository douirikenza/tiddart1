import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io';
import 'dart:html' as html;
import '../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  final String vendorName;
  
  const ChatPage({
    super.key,
    required this.vendorName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Map<String, dynamic>> _messages = [];
  bool _showEmojiPicker = false;
  bool _isComposing = false;
  final ImagePicker _picker = ImagePicker();

  // Liste d'émojis colorés
  final List<String> _emojis = [
    '😀', '😃', '😄', '😁', '😅', '😂', '🤣', '😊',
    '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘',
    '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪',
    '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏', '😒',
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🤎', '🖤',
    '👍', '👎', '👊', '✊', '🤛', '🤜', '🤝', '👏',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onEmojiSelected(String emoji) {
    setState(() {
      _messageController.text = _messageController.text + emoji;
    });
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        _focusNode.unfocus();
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      // Créer une URL temporaire pour l'image
      final reader = html.FileReader();
      reader.readAsDataUrl(html.File([await image.readAsBytes()], image.name));
      reader.onLoad.listen((event) {
        setState(() {
          _messages.add({
            'type': 'image',
            'content': reader.result as String,
            'isMe': true,
            'time': DateTime.now(),
          });
        });
      });
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: Colors.purple),
              ),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.attach_file, color: Colors.orange),
              ),
              title: const Text('Document'),
              onTap: () {
                // Implémenter la sélection de document
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'type': 'text',
          'content': _messageController.text,
          'isMe': true,
          'time': DateTime.now(),
        });
        _messageController.clear();
        _isComposing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
              child: Text(
                widget.vendorName[0],
                style: TextStyle(
                  color: AppTheme.primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vendorName,
                  style: TextStyle(
                    color: AppTheme.primaryBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBrown),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppTheme.primaryBrown),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: message['type'] == 'text' 
                      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                      : const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: message['isMe'] ? AppTheme.primaryBrown : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: message['type'] == 'text'
                      ? Text(
                          message['content'],
                          style: TextStyle(
                            color: message['isMe'] ? Colors.white : Colors.black87,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            message['content'],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                  ),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _showEmojiPicker 
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                          color: AppTheme.primaryBrown,
                        ),
                        onPressed: _toggleEmojiPicker,
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file, color: AppTheme.primaryBrown),
                        onPressed: _showAttachmentOptions,
                      ),
                      IconButton(
                        icon: Icon(Icons.photo_camera, color: AppTheme.primaryBrown),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Écrivez votre message ici...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            setState(() {
                              _isComposing = text.trim().isNotEmpty;
                            });
                          },
                          maxLines: null,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: _isComposing ? AppTheme.primaryBrown : Colors.grey[300],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _isComposing ? _sendMessage : null,
                        ),
                      ),
                    ],
                  ),
                  if (_showEmojiPicker)
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          setState(() {
                            _messageController.text = _messageController.text + emoji.emoji;
                          });
                        },
                        config: Config(
                          columns: 7,
                          emojiSizeMax: 32.0,
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          initCategory: Category.SMILEYS,
                          bgColor: Colors.white,
                          indicatorColor: AppTheme.primaryBrown,
                          iconColor: Colors.grey[600]!,
                          iconColorSelected: AppTheme.primaryBrown,
                          buttonMode: ButtonMode.MATERIAL,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}