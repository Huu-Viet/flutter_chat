import 'package:flutter/material.dart';
import 'sticker_picker_sheet.dart';
import '../../../features/chat/domain/entities/sticker_item.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final VoidCallback onPickImage;
  final VoidCallback onPickMultipleImages;
  final Function(String) onEmojiSelected;
  final Function(StickerItem)? onStickerSelected;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    required this.onPickImage,
    required this.onPickMultipleImages,
    required this.onEmojiSelected,
    this.onStickerSelected,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _showEmojiPicker(BuildContext context) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StickerPickerSheet(
        onStickerTap: (sticker) {
          if (widget.onStickerSelected != null) {
            widget.onStickerSelected!(sticker);
          }
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
                widget.onPickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Multiple Images'),
              onTap: () {
                Navigator.pop(context);
                widget.onPickMultipleImages();
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
        color: Theme.of(context).colorScheme.surfaceBright,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildIconButton(
              icon: Icons.emoji_emotions_outlined,
              onPressed: () => _showEmojiPicker(context),
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildTextField(context)),
            if (!_hasText) ...[
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.more_horiz,
                onPressed: () {},
              ),
              _buildIconButton(
                icon: Icons.mic_none,
                onPressed: () {},
              ),
              _buildIconButton(
                icon: Icons.image_outlined,
                onPressed: () => _showImagePickerOptions(context),
              ),
            ] else ...[
              const SizedBox(width: 8),
              _buildSendButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return IconButton(
      icon: const Icon(Icons.send, color: Colors.blue),
      onPressed: widget.onSendMessage,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? Colors.white70),
      onPressed: onPressed,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: widget.controller,
      style: const TextStyle(
          color: Colors.white
      ),
      decoration: const InputDecoration(
        hintText: 'Tin nhắn',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        hintStyle: TextStyle(color: Colors.grey),
        isDense: true,
      ),
      minLines: 1,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: Colors.blue,
    );
  }

}
