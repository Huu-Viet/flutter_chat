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
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceBright,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
            _buildSendButton(context),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildIconButton(
              icon: Icons.emoji_emotions_outlined,
              onPressed: () => _showEmojiPicker(context),
            ),
            Expanded(child: _buildTextField(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final isTextEmpty = value.text.trim().isEmpty;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: isTextEmpty
              ? Row(
            children: [
              _buildIconButton(
                icon: Icons.image_outlined,
                onPressed: () => _showImagePickerOptions(context),
              ),
              _buildIconButton(
                icon: Icons.mic_none_rounded,
                onPressed: () => {},
              ),
            ],
          )
              : IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: onSendMessage,
          ),
        );
      },
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

  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
          color: Colors.black
      ),
      decoration: const InputDecoration(
        hintText: 'Type a message...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        hintStyle: TextStyle(color: Colors.grey),
      ),
      minLines: 1,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: Colors.grey,
    );
  }

}
