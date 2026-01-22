import 'dart:developer';
import 'package:flutter_chat/core/database/app_database.dart';

abstract class UserDao {
  Future<void> saveUser(UserEntity user);
  Future<int> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Future<UserEntity?> getUserById(String userId);
  Future<List<UserEntity>> getAllUsers();
  
  // Stream methods for real-time updates
  Stream<List<UserEntity>> watchAllUsers();
  Stream<UserEntity?> watchUserById(String userId);
}

class DriftUserDaoImpl implements UserDao {
  final AppDatabase _database;

  DriftUserDaoImpl(this._database);

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _database.deleteUserById(userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      return await _database.getAllUsers();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getUserById(String userId) async{
    try {
      return await _database.getUserById(userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    try {
      await _database.insertUser(user);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<int> updateUser(UserEntity user) async {
    try {
      return await  _database.updateUserData(user);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
  
  @override
  Stream<List<UserEntity>> watchAllUsers() {
    return _database.watchAllUsers();
  }
  
  @override
  Stream<UserEntity?> watchUserById(String userId) {
    return _database.watchUserById(userId);
  }
}