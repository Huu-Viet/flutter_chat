import 'dart:developer';

import 'package:flutter_chat/core/database/app_database.dart';

abstract class MessageDao {
  Future<void> saveMessages(List<ChatMessageEntity> items);
  Future<void> saveMessage(ChatMessageEntity item);
  Future<List<ChatMessageEntity>> getMessagesByConversationId(String conversationId);
  Stream<List<ChatMessageEntity>> watchMessagesByConversationId(String conversationId);
  Future<void> clearMessagesByConversationId(String conversationId);
}

class DriftMessageDaoImpl implements MessageDao {
  final AppDatabase _database;

  DriftMessageDaoImpl(this._database);

  @override
  Future<void> saveMessages(List<ChatMessageEntity> items) async {
    try {
      await _database.insertMessages(items);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveMessage(ChatMessageEntity item) async {
    try {
      await _database.insertMessage(item);
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
}
