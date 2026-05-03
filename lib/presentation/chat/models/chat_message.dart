import 'package:flutter_chat/features/chat/domain/entities/messages/message/forward_info.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message_reaction.dart';

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
  final ForwardInfo? forwardInfo;
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
    this.forwardInfo,
    this.reactions = const <ChatMessageReaction>[],
  });

  ChatMessage copyWithGrouping({bool? isFirstInGroup, bool? isLastInGroup});

  String get type;
}

final class ReplyPreview {
  final String messageId;
  final String senderDisplay;
  final String snippet;

  const ReplyPreview({
    required this.messageId,
    required this.senderDisplay,
    required this.snippet,
  });
}

final class TextChatMessage extends ChatMessage {
  final String text;
  final String? replyToId;
  final ReplyPreview? replyPreview;

  const TextChatMessage({
    required this.text,
    this.replyToId,
    this.replyPreview,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation,
    super.isFirstInGroup,
    super.isLastInGroup,
    super.forwardInfo,
    super.reactions,
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
      replyToId: replyToId,
      replyPreview: replyPreview,
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
      forwardInfo: forwardInfo,
      reactions: reactions,
    );
  }
}

final class ImageChatMessage extends ChatMessage {
  final String? imagePath;
  final String? mediaId;
  final List<String> imagePaths;
  final List<String> mediaIds;
  final bool isUploading;
  final bool isResolvingImage;

  const ImageChatMessage({
    this.imagePath,
    this.mediaId,
    this.imagePaths = const <String>[],
    this.mediaIds = const <String>[],
    this.isUploading = false,
    this.isResolvingImage = false,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation,
    super.isFirstInGroup,
    super.isLastInGroup,
    super.forwardInfo,
    super.reactions,
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
      imagePaths: imagePaths,
      mediaIds: mediaIds,
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
      forwardInfo: forwardInfo,
      reactions: reactions,
    );
  }
}

final class AudioChatMessage extends ChatMessage {
  final String? mediaId;
  final String? audioUrl;
  final int? durationMs;
  final List<double>? waveform;
  final bool isUploading;

  const AudioChatMessage({
    this.mediaId,
    this.audioUrl,
    this.durationMs,
    this.waveform,
    this.isUploading = false,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation,
    super.isFirstInGroup,
    super.isLastInGroup,
    super.forwardInfo,
    super.reactions,
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
      audioUrl: audioUrl,
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
      forwardInfo: forwardInfo,
      reactions: reactions,
    );
  }
}

final class VideoChatMessage extends ChatMessage {
  final String? thumbnailPath;
  final String? videoUrl;
  final String? mediaId;
  final String? thumbMediaId;
  final int? durationMs;
  final bool isUploading;
  final bool isResolvingImage;
  final bool isResolvingVideo;

  const VideoChatMessage({
    this.thumbnailPath,
    this.videoUrl,
    this.mediaId,
    this.thumbMediaId,
    this.durationMs,
    this.isUploading = false,
    this.isResolvingImage = false,
    this.isResolvingVideo = false,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation,
    super.isFirstInGroup,
    super.isLastInGroup,
    super.forwardInfo,
    super.reactions,
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
      videoUrl: videoUrl,
      mediaId: mediaId,
      thumbMediaId: thumbMediaId,
      durationMs: durationMs,
      isUploading: isUploading,
      isResolvingImage: isResolvingImage,
      isResolvingVideo: isResolvingVideo,
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
      forwardInfo: forwardInfo,
      reactions: reactions,
    );
  }
}

final class StickerChatMessage extends ChatMessage {
  final String? stickerId;
  final String? stickerPath;

  const StickerChatMessage({
    this.stickerId,
    this.stickerPath,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation,
    super.isFirstInGroup,
    super.isLastInGroup,
    super.forwardInfo,
    super.reactions,
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
      forwardInfo: forwardInfo,
      reactions: reactions,
    );
  }
}

final class FileChatMessage extends ChatMessage {
  final String? fileName;
  final String? mediaId;
  final int? fileSize;
  final bool isUploading;
  final bool isDownloading;

  const FileChatMessage({
    this.fileName,
    this.mediaId,
    this.fileSize,
    this.isUploading = false,
    this.isDownloading = false,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation,
    super.isFirstInGroup,
    super.isLastInGroup,
    super.forwardInfo,
    super.reactions,
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
      forwardInfo: forwardInfo,
      reactions: reactions,
    );
  }
}

final class ContactCardChatMessage extends ChatMessage {
  final String cardType;
  final String contactUserId;
  final String clientMessageId;

  const ContactCardChatMessage({
    required this.cardType,
    required this.contactUserId,
    required this.clientMessageId,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation,
    super.isFirstInGroup,
    super.isLastInGroup,
    super.forwardInfo,
    super.reactions,
  });

  @override
  String get type => 'contact_card';

  @override
  ContactCardChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return ContactCardChatMessage(
      cardType: cardType,
      contactUserId: contactUserId,
      clientMessageId: clientMessageId,
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
      forwardInfo: forwardInfo,
      reactions: reactions,
    );
  }
}

final class UnknownChatMessage extends ChatMessage {
  final String? content;

  const UnknownChatMessage({
    this.content,
    required super.isSentByMe,
    super.senderId,
    required super.timestamp,
    super.isDeleted,
    super.localId,
    super.serverId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.conversationAvatarUrl,
    super.isGroupConversation,
    super.isFirstInGroup,
    super.isLastInGroup,
    super.forwardInfo,
    super.reactions,
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
      forwardInfo: forwardInfo,
      reactions: reactions,
    );
  }
}

final class SystemChatMessage extends ChatMessage {
  final String text;
  final String? action;

  const SystemChatMessage({
    required this.text,
    this.action,
    required super.timestamp,
    super.localId,
    super.serverId,
    super.senderId,
  }) : super(
         isSentByMe: false,
         isDeleted: false,
         isGroupConversation: false,
         isFirstInGroup: true,
         isLastInGroup: true,
         reactions: const <ChatMessageReaction>[],
       );

  @override
  String get type => 'system';

  @override
  SystemChatMessage copyWithGrouping({
    bool? isFirstInGroup,
    bool? isLastInGroup,
  }) {
    return SystemChatMessage(
      text: text,
      action: action,
      timestamp: timestamp,
      localId: localId,
      serverId: serverId,
      senderId: senderId,
    );
  }
}
