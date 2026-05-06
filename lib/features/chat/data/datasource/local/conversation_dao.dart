import 'dart:developer';

import 'package:flutter_chat/core/database/app_database.dart';
import 'package:drift/drift.dart';

class ConversationMemberLocal {
  final UserEntity user;
  final String role;

  const ConversationMemberLocal({required this.user, required this.role});
}

class ConversationWithUsersLocal {
  final ChatConversationEntity conversation;
  final List<ConversationMemberLocal> participants;

  const ConversationWithUsersLocal({
    required this.conversation,
    required this.participants,
  });
}

abstract class ConversationDao {
  Future<void> saveConversations(List<ChatConversationEntity> items);
  Future<void> saveConversation(ChatConversationEntity item);
  Future<void> updateConversationLastMessage({
    required String conversationId,
    required String messageId,
    required String content,
    required String type,
    required int? offset,
    required String senderId,
    required bool isDeleted,
    required bool isRevoked,
    required DateTime createdAt,
  });
  Future<List<ChatConversationEntity>> getAllConversations();
  Stream<List<ChatConversationEntity>> watchAllConversations();
  Stream<List<ConversationWithUsersLocal>> watchConversationsWithUsers();
  Future<void> deleteConversation(String conversationId);
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
  Future<void> updateConversationLastMessage({
    required String conversationId,
    required String messageId,
    required String content,
    required String type,
    required int? offset,
    required String senderId,
    required bool isDeleted,
    required bool isRevoked,
    required DateTime createdAt,
  }) async {
    try {
      await _database.updateConversationLastMessage(
        conversationId: conversationId,
        messageId: messageId,
        content: content,
        type: type,
        offset: offset,
        senderId: senderId,
        isDeleted: isDeleted,
        isRevoked: isRevoked,
        createdAt: createdAt,
      );
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
  Stream<List<ConversationWithUsersLocal>> watchConversationsWithUsers() {
    final joinedQuery =
        (_database.select(
          _database.chatConversations,
        )..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])).join([
          leftOuterJoin(
            _database.conversationUsers,
            _database.conversationUsers.conversationId.equalsExp(
              _database.chatConversations.id,
            ),
          ),
          leftOuterJoin(
            _database.users,
            _database.users.id.equalsExp(_database.conversationUsers.userId),
          ),
        ]);

    return joinedQuery.watch().map((rows) {
      final grouped = <String, _ConversationWithUsersAccumulator>{};

      for (final row in rows) {
        final conversation = row.readTable(_database.chatConversations);
        final key = conversation.id;
        final accumulator = grouped.putIfAbsent(
          key,
          () => _ConversationWithUsersAccumulator(conversation),
        );

        final membership = row.readTableOrNull(_database.conversationUsers);
        final user = row.readTableOrNull(_database.users);
        if (membership == null || user == null) {
          continue;
        }

        accumulator.addParticipant(
          ConversationMemberLocal(user: user, role: membership.role ?? ''),
        );
      }

      return grouped.values.map((item) => item.build()).toList(growable: false);
    });
  }

  @override
  Future<void> deleteConversation(String conversationId) {
    try {
      return _database.deleteConversation(conversationId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
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

class _ConversationWithUsersAccumulator {
  final ChatConversationEntity conversation;
  final List<ConversationMemberLocal> _participants =
      <ConversationMemberLocal>[];
  final Set<String> _userIds = <String>{};

  _ConversationWithUsersAccumulator(this.conversation);

  void addParticipant(ConversationMemberLocal participant) {
    final userId = participant.user.id;
    if (_userIds.contains(userId)) {
      return;
    }
    _userIds.add(userId);
    _participants.add(participant);
  }

  ConversationWithUsersLocal build() {
    return ConversationWithUsersLocal(
      conversation: conversation,
      participants: List<ConversationMemberLocal>.unmodifiable(_participants),
    );
  }
}
