import 'package:flutter_chat/presentation/chat/models/chat_message_reaction.dart';

class ChatMessage {
  final String? text;
  final String? imagePath;
  final String? mediaId;
  final String? stickerId;
  final String? audioUrl;
  final int? audioDurationSeconds;
  final List<double> audioWaveform;
  final String type;
  final bool isSentByMe;
  final String? senderId;
  final DateTime timestamp;
  final bool isDeleted;
  final bool isUploading;
  final bool isResolvingImage;
  final String? localId;
  final String? serverId;
  final String? conversationAvatarUrl;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final List<ChatMessageReaction> reactions;

  ChatMessage({
    this.text,
    this.imagePath,
    this.mediaId,
    this.audioUrl,
    this.audioDurationSeconds,
    this.audioWaveform = const <double>[],
    this.stickerId,
    this.type = 'text',
    required this.isSentByMe,
    this.senderId,
    required this.timestamp,
    this.isDeleted = false,
    this.isUploading = false,
    this.isResolvingImage = false,
    this.localId,
    this.serverId,
    this.conversationAvatarUrl,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.reactions = const <ChatMessageReaction>[],
  });

  ChatMessage copyWith({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return ChatMessage(
      text: text,
      imagePath: imagePath,
      mediaId: mediaId,
      audioUrl: audioUrl,
      audioDurationSeconds: audioDurationSeconds,
      audioWaveform: audioWaveform,
      stickerId: stickerId,
      type: type,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      isUploading: isUploading,
      isResolvingImage: isResolvingImage,
      localId: localId,
      serverId: serverId,
      conversationAvatarUrl: conversationAvatarUrl,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      reactions: reactions,
    );
  }
}
