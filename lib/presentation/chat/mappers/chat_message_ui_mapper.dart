import 'package:flutter/foundation.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message_reaction.dart';
import 'package:flutter_chat/presentation/chat/utils/message_helpers.dart';
import 'dart:io';

class ChatMessageUIMapper {
  final MessageHelpers _helpers = MessageHelpers();

  static const Duration _groupingWindow = Duration(minutes: 1);

  List<ChatMessage> mapStateMessagesToUI(
    List<Message> messages,
    Set<String> uploadingImagePaths,
    Map<String, String> imageUrlsByMediaId,
    Map<String, String> audioUrlsByMediaId,
    Set<String> resolvingImageMediaIds,
    String? currentUserId,
    Map<String, String> senderDisplayNameByUserId,
    Map<String, String> senderAvatarUrlByUserId,
    bool isGroupConversation,
    String? conversationAvatarUrl,
    String deletedMessageText,
  ) {
    final normalizedCurrentUserId = _normalizeId(currentUserId);

    final mappedMessages = messages
        .map(
          (message) {
            final normalizedSenderId = _normalizeId(message.senderId);
            final isSentByMe = normalizedCurrentUserId.isNotEmpty &&
                normalizedSenderId == normalizedCurrentUserId;
            final senderDisplayName = senderDisplayNameByUserId[normalizedSenderId];
            final senderAvatarUrl = senderAvatarUrlByUserId[normalizedSenderId];
            
            if (message.isDeleted) {
<<<<<<< feature/integrate-emoji
              _logMessageMediaDebug(
                message: message,
                mediaId: null,
                metadataMediaId: _extractMetadataMediaId(message.metadata),
                resolvedAudioUrl: null,
              );

              return ChatMessage(
=======
              return TextChatMessage(
>>>>>>> main
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

<<<<<<< feature/integrate-emoji
            final isImageLikeMessage = _helpers.isImageLikeMessage(message);
            final isStickerMessage = _helpers.isStickerMessage(message);
            final mediaId = message.mediaId?.trim();
            final stickerUrl = _helpers.extractStickerUrl(message);
            final stickerId = _helpers.extractStickerId(message);
            final localPath = _helpers.isLikelyLocalImagePath(message.content) ? message.content : null;
            final audioMetadata = message.metadata;
            final metadataMediaId = _extractMetadataMediaId(audioMetadata);
            final audioDurationSeconds = _extractAudioDurationSeconds(audioMetadata);
            final audioWaveform = _parseWaveform(audioMetadata?['waveform']);
            final audioUrl = _resolveAudioUrl(
              message: message,
              mediaId: mediaId,
              audioUrlsByMediaId: audioUrlsByMediaId,
            );

            _logMessageMediaDebug(
              message: message,
              mediaId: mediaId,
              metadataMediaId: metadataMediaId,
              resolvedAudioUrl: audioUrl,
            );

            final resolvedRemoteUrl = mediaId != null && mediaId.isNotEmpty
                ? imageUrlsByMediaId[mediaId]
                : null;
            final imagePath = isStickerMessage
                ? stickerUrl
                : isImageLikeMessage
                ? (resolvedRemoteUrl ?? localPath)
                : null;
            final reactions = _extractReactions(message.metadata);

            return ChatMessage(
              text: imagePath == null && !isImageLikeMessage && !isStickerMessage ? message.content : null,
              imagePath: imagePath,
              mediaId: mediaId,
              stickerId: stickerId,
              audioUrl: audioUrl,
              audioDurationSeconds: audioDurationSeconds,
              audioWaveform: audioWaveform,
              type: message.type,
              isSentByMe: currentUserId != null && message.senderId == currentUserId,
              senderId: message.senderId,
              timestamp: message.createdAt,
              isDeleted: message.isDeleted,
              isUploading: localPath != null && uploadingImagePaths.contains(localPath),
              isResolvingImage: isImageLikeMessage &&
                  imagePath == null &&
                  mediaId != null &&
                  mediaId.isNotEmpty &&
                  resolvingImageMediaIds.contains(mediaId),
              localId: message.id,
              serverId: message.serverId,
              conversationAvatarUrl: conversationAvatarUrl,
              reactions: reactions,
=======
            final reactions = message.reactions
                .map(
                  (item) => ChatMessageReaction(
                    emoji: item.emoji,
                    count: item.count,
                    myReaction: item.myReaction,
                  ),
                )
                .where((reaction) => reaction.emoji.trim().isNotEmpty && reaction.count > 0)
                .toList(growable: false);

            final baseParams = {
              'isSentByMe': isSentByMe,
              'senderId': normalizedSenderId,
              'timestamp': message.createdAt,
              'isDeleted': message.isDeleted,
              'localId': message.id,
              'serverId': message.serverId,
              'senderDisplayName': senderDisplayName,
              'senderAvatarUrl': senderAvatarUrl,
              'conversationAvatarUrl': conversationAvatarUrl,
              'isGroupConversation': isGroupConversation,
              'reactions': reactions,
            };

            return _createMessageByType(
              message,
              uploadingImagePaths,
              imageUrlsByMediaId,
              resolvingImageMediaIds,
              baseParams,
>>>>>>> main
            );
          },
        )
        .toList();

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

  List<ChatMessage> _applyGrouping(List<ChatMessage> messages) {
    if (messages.isEmpty) return messages;

    final result = <ChatMessage>[];

    for (var i = 0; i < messages.length; i++) {
      final current = messages[i];
      final prev = i > 0 ? messages[i - 1] : null;
      final next = i < messages.length - 1 ? messages[i + 1] : null;

      final bool sameAsPrev = prev != null &&
          _normalizeId(prev.senderId) == _normalizeId(current.senderId) &&
          current.timestamp.difference(prev.timestamp) <= _groupingWindow;

      final bool sameAsNext = next != null &&
          _normalizeId(next.senderId) == _normalizeId(current.senderId) &&
          next.timestamp.difference(current.timestamp) <= _groupingWindow;

      result.add(current.copyWithGrouping(
        isFirstInGroup: !sameAsPrev,
        isLastInGroup: !sameAsNext,
      ));
    }

    return result;
  }

  ChatMessage _createMessageByType(
    Message domainMessage,
    Set<String> uploadingImagePaths,
    Map<String, String> imageUrlsByMediaId,
    Set<String> resolvingImageMediaIds,
    Map<String, dynamic> baseParams,
  ) {
    final bool isSentByMe = baseParams['isSentByMe'] as bool;
    final String senderId = baseParams['senderId'] as String;
    final DateTime timestamp = baseParams['timestamp'] as DateTime;
    final bool isDeleted = baseParams['isDeleted'] as bool;
    final String? localId = baseParams['localId'] as String?;
    final String? serverId = baseParams['serverId'] as String?;
    final String? senderDisplayName = baseParams['senderDisplayName'] as String?;
    final String? senderAvatarUrl = baseParams['senderAvatarUrl'] as String?;
    final String? conversationAvatarUrl = baseParams['conversationAvatarUrl'] as String?;
    final bool isGroupConversation = baseParams['isGroupConversation'] as bool;
    final List<ChatMessageReaction> reactions = baseParams['reactions'] as List<ChatMessageReaction>;

    if (domainMessage is TextMessage) {
      return TextChatMessage(
        text: domainMessage.content,
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
        isUploading: localPath != null && uploadingImagePaths.contains(localPath),
        isResolvingImage: imagePath == null &&
            mediaId != null &&
            mediaId.isNotEmpty &&
            resolvingImageMediaIds.contains(mediaId),
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
        reactions: reactions,
      );
    }

    if (domainMessage is AudioMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.media;

      return AudioChatMessage(
        mediaId: mediaId,
        durationMs: media.durationMs,
        waveform: media.waveform,
        isUploading: false,
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
        reactions: reactions,
      );
    }

    if (domainMessage is VideoMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.media;
      final thumbnailPath = media.url;

      return VideoChatMessage(
        thumbnailPath: thumbnailPath,
        mediaId: mediaId,
        durationMs: media.durationMs,
        isUploading: false,
        isResolvingImage: false,
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
        isDeleted: isDeleted,
        localId: localId,
        serverId: serverId,
        senderDisplayName: senderDisplayName,
        senderAvatarUrl: senderAvatarUrl,
        conversationAvatarUrl: conversationAvatarUrl,
        isGroupConversation: isGroupConversation,
        reactions: reactions,
      );
    }

    if (domainMessage is FileMessage) {
      final mediaId = domainMessage.mediaId?.trim();
      final media = domainMessage.medias.isNotEmpty ? domainMessage.medias.first : null;
      final fileName = media?.url?.split('/').last ?? 'File';

      return FileChatMessage(
        fileName: fileName,
        mediaId: mediaId,
        fileSize: media?.size?.toInt(),
        isUploading: false,
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
        reactions: reactions,
      );
    }

    // Fallback for unknown message types
    return UnknownChatMessage(
      content: domainMessage.content,
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
      reactions: reactions,
    );
  }

  String _normalizeId(String? value) {
    return value?.trim() ?? '';
  }

  void _logMessageMediaDebug({
    required Message message,
    required String? mediaId,
    required String? metadataMediaId,
    required String? resolvedAudioUrl,
  }) {
    assert(() {
      debugPrint(
        '[ChatMessageUIMapper] load message '
        'id=${message.id} type=${message.type} '
        'topMediaId=${mediaId ?? 'null'} '
        'metadataMediaId=${metadataMediaId ?? 'null'} '
        'hasTopMediaId=${mediaId != null && mediaId.isNotEmpty} '
        'hasMetadataMediaId=${metadataMediaId != null && metadataMediaId.isNotEmpty} '
        'resolvedAudioUrl=${resolvedAudioUrl ?? 'null'}',
      );
      return true;
    }());
  }

  String? _extractMetadataMediaId(Map<String, dynamic>? metadata) {
    if (metadata == null) {
      return null;
    }

    final direct = metadata['mediaId'];
    if (direct is String && direct.trim().isNotEmpty) {
      return direct.trim();
    }

    final snakeCase = metadata['media_id'];
    if (snakeCase is String && snakeCase.trim().isNotEmpty) {
      return snakeCase.trim();
    }

    return null;
  }

  int? _extractAudioDurationSeconds(Map<String, dynamic>? metadata) {
    if (metadata == null) {
      return null;
    }

    final durationMs = _toInt(metadata['durationMs']);
    if (durationMs == null || durationMs < 0) {
      return null;
    }

    return (durationMs / 1000).round();
  }

  List<double> _parseWaveform(dynamic value) {
    if (value is! List) {
      return const <double>[];
    }

    return value
        .map((item) {
          if (item is double) return item;
          if (item is int) return item.toDouble();
          if (item is num) return item.toDouble();
          if (item is String) return double.tryParse(item) ?? 0.0;
          return 0.0;
        })
        .toList(growable: false);
  }

  String? _resolveAudioUrl({
    required Message message,
    required String? mediaId,
    required Map<String, String> audioUrlsByMediaId,
  }) {
    if (mediaId != null && mediaId.isNotEmpty) {
      final resolvedAudioUrl = audioUrlsByMediaId[mediaId];
      if (resolvedAudioUrl != null && resolvedAudioUrl.trim().isNotEmpty) {
        return resolvedAudioUrl.trim();
      }
    }

    final metadata = message.metadata;
    if (metadata == null) {
      return null;
    }

    final localAudioPath = metadata['localAudioPath'];
    if (localAudioPath is! String) {
      return null;
    }

    final normalized = localAudioPath.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(normalized);
    final isRemote = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isRemote) {
      return normalized;
    }

    return File(normalized).existsSync() ? normalized : null;
  }
}
