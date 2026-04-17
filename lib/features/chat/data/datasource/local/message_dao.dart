import 'dart:developer';

import 'package:flutter_chat/core/database/app_database.dart';

abstract class MessageDao {
  Future<void> saveMessages(List<ChatMessageEntity> items);
  Future<void> saveMessage(ChatMessageEntity item);
  Future<ChatMessageEntity?> getMessageByClientMessageId(String clientMessageId);
  Future<List<ChatMessageEntity>> getMessagesByConversationId(String conversationId);
  Stream<List<ChatMessageEntity>> watchMessagesByConversationId(String conversationId);
  Future<void> clearMessagesByConversationId(String conversationId);
  Future<void> clearAllMessages();
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
      final clientMessageId = item.clientMessageId?.trim();
      if (clientMessageId == null || clientMessageId.isEmpty) {
        await _database.insertMessage(item);
        return;
      }

      final existing = await _database.getMessageByClientMessageId(clientMessageId);
      if (existing != null) {
        final existingContent = existing.content.trim();
        final incomingContent = item.content.trim();

        if (existingContent.isNotEmpty && incomingContent.isEmpty) {
          return;
        }

        await _database.deleteMessagesByClientMessageId(clientMessageId);
      }

      await _database.insertMessage(item);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<ChatMessageEntity?> getMessageByClientMessageId(String clientMessageId) async {
    try {
      return await _database.getMessageByClientMessageId(clientMessageId);
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
}
