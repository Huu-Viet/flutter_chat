import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:flutter_chat/presentation/chat/chat_providers.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_bubble.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String friendName;

  const ChatPage({super.key,
    required this.conversationId,
    required this.friendName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final MediaService _mediaService = MediaService();
  String? _currentUserId;
  // bool _showEmojiKeyboard = false;

  List<ChatMessage> _mapStateMessagesToUi(List<Message> messages) {
    return messages
        .map(
          (message) => ChatMessage(
            text: _isLikelyLocalImagePath(message.content) ? null : message.content,
            imagePath: _isLikelyLocalImagePath(message.content) ? message.content : null,
            isSentByMe: _currentUserId != null && message.senderId == _currentUserId,
            timestamp: message.createdAt,
          ),
        )
        .toList();
  }

  bool _isLikelyLocalImagePath(String value) {
    final lowerValue = value.toLowerCase();
    return value.startsWith('/') ||
        value.contains(':/') ||
        value.contains(':\\') ||
        lowerValue.endsWith('.png') ||
        lowerValue.endsWith('.jpg') ||
        lowerValue.endsWith('.jpeg') ||
        lowerValue.endsWith('.webp') ||
        lowerValue.endsWith('.gif');
  }

  Future<void> _loadCurrentUserId() async {
    final result = await ref.read(getCurrentUserIdUseCaseProvider).call();
    if (!mounted) {
      return;
    }

    setState(() {
      _currentUserId = result.fold((_) => null, (id) => id);
    });
  }

  @override
  void initState() {
    super.initState();
    ref.read(chatBlocProvider).add(ChatInitialLoadEvent(widget.conversationId));
    _loadCurrentUserId();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatBlocProvider).add(SendTextEvent(
      conversationId: widget.conversationId,
      content: content,
    ));
    _messageController.clear();
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
    final chatBloc = ref.read(chatBlocProvider);
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider<ChatBloc>.value(
      value: chatBloc,
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.error_unknown)),
            );
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.friendName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceBright,
            ),
            body: Column(
              children: [
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    final List<ChatMessage> displayMessages = state is ChatLoaded
                        ? _mapStateMessagesToUi(state.messages)
                        : _messages;

                    return Expanded(
                      child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: displayMessages.length,
                      itemBuilder: (context, index) {
                        final message = displayMessages[displayMessages.length - 1 - index];
                        return MessageBubble(message: message);
                        },
                      ),
                    );
                  },
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
        ),
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
