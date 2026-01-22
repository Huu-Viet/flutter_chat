import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:rxdart/rxdart.dart';

abstract class UserRemoteDataSource {
  Future<void> setUserData(MyUser user);
  Stream<UserDto?> get user;
}

class FirebaseUserDataSourceImpl implements UserRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final CollectionReference usersCollection;

  FirebaseUserDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    CollectionReference? usersCollection,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       usersCollection = usersCollection ?? FirebaseFirestore.instance.collection('users');

  @override
  Future<void> setUserData(MyUser user) async {
    try{
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await usersCollection.doc(currentUser.uid).set({
          'uid': user.id,
          'keycloakId': user.keycloakId,
          'email': user.email,
          'username': user.username,
          'phone': user.phone,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'displayName': user.displayName,
          'photoURL': user.avatarUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch(e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<UserDto?> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      if(firebaseUser == null) {
        yield null;
      } else {
        yield await usersCollection
            .doc(firebaseUser.uid)
            .get()
            .then((value) =>
              UserDto.fromDocument(value.data() as Map<String, dynamic>)
            );
      }
    });
  }
  
}