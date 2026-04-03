import 'package:flutter/material.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/presentation/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_chat/presentation/chat/presentation/widgets/message_input.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  final String friendName;

  const ChatPage({super.key, required this.friendName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final MediaService _mediaService = MediaService();
  // bool _showEmojiKeyboard = false;


  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: _messageController.text,
          isSentByMe: true,
          timestamp: DateTime.now(),
        ));
      });
      _messageController.clear();
    }
  }

  Future<void> _pickImage() async {
    try {
      final File? image = await _mediaService.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _messages.add(ChatMessage(
            imagePath: image.path,
            isSentByMe: true,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    final List<File> images = await _mediaService.pickMultipleImages(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          _messages.add(ChatMessage(
            imagePath: image.path,
            isSentByMe: true,
            timestamp: DateTime.now(),
          ));
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(message: message);
              },
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onPickImage: _pickImage,
            onPickMultipleImages: _pickMultipleImages,
            onEmojiSelected: (emoji) {
              _messageController.text += emoji;
            },
          ),
        ],
      ),
    );
  }


}

class ChatMessage {
  final String? text;
  final String? imagePath;
  final bool isSentByMe;
  final DateTime timestamp;

  ChatMessage({
    this.text,
    this.imagePath,
    required this.isSentByMe,
    required this.timestamp,
  });
}
