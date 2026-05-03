import 'dart:convert';

import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/image_media.dart';
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
        currentUserId: normalizedCurrentUserId,
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
        .map((message) => message.imagePath!.trim())
        .where((path) => path.isNotEmpty)
        .toSet();

    final pendingUploadingPaths = uploadingImagePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty && !existingImagePaths.contains(path))
        .toList(growable: false);

    if (pendingUploadingPaths.isNotEmpty) {
      mappedMessages.add(
        ImageChatMessage(
          imagePath: pendingUploadingPaths.first,
          mediaId: null,
          imagePaths: pendingUploadingPaths,
          mediaIds: const <String>[],
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
    required String currentUserId,
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
      final mediaIds = domainMessage.medias
          .map((media) => media.mediaId.trim())
          .where((id) => id.isNotEmpty)
          .toList(growable: false);
      final mediaId = mediaIds.isNotEmpty ? mediaIds.first : null;
      final localPath = _helpers.isLikelyLocalImagePath(domainMessage.content)
          ? domainMessage.content
          : null;
      final imagePaths = mediaIds
          .map((id) => imageUrlsByMediaId[id]?.trim() ?? '')
          .toList(growable: false);
      if (imagePaths.isNotEmpty &&
          imagePaths.first.isEmpty &&
          localPath != null &&
          localPath.trim().isNotEmpty) {
        imagePaths[0] = localPath.trim();
      }
      final imagePath = imagePaths.firstWhere(
        (path) => path.trim().isNotEmpty,
        orElse: () => '',
      );
      final missingMediaIds = mediaIds
          .where((id) => !imageUrlsByMediaId.containsKey(id))
          .toList(growable: false);

      return ImageChatMessage(
        imagePath: imagePath.trim().isEmpty ? null : imagePath,
        mediaId: mediaId,
        imagePaths: imagePaths,
        mediaIds: mediaIds,
        isUploading:
            localPath != null && uploadingImagePaths.contains(localPath),
        isResolvingImage: missingMediaIds.any(resolvingImageMediaIds.contains),
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

    if (domainMessage is MultiMediaMessage) {
      final imageMedias = domainMessage.medias.whereType<ImageMedia>().toList(
        growable: false,
      );
      if (imageMedias.isNotEmpty) {
        final mediaIds = imageMedias
            .map((media) => media.mediaId.trim())
            .where((id) => id.isNotEmpty)
            .toList(growable: false);
        final mediaId = mediaIds.isNotEmpty ? mediaIds.first : null;
        final imagePaths = mediaIds
            .map((id) => imageUrlsByMediaId[id]?.trim() ?? '')
            .toList(growable: false);
        final imagePath = imagePaths.firstWhere(
          (path) => path.trim().isNotEmpty,
          orElse: () => '',
        );
        final missingMediaIds = mediaIds
            .where((id) => !imageUrlsByMediaId.containsKey(id))
            .toList(growable: false);

        return ImageChatMessage(
          imagePath: imagePath.trim().isEmpty ? null : imagePath,
          mediaId: mediaId,
          imagePaths: imagePaths,
          mediaIds: mediaIds,
          isUploading: false,
          isResolvingImage: missingMediaIds.any(
            resolvingImageMediaIds.contains,
          ),
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

    final pollMessage = _tryBuildPollMessage(
      domainMessage: domainMessage,
      isSentByMe: isSentByMe,
      senderId: senderId,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
      conversationAvatarUrl: conversationAvatarUrl,
      isGroupConversation: isGroupConversation,
      currentUserId: currentUserId,
      reactions: reactions,
    );
    if (pollMessage != null) {
      return pollMessage;
    }

    return UnknownChatMessage(
      content: domainMessage.content,
      rawType: domainMessage is UnknownMessage
          ? domainMessage.rawType
          : 'unknown',
      rawMetadata: domainMessage is UnknownMessage
          ? domainMessage.rawMetadata
          : const <String, dynamic>{},
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

    if (message is ImageMessage) {
      return message.medias.length > 1 ? '[Images]' : '[Image]';
    }
    if (message is MultiMediaMessage) {
      final imageCount = message.medias.whereType<ImageMedia>().length;
      if (imageCount > 1) return '[Images]';
      if (imageCount == 1) return '[Image]';
      return '[Media]';
    }
    if (message is VideoMessage) return '[Video]';
    if (message is AudioMessage) return '[Audio]';
    if (message is FileMessage) return '[File]';
    if (message is StickerMessage) return '[Sticker]';
    if (message is ContactCardMessage) return '[Contact card]';
    if (_isPollLikeUnknownMessage(message)) return '[Poll]';

    final fallback = message.content.trim();
    return fallback.isNotEmpty ? fallback : '[Message]';
  }

  PollChatMessage? _tryBuildPollMessage({
    required Message domainMessage,
    required bool isSentByMe,
    required String senderId,
    required String? senderDisplayName,
    required String? senderAvatarUrl,
    required String? conversationAvatarUrl,
    required bool isGroupConversation,
    required String currentUserId,
    required List<ChatMessageReaction> reactions,
  }) {
    final source = _extractPollSourceFromMessage(domainMessage);
    if (source == null) {
      return null;
    }

    final question =
        _readString(source['question']) ?? domainMessage.content.trim();
    final rawOptions =
        source['options'] ?? source['pollOptions'] ?? source['choices'];
    if (question.isEmpty || rawOptions is! List) {
      return null;
    }

    final options = rawOptions
        .whereType<Map>()
        .map((rawOption) {
          final option = rawOption.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          final voterIds = _readStringList(
            option['voterIds'] ?? option['voters'] ?? option['voter_ids'],
          );
          final voteCount =
              _readInt(
                option['voteCount'] ??
                    option['vote_count'] ??
                    option['votes'] ??
                    option['count'],
              ) ??
              voterIds.length;
          final isSelectedByMe =
              option['myVote'] == true ||
              option['selected'] == true ||
              option['isSelected'] == true ||
              (currentUserId.isNotEmpty && voterIds.contains(currentUserId));

          return PollChatOption(
            id: _readString(option['id']) ?? '',
            text:
                _readString(option['text']) ??
                _readString(option['label']) ??
                'Option',
            voteCount: voteCount,
            isSelectedByMe: isSelectedByMe,
          );
        })
        .where((option) => option.text.trim().isNotEmpty)
        .toList(growable: false);

    if (options.length < 2) {
      return null;
    }

    final pollTimestamp =
        _readDateTime(source['createdAt']) ??
        _readDateTime(source['created_at']) ??
        _readDateTime(source['timestamp']) ??
        domainMessage.createdAt;

    return PollChatMessage(
      pollId:
          _readString(source['id']) ??
          _readString(source['pollId']) ??
          domainMessage.id,
      question: question,
      options: options,
      multipleChoice:
          source['multipleChoice'] == true || source['multiple_choice'] == true,
      deadline: _readDateTime(source['deadline']),
      isClosed: source['isClosed'] == true || source['is_closed'] == true,
      isSentByMe: isSentByMe,
      senderId: senderId,
      timestamp: pollTimestamp,
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

  bool _isPollLikeUnknownMessage(Message message) {
    return _extractPollSourceFromMessage(message) != null;
  }

  Map<String, dynamic>? _extractPollSourceFromMessage(Message message) {
    if (message is UnknownMessage) {
      final source = _extractPollSource(message.rawMetadata);
      if (source != null) {
        return source;
      }

      final rawType = message.rawType.trim().toLowerCase();
      if (rawType == 'poll' || rawType == 'group:poll_created') {
        final contentSource = _extractPollSourceFromContent(message.content);
        if (contentSource != null) {
          return contentSource;
        }
      }
    }

    if (message is SystemMessage) {
      final source = _extractPollSource(message.metadata);
      if (source != null) {
        return source;
      }

      final contentSource = _extractPollSourceFromContent(message.content);
      if (contentSource != null) {
        return contentSource;
      }

      final action = message.action.trim().toUpperCase();
      if (action.contains('POLL')) {
        return _extractPollSource(<String, dynamic>{
          ...message.metadata,
          'type': 'poll',
        });
      }
    }

    if (message is TextMessage) {
      return _extractPollSourceFromContent(message.content);
    }

    return null;
  }

  Map<String, dynamic>? _extractPollSourceFromContent(String? content) {
    final text = content?.trim() ?? '';
    if (text.isEmpty || !(text.startsWith('{') || text.startsWith('['))) {
      return null;
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return _extractPollSource(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Map<String, dynamic>? _extractPollSource(Map<String, dynamic> metadata) {
    if (metadata.isEmpty) {
      return null;
    }

    final topLevelPolls = metadata['polls'];
    if (topLevelPolls is List && topLevelPolls.isNotEmpty) {
      final first = topLevelPolls.first;
      if (first is Map) {
        return first.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    final nested = metadata['poll'];
    if (nested is Map) {
      return nested.map((key, value) => MapEntry(key.toString(), value));
    }

    final nestedData = metadata['data'];
    if (nestedData is Map) {
      final map = nestedData.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      if (map.containsKey('poll')) {
        final innerPoll = map['poll'];
        if (innerPoll is Map) {
          return innerPoll.map((key, value) => MapEntry(key.toString(), value));
        }
      }

      final innerPolls = map['polls'];
      if (innerPolls is List && innerPolls.isNotEmpty) {
        final first = innerPolls.first;
        if (first is Map) {
          return first.map((key, value) => MapEntry(key.toString(), value));
        }
      }

      final hasPollShape =
          map.containsKey('pollId') ||
          map.containsKey('id') ||
          (map.containsKey('question') &&
              (map.containsKey('options') ||
                  map.containsKey('pollOptions') ||
                  map.containsKey('choices')));
      if (hasPollShape) {
        return map;
      }
    }

    final payload = metadata['payload'];
    if (payload is Map) {
      final map = payload.map((key, value) => MapEntry(key.toString(), value));

      if (map.containsKey('poll')) {
        final innerPoll = map['poll'];
        if (innerPoll is Map) {
          return innerPoll.map((key, value) => MapEntry(key.toString(), value));
        }
      }

      final innerPolls = map['polls'];
      if (innerPolls is List && innerPolls.isNotEmpty) {
        final first = innerPolls.first;
        if (first is Map) {
          return first.map((key, value) => MapEntry(key.toString(), value));
        }
      }

      final hasPollShape =
          map.containsKey('pollId') ||
          map.containsKey('id') ||
          map.containsKey('polls') ||
          (map.containsKey('question') &&
              (map.containsKey('options') ||
                  map.containsKey('pollOptions') ||
                  map.containsKey('choices')));
      if (hasPollShape) {
        return map;
      }
    }

    final rawType = metadata['type']?.toString().trim().toLowerCase();
    final kind = metadata['kind']?.toString().trim().toLowerCase();
    final looksLikePoll =
        rawType == 'poll' ||
        kind == 'poll' ||
        metadata.containsKey('pollId') ||
        metadata.containsKey('polls') ||
        (metadata.containsKey('question') &&
            (metadata.containsKey('options') ||
                metadata.containsKey('pollOptions') ||
                metadata.containsKey('choices')));

    if (!looksLikePoll) {
      return null;
    }

    return metadata;
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _readDateTime(dynamic value) {
    final text = _readString(value);
    if (text == null) return null;
    return DateTime.tryParse(text);
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
