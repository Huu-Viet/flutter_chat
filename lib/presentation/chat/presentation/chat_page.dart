import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/native_services/media/media_service.dart';

class ChatPage extends StatefulWidget {
  final String friendName;

  const ChatPage({Key? key, required this.friendName}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final MediaService _mediaService = MediaService();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<File> images = await _mediaService.pickMultipleImages(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        limit: 10,
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }


  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 8,
          children: ['😊', '😂', '❤️', '👍', '🎉', '😍', '🔥', '👏', '😎', '🙏', '💯', '😢', '😮', '😡', '🤔', '👋']
              .map((emoji) => InkWell(
            onTap: () {
              _messageController.text += emoji;
              Navigator.pop(context);
            },
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ))
              .toList(),
        ),
      ),
    );
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
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: message.isSentByMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: message.imagePath != null
            ? Image.file(File(message.imagePath!), height: 200, fit: BoxFit.cover)
            : Text(
          message.text ?? '',
          style: TextStyle(color: message.isSentByMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
            onPressed: _showEmojiPicker,
          ),
          IconButton(
            icon: const Icon(Icons.image, color: Colors.grey),
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
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
