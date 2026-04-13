import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat/application/realtime/bus/app_event_bus.dart';
import 'package:flutter_chat/application/realtime/handlers/call_realtime_handler.dart';
import 'package:flutter_chat/application/realtime/handlers/chat_realtime_handler.dart';
import 'package:flutter_chat/application/realtime/handlers/handler.dart';
import 'package:flutter_chat/application/realtime/orchestrator.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';
import 'package:flutter_chat/application/realtime/subscribers/call_app_event_subscriber.dart';
import 'package:flutter_chat/application/realtime/subscribers/chat_app_event_subscriber.dart';
import 'package:flutter_chat/application/realtime/subscribers/session_app_event_subscriber.dart';
import 'package:flutter_chat/core/database/app_database.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/core/network/realtime_gateway_service.dart';
import 'package:flutter_chat/features/auth/auth_session_providers.dart';
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

final realtimeGatewayServiceProvider = Provider<RealtimeGateway>((ref) {
  final service = RealtimeGatewayService(
    authPrefDataSource: ref.watch(authPrefsDtsProvider),
    firebaseMessaging: FirebaseMessaging.instance,
    getRefreshTokenUseCase: ref.watch(getRefreshTokenUseCaseProvider),
    refreshTokenUseCase: ref.watch(refreshTokenUseCaseProvider),
  );

  ref.onDispose(service.dispose);
  return service;
});

final chatAppEventSubscriberProvider = Provider<AppEventSubscriber>((ref) {
  return const ChatAppEventSubscriber();
});

final callAppEventSubscriberProvider = Provider<AppEventSubscriber>((ref) {
  return const CallAppEventSubscriber();
});

final sessionAppEventSubscriberProvider = Provider<AppEventSubscriber>((ref) {
  return SessionAppEventSubscriber(
    realtimeGateway: ref.watch(realtimeGatewayServiceProvider),
    signOutUseCase: ref.watch(logoutUseCaseProvider),
    onSessionRevoked: () async {
      ref.read(forceLogoutTickProvider.notifier).state++;
    },
  );
});

final appEventSubscribersProvider = Provider<List<AppEventSubscriber>>((ref) {
  return [
    ref.watch(chatAppEventSubscriberProvider),
    ref.watch(callAppEventSubscriberProvider),
    ref.watch(sessionAppEventSubscriberProvider),
  ];
});

final appEventBusProvider = Provider<AppEventBus>((ref) {
  final bus = AppEventBus(subscribers: ref.watch(appEventSubscribersProvider));
  ref.onDispose(bus.dispose);
  return bus;
});

final chatRealtimeHandlerProvider = Provider<RealtimeHandler>((ref) {
  return ChatRealtimeHandler(bus: ref.watch(appEventBusProvider));
});

final callRealtimeHandlerProvider = Provider<RealtimeHandler>((ref) {
  return const CallRealtimeHandler();
});

final realtimeHandlersProvider = Provider<List<RealtimeHandler>>((ref) {
  return [
    ref.watch(chatRealtimeHandlerProvider),
    ref.watch(callRealtimeHandlerProvider),
  ];
});

final realtimeOrchestratorProvider = Provider<RealtimeOrchestrator>((ref) {
  return RealtimeOrchestrator(
    ref.watch(realtimeGatewayServiceProvider),
    handlers: ref.watch(realtimeHandlersProvider),
  );
});

final connectRealtimeGatewayUseCaseProvider = Provider<ConnectRealtimeGatewayUseCase>((ref) {
  return ConnectRealtimeGatewayUseCase(ref.watch(realtimeOrchestratorProvider));
});

final disconnectRealtimeGatewayUseCaseProvider = Provider<DisconnectRealtimeGatewayUseCase>((ref) {
  return DisconnectRealtimeGatewayUseCase(ref.watch(realtimeOrchestratorProvider));
});

//Locale is nullable to allow ref is null.
//This is because we want to set the locale to null when the user logs out,
//so that the app will use the system locale.
final localeProvider = StateProvider<Locale?>((ref) => null);