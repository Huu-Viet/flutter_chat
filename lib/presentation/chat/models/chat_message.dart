import 'package:flutter_chat/presentation/chat/models/chat_message_reaction.dart';

/// Base sealed class for all chat message types
sealed class ChatMessage {
  final bool isSentByMe;
  final String? senderId;
  final DateTime timestamp;
  final bool isDeleted;
  final String? localId;
  final String? serverId;
  final String? senderDisplayName;
  final String? senderAvatarUrl;
  final String? conversationAvatarUrl;
  final bool isGroupConversation;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final List<ChatMessageReaction> reactions;

  const ChatMessage({
    required this.isSentByMe,
    this.senderId,
    required this.timestamp,
    this.isDeleted = false,
    this.localId,
    this.serverId,
    this.senderDisplayName,
    this.senderAvatarUrl,
    this.conversationAvatarUrl,
    this.isGroupConversation = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.reactions = const <ChatMessageReaction>[],
  });

  ChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  });

  String get type;
}

/// Text message
final class TextChatMessage extends ChatMessage {
  final String text;

  const TextChatMessage({
    required this.text,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted = false,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation = false,
    super.isFirstInGroup = true,
    super.isLastInGroup = true,
    super.reactions = const <ChatMessageReaction>[],
  });

  @override
  String get type => 'text';

  @override
  TextChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return TextChatMessage(
      text: text,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      localId: localId,
      serverId: serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      reactions: reactions,
    );
  }
}

/// Image message
final class ImageChatMessage extends ChatMessage {
  final String? imagePath;
  final String? mediaId;
  final bool isUploading;
  final bool isResolvingImage;

  const ImageChatMessage({
    this.imagePath,
    this.mediaId,
    this.isUploading = false,
    this.isResolvingImage = false,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted = false,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation = false,
    super.isFirstInGroup = true,
    super.isLastInGroup = true,
    super.reactions = const <ChatMessageReaction>[],
  });

  @override
  String get type => 'image';

  @override
  ImageChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return ImageChatMessage(
      imagePath: imagePath,
      mediaId: mediaId,
      isUploading: isUploading,
      isResolvingImage: isResolvingImage,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      localId: localId,
      serverId: serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      reactions: reactions,
    );
  }
}

/// Audio message
final class AudioChatMessage extends ChatMessage {
  final String? mediaId;
  final int? durationMs;
  final List<double>? waveform;
  final bool isUploading;

  const AudioChatMessage({
    this.mediaId,
    this.durationMs,
    this.waveform,
    this.isUploading = false,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted = false,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation = false,
    super.isFirstInGroup = true,
    super.isLastInGroup = true,
    super.reactions = const <ChatMessageReaction>[],
  });

  @override
  String get type => 'audio';

  @override
  AudioChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return AudioChatMessage(
      mediaId: mediaId,
      durationMs: durationMs,
      waveform: waveform,
      isUploading: isUploading,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      localId: localId,
      serverId: serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      reactions: reactions,
    );
  }
}

/// Video message
final class VideoChatMessage extends ChatMessage {
  final String? thumbnailPath;
  final String? mediaId;
  final int? durationMs;
  final bool isUploading;
  final bool isResolvingImage;

  const VideoChatMessage({
    this.thumbnailPath,
    this.mediaId,
    this.durationMs,
    this.isUploading = false,
    this.isResolvingImage = false,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted = false,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation = false,
    super.isFirstInGroup = true,
    super.isLastInGroup = true,
    super.reactions = const <ChatMessageReaction>[],
  });

  @override
  String get type => 'video';

  @override
  VideoChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return VideoChatMessage(
      thumbnailPath: thumbnailPath,
      mediaId: mediaId,
      durationMs: durationMs,
      isUploading: isUploading,
      isResolvingImage: isResolvingImage,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      localId: localId,
      serverId: serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      reactions: reactions,
    );
  }
}

/// Sticker message
final class StickerChatMessage extends ChatMessage {
  final String? stickerId;
  final String? stickerPath;

  const StickerChatMessage({
    this.stickerId,
    this.stickerPath,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted = false,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation = false,
    super.isFirstInGroup = true,
    super.isLastInGroup = true,
    super.reactions = const <ChatMessageReaction>[],
  });

  @override
  String get type => 'sticker';

  @override
  StickerChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return StickerChatMessage(
      stickerId: stickerId,
      stickerPath: stickerPath,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      localId: localId,
      serverId: serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      reactions: reactions,
    );
  }
}

/// File message
final class FileChatMessage extends ChatMessage {
  final String? fileName;
  final String? mediaId;
  final int? fileSize;
  final bool isUploading;

  const FileChatMessage({
    this.fileName,
    this.mediaId,
    this.fileSize,
    this.isUploading = false,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted = false,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation = false,
    super.isFirstInGroup = true,
    super.isLastInGroup = true,
    super.reactions = const <ChatMessageReaction>[],
  });

  @override
  String get type => 'file';

  @override
  FileChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return FileChatMessage(
      fileName: fileName,
      mediaId: mediaId,
      fileSize: fileSize,
      isUploading: isUploading,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      localId: localId,
      serverId: serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      reactions: reactions,
    );
  }
}

/// Unknown message (fallback)
final class UnknownChatMessage extends ChatMessage {
  final String? content;

  const UnknownChatMessage({
    this.content,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted = false,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation = false,
    super.isFirstInGroup = true,
    super.isLastInGroup = true,
    super.reactions = const <ChatMessageReaction>[],
  });

  @override
  String get type => 'unknown';

  @override
  UnknownChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return UnknownChatMessage(
      content: content,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: isDeleted,
      localId: localId,
      serverId: serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      isFirstInGroup: isFirstInGroup ?? this.isFirstInGroup,
      isLastInGroup: isLastInGroup ?? this.isLastInGroup,
      reactions: reactions,
    );
  }
}
