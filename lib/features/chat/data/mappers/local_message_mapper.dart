import 'dart:convert';

import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/mappers/local_mapper.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/forward_info.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/audio_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/file_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/generic_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/image_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/message_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/video_media.dart';
import 'package:flutter_chat/features/chat/export.dart';

class LocalMessageMapper
    extends LocalMapper<ChatMessageWithMediasEntity, Message> {
  @override
  Message toDomain(ChatMessageWithMediasEntity entity) {
    final message = entity.message;
    final metadata = _decodeMetadata(message.metadata);
    final normalizedType = message.type.trim().toLowerCase();
    final reactions = _extractReactions(metadata, message.id);
    final isRevoked = message.isRevoked;
    final medias = entity.medias.map(_mapMediaEntity).toList(growable: false);
    final forwardInfo = entity.message.forwardInfoJson != null
        ? ForwardInfo.fromJson(jsonDecode(entity.message.forwardInfoJson!))
        : null;

    switch (normalizedType) {
      case 'system':
        return SystemMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          text: message.content,
          action: (metadata?['action'] ?? '').toString(),
          metadata: metadata ?? const <String, dynamic>{},
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
        );
      case 'contact_page':
      case 'contact_card':
        return ContactCardMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
          forwardInfo: forwardInfo,
          cardType: _extractContactCardType(
            metadata,
            entity.medias,
            normalizedType,
          ),
          contactUserId: _extractContactUserId(metadata, entity.medias),
          clientMessageId: _extractContactClientMessageId(
            metadata,
            entity.medias,
            message,
          ),
        );
      case 'text':
        return TextMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          text: message.content,
          replyToId: message.replyToId,
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
          forwardInfo: forwardInfo,
        );
      case 'sticker':
        return StickerMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          stickerUrl: _extractStickerUrl(metadata, medias),
          stickerId: _extractStickerId(metadata),
          stickerText: message.content,
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
          forwardInfo: forwardInfo,
        );
      case 'audio':
        return AudioMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          media: _toAudioMedia(medias),
          caption: message.content,
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
          forwardInfo: forwardInfo,
        );
      case 'video':
        return VideoMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          media: _toVideoMedia(medias),
          caption: message.content,
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
          forwardInfo: forwardInfo,
        );
      case 'image':
        return ImageMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          medias: _toImageMedias(medias),
          caption: message.content,
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
          forwardInfo: forwardInfo,
        );
      case 'file':
        return FileMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          medias: _toFileMedias(medias),
          caption: message.content,
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
          forwardInfo: forwardInfo,
        );
      case 'media':
        return MultiMediaMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          medias: medias,
          caption: message.content,
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
          forwardInfo: forwardInfo,
        );
      default:
        return UnknownMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          rawType: normalizedType,
          rawContent: message.content,
          rawAttachments: medias,
          rawMetadata: metadata ?? const <String, dynamic>{},
          offset: message.offset,
          isDeleted: message.isDeleted,
          isRevoked: isRevoked,
          serverId: message.serverId,
          createdAt:
              DateTime.tryParse(message.createdAt) ??
              DateTime.fromMillisecondsSinceEpoch(0),
          editedAt: message.editedAt == null
              ? null
              : DateTime.tryParse(message.editedAt!),
          reactions: reactions,
        );
    }
  }

  Map<String, dynamic> _forwardInfoToJson(ForwardInfo info) {
    return {
      'conversationId': info.conversationId,
      'senderId': info.senderId,
      'messageId': info.messageId,
      'content': info.content,
      'type': info.type,
    };
  }

  @override
  ChatMessageWithMediasEntity toEntity(Message domain) {
    final message = ChatMessageEntity(
      id: domain.id,
      conversationId: domain.conversationId,
      senderId: domain.senderId,
      content: domain.content,
      type: domain.type,
      offset: domain.offset,
      isDeleted: domain.isDeleted,
      isRevoked: domain.isRevoked,
      mediaId: domain.mediaId,
      metadata: _buildMetadata(domain),
      serverId: domain.serverId,
      createdAt: domain.createdAt.toUtc().toIso8601String(),
      editedAt: domain.editedAt?.toUtc().toIso8601String(),
      forwardInfoJson: domain.forwardInfo != null
          ? jsonEncode(_forwardInfoToJson(domain.forwardInfo!))
          : null,
      replyToId: domain is TextMessage ? domain.replyToId : null,
    );

    final medias = domain.attachments
        .asMap()
        .entries
        .where((entry) => entry.value.mediaId.trim().isNotEmpty)
        .map(
          (entry) => MessageMediaEntity(
            id: entry.value.mediaId.trim(),
            messageId: domain.id,
            mediaType: entry.value.type,
            url: entry.value.url,
            mimeType: entry.value.mimeType,
            fileName: entry.value.fileName,
            size: entry.value.size,
            durationMs: _durationMsOf(entry.value),
            bitrate: _bitrateOf(entry.value),
            codec: _codecOf(entry.value),
            format: _formatOf(entry.value),
            prefer: _preferOf(entry.value),
            status: _statusOf(entry.value),
            variantsReady: _variantsReadyOf(entry.value),
            thumbReady: _thumbReadyOf(entry.value),
            thumbMediaId: _thumbMediaIdOf(entry.value),
            width: _widthOf(entry.value),
            height: _heightOf(entry.value),
            waveform: _serializeWaveform(_waveformOf(entry.value)),
            orderIndex: entry.key,
          ),
        )
        .toList();

    if (domain is ContactCardMessage) {
      final fallbackMediaId = domain.contactUserId.trim().isNotEmpty
          ? domain.contactUserId.trim()
          : 'contact_${domain.id}';
      medias.add(
        MessageMediaEntity(
          id: fallbackMediaId,
          messageId: domain.id,
          mediaType: domain.type,
          url: null,
          mimeType: null,
          fileName: null,
          size: null,
          durationMs: 0,
          bitrate: 0,
          codec: null,
          format: null,
          prefer: null,
          status: null,
          variantsReady: null,
          thumbReady: null,
          thumbMediaId: null,
          width: null,
          height: null,
          waveform: null,
          orderIndex: medias.length,
          cardType: domain.cardType,
          contactUserId: domain.contactUserId,
          clientMessageId: domain.clientMessageId,
        ),
      );
    }

    return ChatMessageWithMediasEntity(message: message, medias: medias);
  }

  MessageMedia _mapMediaEntity(MessageMediaEntity media) {
    final normalizedType = media.mediaType.trim().toLowerCase();
    final waveform = _parseWaveform(media.waveform);
    switch (normalizedType) {
      case 'audio':
        return AudioMedia(
          id: media.id,
          url: media.url,
          mimeType: media.mimeType,
          fileName: media.fileName,
          size: media.size,
          durationMs: media.durationMs,
          waveform: waveform,
        );
      case 'video':
        return VideoMedia(
          id: media.id,
          url: media.url,
          mimeType: media.mimeType,
          fileName: media.fileName,
          size: media.size,
          durationMs: media.durationMs,
          bitrate: media.bitrate,
          codec: media.codec,
          format: media.format,
          prefer: media.prefer,
          status: media.status,
          variantsReady: media.variantsReady,
          thumbReady: media.thumbReady,
          thumbMediaId: media.thumbMediaId,
          width: media.width,
          height: media.height,
          waveform: waveform,
        );
      case 'image':
        return ImageMedia(
          id: media.id,
          url: media.url,
          mimeType: media.mimeType,
          fileName: media.fileName,
          size: media.size,
          width: media.width,
          height: media.height,
        );
      case 'file':
        return FileMedia(
          id: media.id,
          url: media.url,
          mimeType: media.mimeType,
          fileName: media.fileName,
          size: media.size,
          mediaType: media.mediaType,
        );
      default:
        return GenericMedia(
          id: media.id,
          mediaType: normalizedType.isEmpty ? 'file' : normalizedType,
          url: media.url,
          mimeType: media.mimeType,
          fileName: media.fileName,
          size: media.size,
          durationMs: media.durationMs,
          bitrate: media.bitrate,
          width: media.width,
          height: media.height,
        );
    }
  }

  AudioMedia _toAudioMedia(List<MessageMedia> medias) {
    if (medias.isNotEmpty && medias.first is AudioMedia) {
      return medias.first as AudioMedia;
    }
    final first = medias.isEmpty ? null : medias.first;
    return AudioMedia(
      id: first?.mediaId ?? '',
      url: first?.url,
      mimeType: first?.mimeType,
      fileName: first?.fileName,
      size: first?.size,
      durationMs: first is GenericMedia ? first.durationMs : null,
    );
  }

  VideoMedia _toVideoMedia(List<MessageMedia> medias) {
    if (medias.isNotEmpty && medias.first is VideoMedia) {
      return medias.first as VideoMedia;
    }
    final first = medias.isEmpty ? null : medias.first;
    return VideoMedia(
      id: first?.mediaId ?? '',
      url: first?.url,
      mimeType: first?.mimeType,
      fileName: first?.fileName,
      size: first?.size,
      durationMs: first is VideoMedia
          ? first.durationMs
          : first is GenericMedia
          ? (first.durationMs ?? 0)
          : 0,
      bitrate: first is VideoMedia
          ? first.bitrate
          : first is GenericMedia
          ? (first.bitrate ?? 0)
          : 0,
      codec: first is VideoMedia ? first.codec : null,
      format: first is VideoMedia ? first.format : null,
      prefer: first is VideoMedia ? first.prefer : null,
      status: first is VideoMedia ? first.status : null,
      variantsReady: first is VideoMedia ? first.variantsReady : null,
      thumbReady: first is VideoMedia ? first.thumbReady : null,
      thumbMediaId: first is VideoMedia ? first.thumbMediaId : null,
      width: first is VideoMedia
          ? first.width
          : first is GenericMedia
          ? first.width
          : null,
      height: first is VideoMedia
          ? first.height
          : first is GenericMedia
          ? first.height
          : null,
    );
  }

  List<ImageMedia> _toImageMedias(List<MessageMedia> medias) {
    return medias.whereType<ImageMedia>().toList(growable: false);
  }

  List<FileMedia> _toFileMedias(List<MessageMedia> medias) {
    return medias.whereType<FileMedia>().toList(growable: false);
  }

  List<MessageReaction> _extractReactions(
    Map<String, dynamic>? metadata,
    String fallbackMessageId,
  ) {
    if (metadata == null) {
      return const <MessageReaction>[];
    }

    final raw = metadata['reactions'];
    if (raw is! List) {
      return const <MessageReaction>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (entry) => entry.map((key, value) => MapEntry(key.toString(), value)),
        )
        .map(
          (entry) => MessageReaction(
            messageId: (entry['messageId'] ?? fallbackMessageId).toString(),
            emoji: (entry['emoji'] ?? '').toString(),
            count: _toInt(entry['count']) ?? 0,
            reactors:
                (entry['reactors'] as List?)
                    ?.map((reactor) => reactor.toString())
                    .toList(growable: false) ??
                const <String>[],
            myReaction: entry['myReaction'] == true,
          ),
        )
        .where(
          (reaction) => reaction.emoji.trim().isNotEmpty && reaction.count > 0,
        )
        .toList(growable: false);
  }

  String? _buildMetadata(Message message) {
    final metadata = <String, dynamic>{};

    if (message is UnknownMessage) {
      metadata.addAll(message.rawMetadata);
    }

    if (message is SystemMessage) {
      metadata.addAll(message.metadata);
      if (message.action.trim().isNotEmpty) {
        metadata['action'] = message.action.trim();
      }
    }

    if (message is StickerMessage) {
      metadata['url'] = message.stickerUrl;
      if (message.stickerId != null && message.stickerId!.trim().isNotEmpty) {
        metadata['stickerId'] = message.stickerId!.trim();
      }
    }

    if (message.reactions.isNotEmpty) {
      metadata['reactions'] = message.reactions
          .map(
            (reaction) => <String, dynamic>{
              'messageId': reaction.messageId,
              'emoji': reaction.emoji,
              'count': reaction.count,
              'reactors': reaction.reactors,
              'myReaction': reaction.myReaction,
            },
          )
          .toList(growable: false);
    }

    if (metadata.isEmpty) {
      return null;
    }

    return jsonEncode(metadata);
  }

  String _extractStickerUrl(
    Map<String, dynamic>? metadata,
    List<MessageMedia> medias,
  ) {
    final candidate = metadata?['url']?.toString().trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }

    if (medias.isNotEmpty &&
        medias.first.url != null &&
        medias.first.url!.trim().isNotEmpty) {
      return medias.first.url!.trim();
    }

    return '';
  }

  String? _extractStickerId(Map<String, dynamic>? metadata) {
    final id = metadata?['stickerId']?.toString().trim();
    if (id == null || id.isEmpty) {
      return null;
    }
    return id;
  }

  Map<String, dynamic>? _decodeMetadata(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  MessageMediaEntity? _contactMedia(List<MessageMediaEntity> medias) {
    for (final media in medias) {
      final type = media.mediaType.trim().toLowerCase();
      if (type == 'contact_page' || type == 'contact_card') {
        return media;
      }
    }
    return null;
  }

  String _extractContactCardType(
    Map<String, dynamic>? metadata,
    List<MessageMediaEntity> medias,
    String fallbackType,
  ) {
    final fromMetadata =
        metadata?['cardType']?.toString().trim() ??
        metadata?['card_type']?.toString().trim();
    if (fromMetadata != null && fromMetadata.isNotEmpty) {
      return fromMetadata;
    }

    final fromMedia = _contactMedia(medias)?.cardType?.trim();
    if (fromMedia != null && fromMedia.isNotEmpty) {
      return fromMedia;
    }

    return fallbackType;
  }

  String _extractContactUserId(
    Map<String, dynamic>? metadata,
    List<MessageMediaEntity> medias,
  ) {
    final fromMetadata =
        metadata?['contactUserId']?.toString().trim() ??
        metadata?['contact_user_id']?.toString().trim() ??
        metadata?['userId']?.toString().trim() ??
        metadata?['user_id']?.toString().trim();
    if (fromMetadata != null && fromMetadata.isNotEmpty) {
      return fromMetadata;
    }

    final fromMedia = _contactMedia(medias)?.contactUserId?.trim();
    if (fromMedia != null && fromMedia.isNotEmpty) {
      return fromMedia;
    }

    return '';
  }

  String _extractContactClientMessageId(
    Map<String, dynamic>? metadata,
    List<MessageMediaEntity> medias,
    ChatMessageEntity message,
  ) {
    final fromMetadata =
        metadata?['clientMessageId']?.toString().trim() ??
        metadata?['client_message_id']?.toString().trim();
    if (fromMetadata != null && fromMetadata.isNotEmpty) {
      return fromMetadata;
    }

    final fromMedia = _contactMedia(medias)?.clientMessageId?.trim();
    if (fromMedia != null && fromMedia.isNotEmpty) {
      return fromMedia;
    }

    return message.serverId?.trim() ?? '';
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  int _durationMsOf(MessageMedia media) {
    if (media is AudioMedia) return media.durationMs ?? 0;
    if (media is VideoMedia) return media.durationMs;
    if (media is GenericMedia) return media.durationMs ?? 0;
    return 0;
  }

  int _bitrateOf(MessageMedia media) {
    if (media is VideoMedia) return media.bitrate;
    if (media is GenericMedia) return media.bitrate ?? 0;
    return 0;
  }

  String? _codecOf(MessageMedia media) {
    if (media is VideoMedia) return media.codec;
    return null;
  }

  String? _formatOf(MessageMedia media) {
    if (media is VideoMedia) return media.format;
    return null;
  }

  String? _preferOf(MessageMedia media) {
    if (media is VideoMedia) return media.prefer;
    return null;
  }

  String? _statusOf(MessageMedia media) {
    if (media is VideoMedia) return media.status;
    return null;
  }

  bool? _variantsReadyOf(MessageMedia media) {
    if (media is VideoMedia) return media.variantsReady;
    return null;
  }

  bool? _thumbReadyOf(MessageMedia media) {
    if (media is VideoMedia) return media.thumbReady;
    return null;
  }

  String? _thumbMediaIdOf(MessageMedia media) {
    if (media is VideoMedia) return media.thumbMediaId;
    return null;
  }

  int? _widthOf(MessageMedia media) {
    if (media is ImageMedia) return media.width;
    if (media is VideoMedia) return media.width;
    if (media is GenericMedia) return media.width;
    return null;
  }

  int? _heightOf(MessageMedia media) {
    if (media is ImageMedia) return media.height;
    if (media is VideoMedia) return media.height;
    if (media is GenericMedia) return media.height;
    return null;
  }

  List<double>? _waveformOf(MessageMedia media) {
    if (media is AudioMedia) return media.waveform;
    if (media is VideoMedia) return media.waveform;
    return null;
  }

  String? _serializeWaveform(List<double>? waveform) {
    if (waveform == null || waveform.isEmpty) {
      return null;
    }
    return jsonEncode(waveform);
  }

  List<double>? _parseWaveform(String? waveformJson) {
    if (waveformJson == null || waveformJson.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(waveformJson);
      if (decoded is List) {
        return decoded.map((e) => (e as num).toDouble()).toList();
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }
}
