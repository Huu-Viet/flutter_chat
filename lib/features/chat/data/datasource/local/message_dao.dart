import 'dart:developer';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/features/chat/data/entities/message_reaction_entity.dart';

abstract class MessageDao {
  Future<void> saveMessages(List<ChatMessageEntity> items);
  Future<void> saveMessage(ChatMessageEntity item);
  Future<ChatMessageEntity?> getMessageById(String id);
  Future<ChatMessageEntity?> getMessageByClientMessageId(String clientMessageId);
  Future<List<ChatMessageEntity>> getMessagesByConversationId(String conversationId);
  Stream<List<ChatMessageEntity>> watchMessagesByConversationId(String conversationId);
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
  Future<void> saveMessages(List<ChatMessageEntity> items) async {
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
  Future<void> saveMessage(ChatMessageEntity item) async {
    try {
      final clientMessageId = item.serverId?.trim();
      if (clientMessageId == null || clientMessageId.isEmpty) {
        await _database.insertMessage(item);
        return;
      }

      final existing = await _database.getMessageByServerId(clientMessageId);
      if (existing != null) {
        final existingContent = existing.content.trim();
        final incomingContent = item.content.trim();
        final type = item.type.trim().toLowerCase();

        if (existingContent.isNotEmpty && incomingContent.isEmpty && type != 'image') {
          return;
        }

        await (_database.update(_database.chatMessages)
              ..where((tbl) => tbl.id.equals(existing.id)))
            .write(
          ChatMessagesCompanion(
            id: Value(item.id),
            conversationId: Value(item.conversationId),
            senderId: Value(item.senderId),
            content: Value(item.content),
            type: Value(item.type),
            offset: Value(item.offset),
            isDeleted: Value(item.isDeleted),
            mediaId: Value(item.mediaId),
            metadata: Value(item.metadata),
            serverId: Value(item.serverId),
            createdAt: Value(item.createdAt),
            editedAt: Value(item.editedAt),
          ),
        );
        return;
      }

      await _database.insertMessage(item);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<ChatMessageEntity?> getMessageById(String id) async {
    try {
      return await _database.getMessageById(id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<ChatMessageEntity?> getMessageByClientMessageId(String clientMessageId) async {
    try {
      return await _database.getMessageByServerId(clientMessageId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ChatMessageEntity>> getMessagesByConversationId(String conversationId) async {
    try {
      return await _database.getMessagesByConversationId(conversationId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessagesByConversationId(String conversationId) {
    return _database.watchMessagesByConversationId(conversationId);
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
      if (message == null) {
        return const <MessageReactionEntity>[];
      }

      final metadataMap = _decodeMetadata(message.metadata);
      final reactionsNode = metadataMap['reactions'];
      if (reactionsNode is! List) {
        return const <MessageReactionEntity>[];
      }

      return reactionsNode
          .whereType<Map<String, dynamic>>()
          .map(
            (node) => MessageReactionEntity(
              messageId: (node['messageId'] ?? message.id).toString(),
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
      if (message == null) {
        return;
      }

      final metadataMap = _decodeMetadata(message.metadata);
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
                  tbl.id.equals(message.id) |
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

  Future<ChatMessageEntity?> _resolveMessageByIdentifier(String messageIdentifier) async {
    final byId = await _database.getMessageById(messageIdentifier);
    if (byId != null) {
      return byId;
    }
    return _database.getMessageByServerId(messageIdentifier);
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
