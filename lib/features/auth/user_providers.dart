import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/datasources/user_remote_datasource.dart';
import 'auth_providers.dart'; // Import để sử dụng firebaseAuthProvider

// Firebase services
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final usersCollectionProvider = Provider<CollectionReference>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('users');
});

// Data Sources
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return FirebaseUserDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider), // Sử dụng từ auth_providers
    usersCollection: ref.watch(usersCollectionProvider),
  );
});