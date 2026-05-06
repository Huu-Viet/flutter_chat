import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_chat/features/chat/data/entities/pin_message_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../features/auth/data/entities/user_entity.dart';
import '../../features/chat/data/entities/conversation_entity.dart';
import '../../features/group_manager/data/entities/user_group_setting_entity.dart';
import '../../features/chat/data/entities/message_entity.dart';
import '../../features/friendship/data/entities/friendship_entity.dart';
import '../../features/chat/data/entities/sticker_package_entity.dart';
import '../../features/chat/data/entities/sticker_item_entity.dart';
import '../../features/chat/data/entities/conversation_user_entity.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  ChatConversations,
  ConversationUsers,
  ChatMessages,
  MessageMedias,
  Friendships,
  StickerPackages,
  StickerItems,
  PinMessages,
  UserGroupSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // We do not preserve old local data, so any schema upgrade recreates all tables.
          await m.deleteTable('sticker_items');
          await m.deleteTable('sticker_packages');
          await m.deleteTable('message_medias');
          await m.deleteTable('chat_messages');
          await m.deleteTable('conversation_users');
          await m.deleteTable('chat_conversations');
          await m.deleteTable('friendships');
          await m.deleteTable('users');
          await m.deleteTable('pin_messages');
          await m.deleteTable('user_group_settings');

          await m.createTable(users);
          await m.createTable(friendships);
          await m.createTable(chatConversations);
          await m.createTable(conversationUsers);
          await m.createTable(chatMessages);
          await m.createTable(messageMedias);
          await m.createTable(stickerPackages);
          await m.createTable(stickerItems);
          await m.createTable(pinMessages);
          await m.createTable(userGroupSettings);
        },
      );

  // Query methods for Users table
  Future<void> insertUser(UserEntity user) async {
    await into(users).insert(user, mode: InsertMode.replace);
  }

  Future<int> updateUserData(UserEntity user) async {
    return (update(users)..where((u) => u.id.equals(user.id))).write(user.toCompanion(false));
  }

  Future<bool> deleteUserById(String userId) async {
    return (delete(users)..where((u) => u.id.equals(userId))).go().then((count) => count > 0);
  }

  Future<bool> clearAllUsers() async {
    return delete(users).go().then((count) => count > 0);
  }

  Future<void> clearAllAppData() async {
    await transaction(() async {
      await delete(stickerItems).go();
      await delete(stickerPackages).go();
      await delete(messageMedias).go();
      await delete(chatMessages).go();
      await delete(conversationUsers).go();
      await delete(chatConversations).go();
      await delete(friendships).go();
      await delete(users).go();
    });
  }

  Future<UserEntity?> getUserById(String userId) async {
    return (select(users)..where((u) => u.id.equals(userId))).getSingleOrNull();
  }

  Future<List<UserEntity>> getAllUsers() async {
    return select(users).get();
  }

  // Stream methods for real-time updates
  Stream<List<UserEntity>> watchAllUsers() {
    return select(users).watch();
  }

  Stream<UserEntity?> watchUserById(String userId) {
    return (select(users)..where((u) => u.id.equals(userId))).watchSingleOrNull();
  }

  // Chat conversation queries
  Future<void> insertConversation(ChatConversationEntity item) async {
    await into(chatConversations).insert(item, mode: InsertMode.replace);
  }

  Future<void> insertConversations(List<ChatConversationEntity> items) async {
    if (items.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(chatConversations, items);
    });
  }

  Future<List<ChatConversationEntity>> getAllChatConversations() {
    return (select(chatConversations)
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.updatedAt),
          ]))
        .get();
  }

  Stream<List<ChatConversationEntity>> watchAllChatConversations() {
    return (select(chatConversations)
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.updatedAt),
          ]))
        .watch();
  }

  Future<void> insertConversationUsers(List<ConversationUserEntity> items) async {
    if (items.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(conversationUsers, items);
    });
  }

  Future<List<ConversationUserEntity>> getConversationUsers(String conversationId) {
    return (select(conversationUsers)
          ..where((tbl) => tbl.conversationId.equals(conversationId)))
        .get();
  }

  Stream<List<ConversationUserEntity>> watchConversationUsers(String conversationId) {
    return (select(conversationUsers)
          ..where((tbl) => tbl.conversationId.equals(conversationId)))
        .watch();
  }

  Future<void> clearConversationUsers() async {
    await delete(conversationUsers).go();
  }

  Future<void> deleteConversation(String conversationId) async {
    await transaction(() async {
      await (delete(conversationUsers)..where((tbl) => tbl.conversationId.equals(conversationId))).go();
      await (delete(chatMessages)..where((tbl) => tbl.conversationId.equals(conversationId))).go();
      await (delete(chatConversations)..where((tbl) => tbl.id.equals(conversationId))).go();
    });
  }

  Future<void> clearChatConversations() async {
    await delete(chatConversations).go();
  }

  Future<void> clearAllMessages() async {
    await delete(messageMedias).go();
    await delete(chatMessages).go();
  }

  // Sticker package queries
  Future<void> insertStickerPackage(StickerPackageEntity item) async {
    await into(stickerPackages).insert(item, mode: InsertMode.replace);
  }

  Future<void> insertStickerPackages(List<StickerPackageEntity> items) async {
    if (items.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(stickerPackages, items);
    });
  }

  Future<List<StickerPackageEntity>> getAllStickerPackages() {
    return select(stickerPackages).get();
  }

  Stream<List<StickerPackageEntity>> watchAllStickerPackages() {
    return select(stickerPackages).watch();
  }

  Future<void> clearStickerPackages() async {
    await delete(stickerPackages).go();
  }

  // Sticker item queries
  Future<void> insertStickerItem(StickerItemEntity item) async {
    await into(stickerItems).insert(item, mode: InsertMode.replace);
  }

  Future<void> insertStickerItems(List<StickerItemEntity> items) async {
    if (items.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(stickerItems, items);
    });
  }

  Future<List<StickerItemEntity>> getStickerItemsByPackageId(String packageId) {
    return (select(stickerItems)..where((tbl) => tbl.packageId.equals(packageId))).get();
  }

  Stream<List<StickerItemEntity>> watchStickerItemsByPackageId(String packageId) {
    return (select(stickerItems)..where((tbl) => tbl.packageId.equals(packageId))).watch();
  }

  Future<void> clearStickerItemsByPackageId(String packageId) async {
    await (delete(stickerItems)..where((tbl) => tbl.packageId.equals(packageId))).go();
  }

  Future<void> clearAllStickerItems() async {
    await delete(stickerItems).go();
  }

  // Chat message queries
  Future<void> insertMessage(ChatMessageEntity item) async {
    await into(chatMessages).insert(item, mode: InsertMode.replace);
  }

  Future<ChatMessageEntity?> getMessageByServerId(String serverId) async {
    return (select(chatMessages)..where((tbl) => tbl.serverId.equals(serverId))).getSingleOrNull();
  }

  Future<ChatMessageEntity?> getMessageById(String id) async {
    return (select(chatMessages)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteMessageById(String id) async {
    await (delete(messageMedias)..where((tbl) => tbl.messageId.equals(id))).go();
    await (delete(chatMessages)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteMessagesByServerId(String serverId) async {
    final messages = await (select(chatMessages)..where((tbl) => tbl.serverId.equals(serverId))).get();
    final messageIds = messages.map((e) => e.id).toList(growable: false);
    if (messageIds.isNotEmpty) {
      await (delete(messageMedias)..where((tbl) => tbl.messageId.isIn(messageIds))).go();
    }
    await (delete(chatMessages)..where((tbl) => tbl.serverId.equals(serverId))).go();
  }

  Future<void> insertMessages(List<ChatMessageEntity> items) async {
    if (items.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(chatMessages, items);
    });
  }

  Future<List<ChatMessageEntity>> getMessagesByConversationId(String conversationId) {
    return (select(chatMessages)
          ..where((tbl) => tbl.conversationId.equals(conversationId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.offset),
            (tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .get();
  }

  Stream<List<ChatMessageEntity>> watchMessagesByConversationId(String conversationId) {
    return (select(chatMessages)
          ..where((tbl) => tbl.conversationId.equals(conversationId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.offset),
            (tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .watch();
  }

  Stream<List<PinMessageEntity>> watchPinnedMessagesByConversationId(String conversationId) {
    return (select(pinMessages)
          ..where((tbl) => tbl.conversationId.equals(conversationId))
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
        .watch();
  }

  Future<void> clearMessagesByConversationId(String conversationId) async {
    final messages = await (select(chatMessages)..where((tbl) => tbl.conversationId.equals(conversationId))).get();
    final messageIds = messages.map((e) => e.id).toList(growable: false);
    if (messageIds.isNotEmpty) {
      await (delete(messageMedias)..where((tbl) => tbl.messageId.isIn(messageIds))).go();
    }
    await (delete(chatMessages)..where((tbl) => tbl.conversationId.equals(conversationId))).go();
  }

  Future<List<MessageMediaEntity>> getMessageMediasByMessageIds(List<String> messageIds) async {
    if (messageIds.isEmpty) {
      return const <MessageMediaEntity>[];
    }

    return (select(messageMedias)
          ..where((tbl) => tbl.messageId.isIn(messageIds))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.messageId),
            (tbl) => OrderingTerm.asc(tbl.orderIndex),
          ]))
        .get();
  }

  Future<void> replaceMessageMedias(String messageId, List<MessageMediaEntity> medias) async {
    await transaction(() async {
      await (delete(messageMedias)..where((tbl) => tbl.messageId.equals(messageId))).go();
      if (medias.isNotEmpty) {
        await batch((b) {
          b.insertAllOnConflictUpdate(messageMedias, medias);
        });
      }
    });
  }

  Future<void> updateMessageContent(
    String id,
    String content,
    DateTime editedAt,
  ) async {
    await (update(chatMessages)..where((tbl) => tbl.id.equals(id))).write(
      ChatMessagesCompanion(
        content: Value(content),
        editedAt: Value(editedAt.toIso8601String()),
      ),
    );
  }

  Future<void> updateMessageDeleted(String messageIdentifier) async {
    await (update(chatMessages)
          ..where(
            (tbl) =>
                tbl.id.equals(messageIdentifier) |
                tbl.serverId.equals(messageIdentifier),
          ))
        .write(
      const ChatMessagesCompanion(
        isDeleted: Value(true),
        isRevoked: Value(true),
      ),
    );
  }

  Future<void> insertOrReplacePinMessage(PinMessageEntity item) async {
    await into(pinMessages).insert(item, mode: InsertMode.replace);
  }

  Future<List<PinMessageEntity>> getPinnedMessagesByConversationId(String conversationId) async {
    return (select(pinMessages)..where((tbl) => tbl.conversationId.equals(conversationId))).get();
  }

  Future<void> clearFriendships() async {
    await delete(friendships).go();
  }

  Future<void> upsertUserGroupSetting(UserGroupSettingsCompanion data) async {
    await into(userGroupSettings).insertOnConflictUpdate(data);
  }

  Future<UserGroupSettingEntity?> getUserGroupSetting({
    required String groupId,
    required String userId,
  }) {
    return (select(userGroupSettings)
      ..where((t) => t.groupId.equals(groupId) & t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> updateUserGroupMute({
    required String groupId,
    required String userId,
    required bool isMuted,
  }) {
    return (update(userGroupSettings)
      ..where((t) => t.groupId.equals(groupId) & t.userId.equals(userId)))
        .write(
      UserGroupSettingsCompanion(
        isMute: Value(isMuted),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, 'flutter_chat.db'));
    return NativeDatabase(file);
  });
}
