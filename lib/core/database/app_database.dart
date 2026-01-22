import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../features/auth/data/entities/user_entity.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, 'flutter_chat.db'));
    return NativeDatabase(file);
  });
}
