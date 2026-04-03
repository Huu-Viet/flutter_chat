import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

//firebase
final firebaseDatabaseRefProvider = Provider<DatabaseReference>((ref) {
  return FirebaseDatabase.instance.ref();
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

//Locale is nullable to allow ref is null.
//This is because we want to set the locale to null when the user logs out,
//so that the app will use the system locale.
final localeProvider = StateProvider<Locale?>((ref) => null);