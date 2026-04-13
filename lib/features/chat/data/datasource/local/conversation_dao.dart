  import 'dart:developer';

import 'package:flutter_chat/core/database/app_database.dart';

abstract class ConversationDao {
  Future<void> saveConversations(List<ChatConversationEntity> items);
  Future<void> saveConversation(ChatConversationEntity item);
  Future<List<ChatConversationEntity>> getAllConversations();
  Stream<List<ChatConversationEntity>> watchAllConversations();
  Future<void> clearConversations();
}

class DriftConversationDaoImpl implements ConversationDao {
  final AppDatabase _database;

  DriftConversationDaoImpl(this._database);

  @override
  Future<void> saveConversations(List<ChatConversationEntity> items) async {
    try {
      await _database.insertConversations(items);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveConversation(ChatConversationEntity item) async {
    try {
      await _database.insertConversation(item);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ChatConversationEntity>> getAllConversations() async {
    try {
      return await _database.getAllChatConversations();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<ChatConversationEntity>> watchAllConversations() {
    return _database.watchAllChatConversations();
  }

  @override
  Future<void> clearConversations() async {
    try {
      await _database.clearChatConversations();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
