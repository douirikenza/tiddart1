import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;

  final List<Map<String, dynamic>> _messages = [
    {'text': "Bonjour, est-ce disponible ?", 'isMe': false},
    {'text': "Oui, c'est disponible.", 'isMe': true},
  ];

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _player.openPlayer();
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission micro refusée. Activez-la dans les paramètres.'),
          backgroundColor: Colors.brown,
        ),
      );
      return;
    }

    await _recorder.openRecorder();
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      await _recorder.startRecorder(
        toFile: 'voice.aac',
        codec: Codec.aacADTS,
      );
    } else {
      final path = await _recorder.stopRecorder();
      if (path != null) {
        final file = File(path);
        final fileName = 'audios/${DateTime.now().millisecondsSinceEpoch}.aac';
        final ref = FirebaseStorage.instance.ref().child(fileName);

        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();

        setState(() {
          _messages.add({'text': downloadUrl, 'isMe': true, 'isAudio': true});
        });
        _scrollToBottom();
      }
    }
    setState(() => _isRecording = !_isRecording);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({'text': text, 'isMe': true});
        _messageController.clear();
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF5E6D3),
                const Color(0xFFF0D9B5),
              ],
            ),
          ),
        ),
        title: Text(
          'Chat avec Artisan',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.primaryBrown),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFDF6E9),
              const Color(0xFFF5E6D3),
            ],
          ),
        ),
        child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['isAudio'] == true) {
                  return AudioBubble(
                    filePath: msg['text'],
                    isSentByMe: msg['isMe'],
                    player: _player,
                  );
                }
                return ChatBubble(message: msg['text'], isSentByMe: msg['isMe']);
              },
            ),
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF3E8),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFE5D5C0),
                          width: 1.5,
                        ),
                      ),
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: Color(0xFF4B2706),
                        ),
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF4B2706).withOpacity(0.6),
                            fontFamily: 'Roboto',
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF8B4513),
                          const Color(0xFF4B2706),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4B2706).withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                  ),
                  child: IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 22,
                      ),
                    onPressed: _toggleRecording,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF8B4513),
                          const Color(0xFF4B2706),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4B2706).withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                  ),
                  child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 22,
                      ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;

  const ChatBubble({super.key, required this.message, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSentByMe
                ? [
                    const Color(0xFFD2B48C),
                    const Color(0xFFC4A484),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8F8F8),
                  ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isSentByMe ? 20 : 4),
            bottomRight: Radius.circular(isSentByMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            color: isSentByMe ? const Color(0xFF4B2706) : const Color(0xFF2D2D2D),
            fontFamily: 'Roboto',
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class AudioBubble extends StatelessWidget {
  final String filePath;
  final bool isSentByMe;
  final FlutterSoundPlayer player;

  const AudioBubble({
    super.key,
    required this.filePath,
    required this.isSentByMe,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSentByMe
                ? [
                    const Color(0xFFD2B48C),
                    const Color(0xFFC4A484),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8F8F8),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.audiotrack, size: 20, color: Colors.brown),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () async {
                if (player.isPlaying) {
                  await player.stopPlayer();
                } else {
                  await player.startPlayer(fromURI: filePath);
                }
              },
              child: const Text("Écouter"),
            ),
          ],
        ),
      ),
    );
  }
}