import 'dart:developer';

import 'package:flutter_chat/core/database/app_database.dart';

abstract class ConversationUserDao {
  Future<void> saveConversationUsers(List<ConversationUserEntity> items);
  Future<List<ConversationUserEntity>> getConversationUsers(String conversationId);
  Stream<List<ConversationUserEntity>> watchConversationUsers(String conversationId);
  Future<void> clearConversationUsers();
}

class DriftConversationUserDaoImpl implements ConversationUserDao {
  final AppDatabase _database;

  DriftConversationUserDaoImpl(this._database);

  @override
  Future<void> saveConversationUsers(List<ConversationUserEntity> items) async {
    try {
      await _database.insertConversationUsers(items);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ConversationUserEntity>> getConversationUsers(String conversationId) async {
    try {
      return await _database.getConversationUsers(conversationId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<ConversationUserEntity>> watchConversationUsers(String conversationId) {
    return _database.watchConversationUsers(conversationId);
  }

  @override
  Future<void> clearConversationUsers() async {
    try {
      await _database.clearConversationUsers();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}