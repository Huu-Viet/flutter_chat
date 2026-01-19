import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';

abstract class UserRemoteDataSource {
  Future<void> setUserData(MyUser user);
  Stream<MyUser?> get user;
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
  Stream<MyUser?> get user {
    //Todo: implement user stream
    throw UnimplementedError();
    // final currentUser = _firebaseAuth.currentUser;
    // if (currentUser == null) {
    //   return Stream.value(null);
    // }
    //
    // return usersCollection.doc(currentUser.uid).snapshots().map((doc) {
    //   if (doc.exists) {
    //     final data = doc.data() as Map<String, dynamic>;
    //     return MyUser(
    //       uid: data['uid'] ?? '',
    //       phone: data['phone'],
    //       firstName: data['firstName'],
    //       lastName: data['lastName'],
    //       displayName: data['displayName'],
    //       photoURL: data['photoURL'],
    //     );
    //   }
    //   return null;
    // });
  }
  
}