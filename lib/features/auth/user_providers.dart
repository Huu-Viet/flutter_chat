import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/user_dao.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart'; // Import để sử dụng firebaseAuthProvider

// Firebase native_services
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

final userDaoProvider = Provider<UserDao>((ref) {
  return DriftUserDaoImpl(
    ref.watch(databaseProvider)
  );
});

// Use Cases
final getCurrentUserInfoUseCase = Provider<GetCurrentUserInfo>((ref) {
  return GetCurrentUserInfo(
    ref.watch(authRepositoryProvider),
  );
});
