import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../features/auth/data/entities/user_entity.dart';
import '../../features/chat/data/entities/conversation_entity.dart';
import '../../features/chat/data/entities/message_entity.dart';
import '../../features/friendship/data/entities/friendship_entity.dart';
import '../../features/chat/data/entities/sticker_package_entity.dart';
import '../../features/chat/data/entities/sticker_item_entity.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users, ChatConversations, ChatMessages, Friendships, StickerPackages, StickerItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // We do not preserve old local data, so any schema upgrade recreates all tables.
          await m.deleteTable('sticker_items');
          await m.deleteTable('sticker_packages');
          await m.deleteTable('chat_messages');
          await m.deleteTable('chat_conversations');
          await m.deleteTable('friendships');
          await m.deleteTable('users');

          await m.createTable(users);
          await m.createTable(friendships);
          await m.createTable(chatConversations);
          await m.createTable(chatMessages);
          await m.createTable(stickerPackages);
          await m.createTable(stickerItems);
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
      await delete(chatMessages).go();
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

  Future<void> clearChatConversations() async {
    await delete(chatConversations).go();
  }

  Future<void> clearAllMessages() async {
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

  Future<void> deleteMessagesByServerId(String serverId) async {
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

  Future<void> clearMessagesByConversationId(String conversationId) async {
    await (delete(chatMessages)..where((tbl) => tbl.conversationId.equals(conversationId))).go();
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

  Future<void> clearFriendships() async {
    await delete(friendships).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, 'flutter_chat.db'));
    return NativeDatabase(file);
  });
}
