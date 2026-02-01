import 'package:flutter/material.dart';
import 'emoji_picker_widget.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final VoidCallback onPickImage;
  final VoidCallback onPickMultipleImages; // Add this
  final Function(String) onEmojiSelected;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    required this.onPickImage,
    required this.onPickMultipleImages, // Add this
    required this.onEmojiSelected,
  });

  void _showEmojiPicker(BuildContext context) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EmojiPickerWidget(
        onEmojiSelected: (emoji) {
          onEmojiSelected(emoji);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pick Single Image'),
              onTap: () {
                Navigator.pop(context);
                onPickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Multiple Images'),
              onTap: () {
                Navigator.pop(context);
                onPickMultipleImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildInputContainer(context),
            const SizedBox(width: 8),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            _buildIconButton(
              icon: Icons.emoji_emotions_outlined,
              onPressed: () => _showEmojiPicker(context),
            ),
            _buildIconButton(
              icon: Icons.image_outlined,
              onPressed: () => _showImagePickerOptions(context),
            ),
            Expanded(child: _buildTextField()),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white),
        onPressed: onSendMessage,
      ),
    );
  }


  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? Colors.grey),
      onPressed: onPressed,
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Type a message...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      minLines: 1,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
    );
  }

}
