import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter_chat/core/database/app_database.dart';

abstract class MessageDao {
  Future<void> saveMessages(List<ChatMessageEntity> items);
  Future<void> saveMessage(ChatMessageEntity item);
  Future<ChatMessageEntity?> getMessageByServerId(String serverId);
  Future<List<ChatMessageEntity>> getMessagesByConversationId(String conversationId);
  Stream<List<ChatMessageEntity>> watchMessagesByConversationId(String conversationId);
  Future<void> clearMessagesByConversationId(String conversationId);
  Future<void> clearAllMessages();
  Future<void> updateServerId(String localId, String serverId);
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
      final serverId = item.serverId?.trim();
      if (serverId == null || serverId.isEmpty) {
        await _database.insertMessage(item);
        return;
      }

      final existing = await _database.getMessageByServerId(serverId);
      if (existing != null) {
        final existingContent = existing.content.trim();
        final incomingContent = item.content.trim();

        if (existingContent.isNotEmpty && incomingContent.isEmpty) {
          return;
        }

        await _database.deleteMessagesByServerId(serverId);
      }

      await _database.insertMessage(item);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<ChatMessageEntity?> getMessageByServerId(String serverId) async {
    try {
      return await _database.getMessageByServerId(serverId);
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
}
