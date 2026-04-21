import 'dart:developer';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/features/chat/data/entities/message_reaction_entity.dart';

class ChatMessageWithMediasEntity {
  final ChatMessageEntity message;
  final List<MessageMediaEntity> medias;

  const ChatMessageWithMediasEntity({
    required this.message,
    required this.medias,
  });
}

abstract class MessageDao {
  Future<void> saveMessages(List<ChatMessageWithMediasEntity> items);
  Future<void> saveMessage(ChatMessageWithMediasEntity item);
  Future<ChatMessageWithMediasEntity?> getMessageById(String id);
  Future<ChatMessageWithMediasEntity?> getMessageByClientMessageId(String clientMessageId);
  Future<List<ChatMessageWithMediasEntity>> getMessagesByConversationId(String conversationId);
  Stream<List<ChatMessageWithMediasEntity>> watchMessagesByConversationId(String conversationId);
  Future<void> clearMessagesByConversationId(String conversationId);
  Future<void> clearAllMessages();
  Future<void> updateServerId(String localId, String serverId);
  Future<void> updateMessageContent(String id, String content, DateTime editedAt);
  Future<void> updateMessageDeleted(String messageIdentifier);
  Future<List<MessageReactionEntity>> getMessageReactions(String messageIdentifier);
  Future<void> saveMessageReactions(
    String messageIdentifier,
    List<MessageReactionEntity> reactions,
  );
}

class DriftMessageDaoImpl implements MessageDao {
  final AppDatabase _database;

  DriftMessageDaoImpl(this._database);

  @override
  Future<void> saveMessages(List<ChatMessageWithMediasEntity> items) async {
    try {
      for (final item in items) {
        await saveMessage(item);
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveMessage(ChatMessageWithMediasEntity item) async {
    try {
      final message = item.message;
      final clientMessageId = message.serverId?.trim();
      if (clientMessageId == null || clientMessageId.isEmpty) {
        await _database.insertMessage(message);
        await _database.replaceMessageMedias(message.id, item.medias);
        return;
      }

      final existing = await _database.getMessageByServerId(clientMessageId);
      if (existing != null) {
        final existingContent = existing.content.trim();
        final incomingContent = message.content.trim();
        final type = message.type.trim().toLowerCase();

        if (existingContent.isNotEmpty && incomingContent.isEmpty && type != 'image') {
          return;
        }

        await (_database.update(_database.chatMessages)
              ..where((tbl) => tbl.id.equals(existing.id)))
            .write(
          ChatMessagesCompanion(
            id: Value(message.id),
            conversationId: Value(message.conversationId),
            senderId: Value(message.senderId),
            content: Value(message.content),
            type: Value(message.type),
            offset: Value(message.offset),
            isDeleted: Value(message.isDeleted),
            metadata: Value(message.metadata),
            serverId: Value(message.serverId),
            createdAt: Value(message.createdAt),
            editedAt: Value(message.editedAt),
          ),
        );
        await _database.replaceMessageMedias(existing.id, item.medias);
        return;
      }

      await _database.insertMessage(message);
      await _database.replaceMessageMedias(message.id, item.medias);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<ChatMessageWithMediasEntity?> getMessageById(String id) async {
    try {
      final message = await _database.getMessageById(id);
      if (message == null) {
        return null;
      }
      final medias = await _database.getMessageMediasByMessageIds(<String>[message.id]);
      return ChatMessageWithMediasEntity(message: message, medias: medias);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<ChatMessageWithMediasEntity?> getMessageByClientMessageId(String clientMessageId) async {
    try {
      final message = await _database.getMessageByServerId(clientMessageId);
      if (message == null) {
        return null;
      }
      final medias = await _database.getMessageMediasByMessageIds(<String>[message.id]);
      return ChatMessageWithMediasEntity(message: message, medias: medias);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ChatMessageWithMediasEntity>> getMessagesByConversationId(String conversationId) async {
    try {
      final messages = await _database.getMessagesByConversationId(conversationId);
      return _attachMedias(messages);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<ChatMessageWithMediasEntity>> watchMessagesByConversationId(String conversationId) {
    return _database.watchMessagesByConversationId(conversationId).asyncMap(_attachMedias);
  }

  @override
  Future<void> clearMessagesByConversationId(String conversationId) async {
    try {
      await _database.clearMessagesByConversationId(conversationId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> clearAllMessages() async {
    try {
      await _database.clearAllMessages();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateServerId(String localId, String serverId) async {
    try {
      await (_database.update(_database.chatMessages)
        ..where((tbl) => tbl.id.equals(localId)))
          .write(ChatMessagesCompanion(
          serverId: Value(serverId),),
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateMessageContent(
    String id,
    String content,
    DateTime editedAt,
  ) async {
    try {
      await _database.updateMessageContent(id, content, editedAt);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateMessageDeleted(String messageIdentifier) async {
    try {
      await _database.updateMessageDeleted(messageIdentifier);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<MessageReactionEntity>> getMessageReactions(String messageIdentifier) async {
    try {
      final message = await _resolveMessageByIdentifier(messageIdentifier);
      final rawMessage = message?.message;
      if (rawMessage == null) {
        return const <MessageReactionEntity>[];
      }

      final metadataMap = _decodeMetadata(rawMessage.metadata);
      final reactionsNode = metadataMap['reactions'];
      if (reactionsNode is! List) {
        return const <MessageReactionEntity>[];
      }

      return reactionsNode
          .whereType<Map<String, dynamic>>()
          .map(
            (node) => MessageReactionEntity(
              messageId: (node['messageId'] ?? rawMessage.id).toString(),
              emoji: (node['emoji'] ?? '').toString(),
              count: _asInt(node['count']) ?? 0,
              reactors: (node['reactors'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .where((e) => e.isNotEmpty)
                      .toList(growable: false) ??
                  const <String>[],
              myReaction: node['myReaction'] == true,
            ),
          )
          .where((reaction) => reaction.emoji.isNotEmpty)
          .toList(growable: false);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveMessageReactions(
    String messageIdentifier,
    List<MessageReactionEntity> reactions,
  ) async {
    try {
      final message = await _resolveMessageByIdentifier(messageIdentifier);
      final rawMessage = message?.message;
      if (rawMessage == null) {
        return;
      }

      final metadataMap = _decodeMetadata(rawMessage.metadata);
      metadataMap['reactions'] = reactions
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

      await (_database.update(_database.chatMessages)
            ..where(
              (tbl) =>
                  tbl.id.equals(rawMessage.id) |
                  tbl.serverId.equals(messageIdentifier),
            ))
          .write(
        ChatMessagesCompanion(
          metadata: Value(jsonEncode(metadataMap)),
        ),
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<ChatMessageWithMediasEntity?> _resolveMessageByIdentifier(String messageIdentifier) async {
    final byId = await _database.getMessageById(messageIdentifier);
    if (byId != null) {
      final medias = await _database.getMessageMediasByMessageIds(<String>[byId.id]);
      return ChatMessageWithMediasEntity(message: byId, medias: medias);
    }
    final byServerId = await _database.getMessageByServerId(messageIdentifier);
    if (byServerId == null) {
      return null;
    }
    final medias = await _database.getMessageMediasByMessageIds(<String>[byServerId.id]);
    return ChatMessageWithMediasEntity(message: byServerId, medias: medias);
  }

  Future<List<ChatMessageWithMediasEntity>> _attachMedias(List<ChatMessageEntity> messages) async {
    if (messages.isEmpty) {
      return const <ChatMessageWithMediasEntity>[];
    }

    final messageIds = messages.map((entry) => entry.id).toList(growable: false);
    final medias = await _database.getMessageMediasByMessageIds(messageIds);
    final mediasByMessageId = <String, List<MessageMediaEntity>>{};
    for (final media in medias) {
      final bucket = mediasByMessageId.putIfAbsent(media.messageId, () => <MessageMediaEntity>[]);
      bucket.add(media);
    }

    return messages
        .map(
          (message) => ChatMessageWithMediasEntity(
            message: message,
            medias: List<MessageMediaEntity>.unmodifiable(
              mediasByMessageId[message.id] ?? const <MessageMediaEntity>[],
            ),
          ),
        )
        .toList(growable: false);
  }

  Map<String, dynamic> _decodeMetadata(String? rawMetadata) {
    if (rawMetadata == null || rawMetadata.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(rawMetadata);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
