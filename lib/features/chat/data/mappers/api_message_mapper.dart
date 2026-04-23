import 'package:flutter_chat/core/mappers/remote_mapper.dart';
import 'package:flutter_chat/features/chat/data/dtos/message_attachment_dto.dart';
import 'package:flutter_chat/features/chat/data/dtos/message_dto.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/audio_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/file_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/generic_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/image_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/message_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/video_media.dart';
import 'package:flutter_chat/features/chat/export.dart';

class ApiMessageMapper implements RemoteMapper<MessageDto, Message> {
  DateTime _parseDate(String? value) {
    return DateTime.tryParse(value ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Message toDomain(MessageDto dto) {
    final normalizedType = (dto.type ?? 'text').trim().toLowerCase();
    final createdAt = _parseDate(dto.createdAt);
    final editedAt = dto.editedAt == null ? null : _parseDate(dto.editedAt);
    final metadata = dto.metadata;
    final reactions = _extractReactions(metadata, dto.id ?? '');
    final isRevoked = dto.isRevoked ?? false;
    final medias = _mapAttachmentDtos(
      dto.attachments,
      fallbackType: normalizedType,
      messageMetadata: metadata,
    );

    switch (normalizedType) {
      case 'text':
        return TextMessage(
          id: dto.id ?? '',
          conversationId: dto.conversationId ?? '',
          senderId: dto.senderId ?? '',
          text: dto.content ?? '',
          offset: dto.offset,
          isDeleted: dto.isDeleted ?? false,
          isRevoked: isRevoked,
          serverId: dto.clientMessageId,
          createdAt: createdAt,
          editedAt: editedAt,
          reactions: reactions,
        );
      case 'sticker':
        return StickerMessage(
          id: dto.id ?? '',
          conversationId: dto.conversationId ?? '',
          senderId: dto.senderId ?? '',
          stickerUrl: _extractStickerUrl(metadata, medias),
          stickerId: _extractStickerId(metadata),
          stickerText: dto.content ?? '',
          offset: dto.offset,
          isDeleted: dto.isDeleted ?? false,
          isRevoked: isRevoked,
          serverId: dto.clientMessageId,
          createdAt: createdAt,
          editedAt: editedAt,
          reactions: reactions,
        );
      case 'audio':
        return AudioMessage(
          id: dto.id ?? '',
          conversationId: dto.conversationId ?? '',
          senderId: dto.senderId ?? '',
          media: _toAudioMedia(medias, dto.mediaId, metadata),
          caption: dto.content,
          offset: dto.offset,
          isDeleted: dto.isDeleted ?? false,
          isRevoked: isRevoked,
          serverId: dto.clientMessageId,
          createdAt: createdAt,
          editedAt: editedAt,
          reactions: reactions,
        );
      case 'video':
        return VideoMessage(
          id: dto.id ?? '',
          conversationId: dto.conversationId ?? '',
          senderId: dto.senderId ?? '',
          media: _toVideoMedia(medias, dto.mediaId, metadata),
          caption: dto.content,
          offset: dto.offset,
          isDeleted: dto.isDeleted ?? false,
          isRevoked: isRevoked,
          serverId: dto.clientMessageId,
          createdAt: createdAt,
          editedAt: editedAt,
          reactions: reactions,
        );
      case 'image':
        return ImageMessage(
          id: dto.id ?? '',
          conversationId: dto.conversationId ?? '',
          senderId: dto.senderId ?? '',
          medias: _toImageMedias(medias, dto.mediaId),
          caption: dto.content,
          offset: dto.offset,
          isDeleted: dto.isDeleted ?? false,
          isRevoked: isRevoked,
          serverId: dto.clientMessageId,
          createdAt: createdAt,
          editedAt: editedAt,
          reactions: reactions,
        );
      case 'file':
        return FileMessage(
          id: dto.id ?? '',
          conversationId: dto.conversationId ?? '',
          senderId: dto.senderId ?? '',
          medias: _toFileMedias(medias, dto.mediaId, metadata),
          caption: dto.content,
          offset: dto.offset,
          isDeleted: dto.isDeleted ?? false,
          isRevoked: isRevoked,
          serverId: dto.clientMessageId,
          createdAt: createdAt,
          editedAt: editedAt,
          reactions: reactions,
        );
      case 'media':
        return MultiMediaMessage(
          id: dto.id ?? '',
          conversationId: dto.conversationId ?? '',
          senderId: dto.senderId ?? '',
          medias: medias,
          caption: dto.content,
          offset: dto.offset,
          isDeleted: dto.isDeleted ?? false,
          isRevoked: isRevoked,
          serverId: dto.clientMessageId,
          createdAt: createdAt,
          editedAt: editedAt,
          reactions: reactions,
        );
      default:
        return UnknownMessage(
          id: dto.id ?? '',
          conversationId: dto.conversationId ?? '',
          senderId: dto.senderId ?? '',
          rawType: normalizedType,
          rawContent: dto.content ?? '',
          rawAttachments: medias,
          offset: dto.offset,
          isDeleted: dto.isDeleted ?? false,
          isRevoked: isRevoked,
          serverId: dto.clientMessageId,
          createdAt: createdAt,
          editedAt: editedAt,
          reactions: reactions,
        );
    }
  }

  @override
  MessageDto? toDto(Message domain) {
    return MessageDto(
      id: domain.id,
      conversationId: domain.conversationId,
      senderId: domain.senderId,
      content: domain.content,
      type: domain.type,
      offset: domain.offset,
      isDeleted: domain.isDeleted,
      isRevoked: domain.isRevoked,
      mediaId: domain.mediaId,
      attachments: domain.attachments
          .map(
            (entry) => MessageAttachmentDto(
              mediaId: entry.mediaId,
              kind: entry.type,
              type: entry.type,
              url: entry.url,
              mimeType: entry.mimeType,
              fileName: entry.fileName,
              size: entry.size,
              durationMs: _durationMsOf(entry),
              bitrate: _bitrateOf(entry),
              codec: _codecOf(entry),
              format: _formatOf(entry),
              width: _widthOf(entry),
              height: _heightOf(entry),
              prefer: _preferOf(entry),
              status: _statusOf(entry),
              variantsReady: _variantsReadyOf(entry),
              thumbReady: _thumbReadyOf(entry),
            ),
          )
          .toList(growable: false),
      metadata: _buildMetadata(domain),
      clientMessageId: domain.serverId,
      createdAt: domain.createdAt.toIso8601String(),
      editedAt: domain.editedAt?.toIso8601String(),
    );
  }

  @override
  List<Message> toDomainList(List<MessageDto> dtos) {
    return dtos.map(toDomain).toList(growable: false);
  }

  @override
  List<MessageDto> toDtoList(List<Message> domains) {
    return domains.map((d) => toDto(d)!).toList(growable: false);
  }

  List<MessageMedia> _mapAttachmentDtos(
    List<MessageAttachmentDto> dtos, {
    required String fallbackType,
    Map<String, dynamic>? messageMetadata,
  }) {
    final fileName = messageMetadata?['filename']?.toString();
    final fileSize = MessageDto.asInt(messageMetadata?['fileSize']);
    final thumbMediaId = messageMetadata?['thumbMediaId']?.toString();
    
    return dtos
        .map(
          (entry) => _mapAttachmentDto(
            entry,
            fallbackType: fallbackType,
            fileName: fileName,
            fileSize: fileSize,
            thumbMediaId: thumbMediaId,
          ),
        )
        .where((media) => media.mediaId.trim().isNotEmpty)
        .toList(growable: false);
  }

  MessageMedia _mapAttachmentDto(
    MessageAttachmentDto dto, {
    required String fallbackType,
    String? fileName,
    int? fileSize,
    String? thumbMediaId,
  }) {
    final mediaType = (dto.kind ?? dto.type ?? fallbackType).trim().toLowerCase();
    final effectiveFileName = dto.fileName ?? fileName;
    final effectiveSize = dto.size ?? fileSize;
    
    switch (mediaType) {
      case 'audio':
        return AudioMedia(
          id: dto.mediaId,
          url: dto.url,
          mimeType: dto.mimeType,
          fileName: effectiveFileName,
          size: effectiveSize,
          durationMs: dto.durationMs,
          waveform: dto.waveform,
        );
      case 'video':
        return VideoMedia(
          id: dto.mediaId,
          url: dto.url,
          mimeType: dto.mimeType,
          fileName: effectiveFileName,
          size: effectiveSize,
          durationMs: dto.durationMs ?? 0,
          bitrate: dto.bitrate ?? 0,
          codec: dto.codec,
          format: dto.format,
          prefer: dto.prefer,
          status: dto.status,
          variantsReady: dto.variantsReady,
          thumbReady: dto.thumbReady,
          thumbMediaId: dto.thumbMediaId ?? thumbMediaId,
          width: dto.width,
          height: dto.height,
          waveform: dto.waveform,
        );
      case 'image':
        return ImageMedia(
          id: dto.mediaId,
          url: dto.url,
          mimeType: dto.mimeType,
          fileName: effectiveFileName,
          size: effectiveSize,
          width: dto.width,
          height: dto.height,
        );
      case 'file':
        return FileMedia(
          id: dto.mediaId,
          url: dto.url,
          mimeType: dto.mimeType,
          fileName: effectiveFileName,
          size: effectiveSize,
          mediaType: dto.type,
        );
      default:
        return GenericMedia(
          id: dto.mediaId,
          mediaType: mediaType,
          url: dto.url,
          mimeType: dto.mimeType,
          fileName: effectiveFileName,
          size: effectiveSize,
          durationMs: dto.durationMs,
          bitrate: dto.bitrate,
          width: dto.width,
          height: dto.height,
        );
    }
  }

  AudioMedia _toAudioMedia(List<MessageMedia> medias, String? mediaId, Map<String, dynamic>? metadata) {
    final waveform = _extractWaveform(metadata);
    // final durationMs = _extractDurationMs(metadata);
    if (medias.isNotEmpty && medias.first is AudioMedia) {
      final existing = medias.first as AudioMedia;
      return AudioMedia(
        id: existing.mediaId,
        url: existing.url,
        mimeType: existing.mimeType,
        size: existing.size,
        durationMs: existing.durationMs,
        waveform: existing.waveform ?? waveform,
      );
    }
    final fallbackId = mediaId?.trim() ?? '';
    return AudioMedia(
      id: fallbackId,
      // durationMs: durationMs,
      waveform: waveform,
    );
  }

  VideoMedia _toVideoMedia(List<MessageMedia> medias, String? mediaId, Map<String, dynamic>? metadata) {
    final waveform = _extractWaveform(metadata);
    final durationMs = _extractDurationMs(metadata);
    final metadataThumbMediaId = metadata?['thumbMediaId']?.toString();
    if (medias.isNotEmpty && medias.first is VideoMedia) {
      final existing = medias.first as VideoMedia;
      return VideoMedia(
        id: existing.mediaId,
        url: existing.url,
        mimeType: existing.mimeType,
        size: existing.size,
        fileName: existing.fileName,
        durationMs: existing.durationMs,
        bitrate: existing.bitrate,
        codec: existing.codec,
        format: existing.format,
        prefer: existing.prefer,
        status: existing.status,
        variantsReady: existing.variantsReady,
        thumbReady: existing.thumbReady,
        thumbMediaId: existing.thumbMediaId ?? metadataThumbMediaId,
        width: existing.width,
        height: existing.height,
        waveform: existing.waveform ?? waveform,
      );
    }
    final first = medias.isNotEmpty ? medias.first : null;
    final fallbackId = (first?.mediaId ?? mediaId ?? '').trim();
    // final effectiveDurationMs = first is VideoMedia
    //     ? first.durationMs
    //     : first is GenericMedia
    //         ? (first.durationMs ?? durationMs ?? 0)
    //         : (durationMs ?? 0);
    return VideoMedia(
      id: fallbackId,
      url: first?.url,
      mimeType: first?.mimeType,
      size: first?.size,
      fileName: first?.fileName,
      // durationMs: effectiveDurationMs,
      bitrate: first is VideoMedia
          ? first.bitrate
          : first is GenericMedia
              ? (first.bitrate ?? 0)
              : 0,
      thumbMediaId: first is VideoMedia ? first.thumbMediaId : metadataThumbMediaId,
      width: first is GenericMedia ? first.width : null,
      height: first is GenericMedia ? first.height : null,
      waveform: waveform,
    );
  }

  List<ImageMedia> _toImageMedias(List<MessageMedia> medias, String? mediaId) {
    final imageMedias = medias.whereType<ImageMedia>().toList(growable: false);
    if (imageMedias.isNotEmpty) {
      return imageMedias;
    }

    final fallbackId = mediaId?.trim();
    if (fallbackId == null || fallbackId.isEmpty) {
      return const <ImageMedia>[];
    }

    return <ImageMedia>[ImageMedia(id: fallbackId)];
  }

  List<FileMedia> _toFileMedias(
    List<MessageMedia> medias,
    String? mediaId,
    Map<String, dynamic>? metadata,
  ) {
    final fileMedias = medias.whereType<FileMedia>().toList(growable: false);
    if (fileMedias.isNotEmpty) {
      return fileMedias;
    }

    final fallbackId = mediaId?.trim();
    if (fallbackId == null || fallbackId.isEmpty) {
      return const <FileMedia>[];
    }

    final fileName = metadata?['filename']?.toString();
    final fileSize = MessageDto.asInt(metadata?['fileSize']);

    return <FileMedia>[
      FileMedia(
        id: fallbackId,
        fileName: fileName,
        size: fileSize,
      ),
    ];
  }

  List<MessageReaction> _extractReactions(Map<String, dynamic>? metadata, String fallbackMessageId) {
    if (metadata == null) {
      return const <MessageReaction>[];
    }

    final raw = metadata['reactions'];
    if (raw is! List) {
      return const <MessageReaction>[];
    }

    return raw
        .whereType<Map>()
        .map((entry) => entry.map((key, value) => MapEntry(key.toString(), value)))
        .map(
          (entry) => MessageReaction(
            messageId: (entry['messageId'] ?? fallbackMessageId).toString(),
            emoji: (entry['emoji'] ?? '').toString(),
            count: _toInt(entry['count']) ?? 0,
            reactors: (entry['reactors'] as List?)
                    ?.map((reactor) => reactor.toString())
                    .toList(growable: false) ??
                const <String>[],
            myReaction: entry['myReaction'] == true,
          ),
        )
        .where((reaction) => reaction.emoji.trim().isNotEmpty && reaction.count > 0)
        .toList(growable: false);
  }

  Map<String, dynamic>? _buildMetadata(Message message) {
    final metadata = <String, dynamic>{};

    if (message is StickerMessage) {
      metadata['url'] = message.stickerUrl;
      if (message.stickerId != null && message.stickerId!.trim().isNotEmpty) {
        metadata['stickerId'] = message.stickerId!.trim();
      }
    }

    // Extract waveform from audio/video messages
    final waveform = _extractWaveformFromMessage(message);
    if (waveform != null && waveform.isNotEmpty) {
      metadata['waveform'] = waveform;
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

    return metadata;
  }

  String _extractStickerUrl(Map<String, dynamic>? metadata, List<MessageMedia> medias) {
    final candidate = metadata?['url']?.toString().trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }

    if (medias.isNotEmpty && medias.first.url != null && medias.first.url!.trim().isNotEmpty) {
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

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  int? _durationMsOf(MessageMedia media) {
    if (media is AudioMedia) return media.durationMs;
    if (media is VideoMedia) return media.durationMs;
    if (media is GenericMedia) return media.durationMs;
    return null;
  }

  int? _bitrateOf(MessageMedia media) {
    if (media is VideoMedia) return media.bitrate;
    if (media is GenericMedia) return media.bitrate;
    return null;
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

  int? _extractDurationMs(Map<String, dynamic>? metadata) {
    if (metadata == null) {
      return null;
    }

    final durationRaw = metadata['durationMs'] ?? metadata['duration'] ?? metadata['duration_ms'];
    if (durationRaw is int) {
      return durationRaw;
    }
    if (durationRaw is String) {
      return int.tryParse(durationRaw);
    }
    if (durationRaw is num) {
      return durationRaw.toInt();
    }

    // Try nested under media payload
    final mediaNode = metadata['media'];
    if (mediaNode is Map<String, dynamic>) {
      final nested = mediaNode['durationMs'] ?? mediaNode['duration'];
      if (nested is int) {
        return nested;
      }
      if (nested is String) {
        return int.tryParse(nested);
      }
      if (nested is num) {
        return nested.toInt();
      }
    }

    return null;
  }

  List<double>? _extractWaveform(Map<String, dynamic>? metadata) {
    if (metadata == null) {
      return null;
    }

    final waveformRaw = metadata['waveform'];
    if (waveformRaw is List) {
      return waveformRaw
          .where((e) => e is num || e is String)
          .map((e) => e is num ? e.toDouble() : double.tryParse(e.toString()))
          .whereType<double>()
          .toList(growable: false);
    }

    // Some backends nest waveform under media payload.
    final mediaNode = metadata['media'];
    if (mediaNode is Map<String, dynamic>) {
      final nested = mediaNode['waveform'];
      if (nested is List) {
        return nested
            .where((e) => e is num || e is String)
            .map((e) => e is num ? e.toDouble() : double.tryParse(e.toString()))
            .whereType<double>()
            .toList(growable: false);
      }
    }

    return null;
  }

  List<double>? _extractWaveformFromMessage(Message message) {
    if (message is AudioMessage) {
      return message.media.waveform;
    }
    if (message is VideoMessage) {
      return message.media.waveform;
    }
    return null;
  }
}
