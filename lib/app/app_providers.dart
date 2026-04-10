import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/platform_services/realtime/realtime_gateway_service.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
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

final realtimeGatewayServiceProvider = Provider<RealtimeGatewayService>((ref) {
  final service = RealtimeGatewayService(
    authPrefDataSource: ref.watch(authPrefsDtsProvider),
    firebaseMessaging: FirebaseMessaging.instance,
    getRefreshTokenUseCase: ref.watch(getRefreshTokenUseCaseProvider),
    refreshTokenUseCase: ref.watch(refreshTokenUseCaseProvider),
  );

  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});

//Locale is nullable to allow ref is null.
//This is because we want to set the locale to null when the user logs out,
//so that the app will use the system locale.
final localeProvider = StateProvider<Locale?>((ref) => null);