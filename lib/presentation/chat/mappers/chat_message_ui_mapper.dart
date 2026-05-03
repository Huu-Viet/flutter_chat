import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message_reaction.dart';
import 'package:flutter_chat/presentation/chat/utils/message_helpers.dart';

class ChatMessageUIMapper {
  final MessageHelpers _helpers = MessageHelpers();
  static const Duration _groupingWindow = Duration(minutes: 1);

  List<ChatMessage> mapStateMessagesToUI(
    List<Message> messages,
    Set<String> uploadingImagePaths,
    Map<String, String> imageUrlsByMediaId,
    Map<String, String> audioUrlsByMediaId,
    Map<String, String> videoUrlsByMediaId,
    Set<String> resolvingImageMediaIds,
    Set<String> resolvingAudioMediaIds,
    Set<String> resolvingVideoMediaIds,
    String? currentUserId,
    Map<String, String> senderDisplayNameByUserId,
    Map<String, String> senderAvatarUrlByUserId,
    bool isGroupConversation,
    String? conversationAvatarUrl,
    String deletedMessageText,
  ) {
    final normalizedCurrentUserId = _normalizeId(currentUserId);
    final messageById = <String, Message>{
      for (final msg in messages) ...{
        if (_normalizeId(msg.id).isNotEmpty) _normalizeId(msg.id): msg,
        if (_normalizeId(msg.serverId).isNotEmpty)
          _normalizeId(msg.serverId): msg,
      },
    };

    final mappedMessages = messages.map((message) {
      final normalizedSenderId = _normalizeId(message.senderId);
      final isSentByMe =
          normalizedCurrentUserId.isNotEmpty &&
          normalizedSenderId == normalizedCurrentUserId;
      final senderDisplayName = senderDisplayNameByUserId[normalizedSenderId];
      final senderAvatarUrl = senderAvatarUrlByUserId[normalizedSenderId];

      if (message.isDeleted || message.isRevoked) {
        return TextChatMessage(
          text: deletedMessageText,
          isSentByMe: isSentByMe,
          senderId: normalizedSenderId,
          senderDisplayName: senderDisplayName,
          senderAvatarUrl: senderAvatarUrl,
          timestamp: message.createdAt,
          isDeleted: true,
          localId: message.id,
          serverId: message.serverId,
          conversationAvatarUrl: conversationAvatarUrl,
          isGroupConversation: isGroupConversation,
        );
      }

      final reactions = message.reactions
          .map(
            (item) => ChatMessageReaction(
              emoji: item.emoji,
              count: item.count,
              myReaction: item.myReaction,
            ),
          )
          .where(
            (reaction) =>
                reaction.emoji.trim().isNotEmpty && reaction.count > 0,
          )
          .toList(growable: false);

      return _createMessageByType(
        domainMessage: message,
        messageById: messageById,
        uploadingImagePaths: uploadingImagePaths,
        imageUrlsByMediaId: imageUrlsByMediaId,
        audioUrlsByMediaId: audioUrlsByMediaId,
        videoUrlsByMediaId: videoUrlsByMediaId,
        resolvingImageMediaIds: resolvingImageMediaIds,
        resolvingAudioMediaIds: resolvingAudioMediaIds,
        resolvingVideoMediaIds: resolvingVideoMediaIds,
        isSentByMe: isSentByMe,
        senderId: normalizedSenderId,
        senderDisplayName: senderDisplayName,
        senderDisplayNameByUserId: senderDisplayNameByUserId,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }).toList();

    final existingImagePaths = mappedMessages
        .whereType<ImageChatMessage>()
        .where((message) => message.imagePath != null)
        .map((message) => message.imagePath!)
        .toSet();

    for (final imagePath in uploadingImagePaths) {
      if (existingImagePaths.contains(imagePath)) {
        continue;
      }

      mappedMessages.add(
        ImageChatMessage(
          imagePath: imagePath,
          mediaId: null,
          isUploading: true,
          isSentByMe: true,
          timestamp: DateTime.now(),
          conversationAvatarUrl: conversationAvatarUrl,
          isGroupConversation: isGroupConversation,
        ),
      );
    }

    return _applyGrouping(mappedMessages);
  }

  ChatMessage _createMessageByType({
    required Message domainMessage,
    required Map<String, Message> messageById,
    required Set<String> uploadingImagePaths,
    required Map<String, String> imageUrlsByMediaId,
    required Map<String, String> audioUrlsByMediaId,
    required Map<String, String> videoUrlsByMediaId,
    required Set<String> resolvingImageMediaIds,
    required Set<String> resolvingAudioMediaIds,
    required Set<String> resolvingVideoMediaIds,
    required bool isSentByMe,
    required String senderId,
    required String? senderDisplayName,
    required Map<String, String> senderDisplayNameByUserId,
    required String? senderAvatarUrl,
    required String? conversationAvatarUrl,
    required bool isGroupConversation,
    required List<ChatMessageReaction> reactions,
  }) {
    final timestamp = domainMessage.createdAt;

    if (domainMessage is TextMessage) {
      final replyPreview = _buildReplyPreview(
        replyToId: domainMessage.replyToId,
        messageById: messageById,
        senderDisplayNameByUserId: senderDisplayNameByUserId,
      );

      return TextChatMessage(
        text: domainMessage.content,
        replyToId: domainMessage.replyToId,
        replyPreview: replyPreview,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        forwardInfo: domainMessage.forwardInfo,
        reactions: reactions,
      );
    }

    if (domainMessage is ImageMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final localPath = _helpers.isLikelyLocalImagePath(domainMessage.content)
          ? domainMessage.content
          : null;
      final resolvedRemoteUrl = mediaId != null && mediaId.isNotEmpty
          ? imageUrlsByMediaId[mediaId]
          : null;
      final imagePath = resolvedRemoteUrl ?? localPath;

      return ImageChatMessage(
        imagePath: imagePath,
        mediaId: mediaId,
        isUploading:
            localPath != null && uploadingImagePaths.contains(localPath),
        isResolvingImage:
            imagePath == null &&
            mediaId != null &&
            mediaId.isNotEmpty &&
            resolvingImageMediaIds.contains(mediaId),
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        forwardInfo: domainMessage.forwardInfo,
        reactions: reactions,
      );
    }

    if (domainMessage is AudioMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.media;
      final resolvedAudioUrl = mediaId != null && mediaId.isNotEmpty
          ? audioUrlsByMediaId[mediaId]
          : null;
      final audioUrl =
          (resolvedAudioUrl != null && resolvedAudioUrl.trim().isNotEmpty)
          ? resolvedAudioUrl.trim()
          : media.url;

      return AudioChatMessage(
        mediaId: mediaId,
        audioUrl: audioUrl,
        durationMs: media.durationMs,
        waveform: media.waveform,
        isUploading: false,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        forwardInfo: domainMessage.forwardInfo,
        reactions: reactions,
      );
    }

    if (domainMessage is VideoMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.media;
      final thumbMediaId = media.thumbMediaId?.trim();
      final resolvedThumbUrl = thumbMediaId != null && thumbMediaId.isNotEmpty
          ? imageUrlsByMediaId[thumbMediaId]
          : null;
      final thumbnailPath =
          (resolvedThumbUrl != null && resolvedThumbUrl.trim().isNotEmpty)
          ? resolvedThumbUrl.trim()
          : null;

      final resolvedVideoUrl = mediaId != null && mediaId.isNotEmpty
          ? videoUrlsByMediaId[mediaId]
          : null;
      final videoUrl =
          (resolvedVideoUrl != null && resolvedVideoUrl.trim().isNotEmpty)
          ? resolvedVideoUrl.trim()
          : media.url;

      return VideoChatMessage(
        thumbnailPath: thumbnailPath,
        videoUrl: videoUrl,
        mediaId: mediaId,
        thumbMediaId: thumbMediaId,
        durationMs: media.durationMs,
        isUploading: false,
        isResolvingImage:
            mediaId != null &&
            mediaId.isNotEmpty &&
            thumbMediaId != null &&
            thumbMediaId.isNotEmpty &&
            thumbnailPath == null &&
            resolvingImageMediaIds.contains(thumbMediaId),
        isResolvingVideo:
            mediaId != null &&
            mediaId.isNotEmpty &&
            (videoUrl == null || videoUrl.trim().isEmpty) &&
            resolvingVideoMediaIds.contains(mediaId),
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        forwardInfo: domainMessage.forwardInfo,
        reactions: reactions,
      );
    }

    if (domainMessage is StickerMessage) {
      return StickerChatMessage(
        stickerId: domainMessage.stickerId,
        stickerPath: domainMessage.stickerUrl,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    if (domainMessage is FileMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.medias.isNotEmpty
          ? domainMessage.medias.first
          : null;
      // Extract fileName from media first, fallback to caption (which stores fileName)
      final fileName = media?.fileName?.trim().isEmpty == false
          ? media?.fileName?.trim()
          : (domainMessage.caption?.trim().isEmpty == false
                ? domainMessage.caption
                : null);

      return FileChatMessage(
        fileName: fileName,
        mediaId: mediaId,
        fileSize: media?.size?.toInt(),
        isUploading: false,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        forwardInfo: domainMessage.forwardInfo,
        reactions: reactions,
      );
    }

    if (domainMessage is ContactCardMessage) {
      return ContactCardChatMessage(
        cardType: domainMessage.cardType,
        contactUserId: domainMessage.contactUserId,
        clientMessageId: domainMessage.clientMessageId,
        isSentByMe: isSentByMe,
        senderId: senderId,
        timestamp: timestamp,
        isDeleted: domainMessage.isDeleted,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        forwardInfo: domainMessage.forwardInfo,
        reactions: reactions,
      );
    }

    if (domainMessage is SystemMessage) {
      return SystemChatMessage(
        text: _buildSystemText(domainMessage),
        action: domainMessage.action,
        timestamp: timestamp,
        localId: domainMessage.id,
        serverId: domainMessage.serverId,
        senderId: senderId,
      );
    }

    return UnknownChatMessage(
      content: domainMessage.content,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: timestamp,
      isDeleted: domainMessage.isDeleted,
      localId: domainMessage.id,
      serverId: domainMessage.serverId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      forwardInfo: domainMessage.forwardInfo,
      reactions: reactions,
    );
  }

  List<ChatMessage> _applyGrouping(List<ChatMessage> messages) {
    if (messages.isEmpty) return messages;

    final result = <ChatMessage>[];

    for (var i = 0; i < messages.length; i++) {
      final current = messages[i];
      final prev = i > 0 ? messages[i - 1] : null;
      final next = i < messages.length - 1 ? messages[i + 1] : null;

      final sameAsPrev =
          prev != null &&
          _normalizeId(prev.senderId) == _normalizeId(current.senderId) &&
          current.timestamp.difference(prev.timestamp) <= _groupingWindow;

      final sameAsNext =
          next != null &&
          _normalizeId(next.senderId) == _normalizeId(current.senderId) &&
          next.timestamp.difference(current.timestamp) <= _groupingWindow;

      result.add(
        current.copyWithGrouping(
          isFirstInGroup: !sameAsPrev,
          isLastInGroup: !sameAsNext,
        ),
      );
    }

    return result;
  }

  String _normalizeId(String? value) {
    return value?.trim() ?? '';
  }

  ReplyPreview? _buildReplyPreview({
    required String? replyToId,
    required Map<String, Message> messageById,
    required Map<String, String> senderDisplayNameByUserId,
  }) {
    final normalizedReplyToId = _normalizeId(replyToId);
    if (normalizedReplyToId.isEmpty) {
      return null;
    }

    final replied = messageById[normalizedReplyToId];
    if (replied == null) {
      return ReplyPreview(
        messageId: normalizedReplyToId,
        senderDisplay: 'Unknown',
        snippet: 'Original message',
      );
    }

    final repliedSenderId = _normalizeId(replied.senderId);
    final senderDisplay =
        senderDisplayNameByUserId[repliedSenderId]?.trim().isNotEmpty == true
        ? senderDisplayNameByUserId[repliedSenderId]!.trim()
        : repliedSenderId;

    final snippet = _snippetFromMessage(replied);
    return ReplyPreview(
      messageId: normalizedReplyToId,
      senderDisplay: senderDisplay.isEmpty ? 'Unknown' : senderDisplay,
      snippet: snippet,
    );
  }

  String _snippetFromMessage(Message message) {
    if (message is SystemMessage) {
      final text = _buildSystemText(message).trim();
      return text.isNotEmpty ? text : '[System]';
    }

    if (message is TextMessage) {
      final text = message.content.trim();
      if (text.isNotEmpty) return text;
    }

    if (message is ImageMessage) return '[Image]';
    if (message is VideoMessage) return '[Video]';
    if (message is AudioMessage) return '[Audio]';
    if (message is FileMessage) return '[File]';
    if (message is StickerMessage) return '[Sticker]';
    if (message is ContactCardMessage) return '[Contact card]';

    final fallback = message.content.trim();
    return fallback.isNotEmpty ? fallback : '[Message]';
  }

  String _buildSystemText(SystemMessage message) {
    final metadata = message.metadata;
    final action = message.action.trim().toUpperCase();
    final actorName =
        _readString(metadata['actorName']) ??
        _readString(metadata['updatedByName']) ??
        'Someone';
    final targetNames = _readStringList(metadata['targetNames']);

    switch (action) {
      case 'MEMBER_ADDED':
        final actorId = _readString(metadata['actorId']) ?? '';
        final targetIds = _readStringList(metadata['targetIds']);
        final joinSource =
            _readString(metadata['joinVia']) ??
            _readString(metadata['source']) ??
            _readString(metadata['method']) ??
            _readString(metadata['joinMethod']);
        final isInviteJoin =
            (joinSource?.toLowerCase().contains('invite') ?? false) ||
            (targetIds.length == 1 &&
                actorId.isNotEmpty &&
                actorId == targetIds.first);

        if (isInviteJoin) {
          final joinedName = targetNames.isNotEmpty
              ? targetNames.first
              : actorName;
          return '$joinedName joined the group via invite link';
        }

        if (targetNames.isNotEmpty) {
          return '$actorName added ${targetNames.join(', ')} to the group';
        }
        return '$actorName added new member(s)';
      case 'MEMBER_LEFT':
        return '$actorName left the group';
      case 'MEMBER_REMOVED':
        if (targetNames.isNotEmpty) {
          return '$actorName removed ${targetNames.join(', ')} from the group';
        }
        return '$actorName removed a member';
      case 'MEMBER_KICKED':
        if (targetNames.isNotEmpty) {
          return '$actorName kicked ${targetNames.first} from the group';
        }
        return '$actorName kicked a member';
      case 'ROLE_CHANGED':
        final role = _readString(metadata['newRole']) ?? 'MEMBER';
        final target = targetNames.isNotEmpty ? targetNames.first : 'a member';
        return '$actorName made $target $role';
      case 'GROUP_INFO_UPDATED':
        final changes = metadata['changes'];
        if (changes is Map) {
          final map = changes.map((key, value) => MapEntry('$key', value));
          final changedName = _readString(map['name']);
          final avatarChanged = map['avatarChanged'] == true;
          if (changedName != null && avatarChanged) {
            return '$actorName updated the group info';
          }
          if (changedName != null) {
            return '$actorName renamed the group to "$changedName"';
          }
          if (avatarChanged) {
            return '$actorName changed the group photo';
          }
        }
        return '$actorName updated the group info';
      default:
        final fallback = message.content.trim();
        return fallback.isNotEmpty ? fallback : 'System activity';
    }
  }

  String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  List<String> _readStringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }
}
