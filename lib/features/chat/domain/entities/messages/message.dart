import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/audio_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/file_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/image_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_media_info/video_media.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message_reaction.dart';
import 'message_media_info/message_media.dart';

part '../messages/text_message.dart';
part '../messages/sticker_message.dart';
part '../messages/audio_message.dart';
part '../messages/video_message.dart';
part '../messages/image_message.dart';
part '../messages/file_message.dart';
part '../messages/multi_media_message.dart';
part '../messages/unknow_message.dart';

sealed class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final int? offset;
  final bool isDeleted;
  final bool isRevoked;
  final String? serverId;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<MessageReaction> reactions;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.offset,
    required this.isDeleted,
    this.isRevoked = false,
    required this.serverId,
    required this.createdAt,
    required this.editedAt,
    this.reactions = const <MessageReaction>[],
  });

  String get type;

  String get content;

  List<MessageMedia> get attachments => const <MessageMedia>[];

  String? get mediaId {
    if (attachments.isEmpty) {
      return null;
    }
    return attachments.first.mediaId;
  }
}


