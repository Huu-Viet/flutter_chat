import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint(e.toString());
      rethrow;
    }
  }

  @override
  Stream<UserDto?> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      if(firebaseUser == null) {
        yield null;
      } else {
        debugPrint("Firebase user authenticated: ${firebaseUser.uid}");
        debugPrint("Fetching user data from Firestore...");
        
        try {
          final docSnapshot = await usersCollection.doc(firebaseUser.uid).get();
          
          if (docSnapshot.exists) {
            debugPrint("Firestore document exists for user ${firebaseUser.uid}");
            final data = docSnapshot.data() as Map<String, dynamic>;
            debugPrint("Document data: $data");
            yield UserDto.fromDocument(data);
          } else {
            debugPrint("Firestore document does NOT exist for user ${firebaseUser.uid}");
            yield null;
          }
        } catch (e) {
          debugPrint("Error fetching user from Firestore: $e");
          yield null;
        }
      }
    });
  }
}