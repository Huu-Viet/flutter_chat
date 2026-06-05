import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/network/no_op_realtime_gateway.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/auth_interceptor.dart';
import 'package:flutter_chat/features/auth/data/datasources/api/auth_remote_service_impl.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/auth_pref_datasource.dart';
import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/features/call/data/local/pending_call_storage.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_accept_mapper.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_mapper.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_token_mapper.dart';
import 'package:flutter_chat/features/call/data/repo_impl/call_repo_impl.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCMBackgroundHandler: background message received data=${message.data} notification=${message.notification?.title}/${message.notification?.body}');
  await Firebase.initializeApp();
  final plugin = FlutterLocalNotificationsPlugin();
  final callRepository = CallRepoImpl(
      callRemoteDataSource: CallRemoteDSImpl(
        dio: authDioForBackground(),
        realtimeGateway: NoOpRealtimeGateway()
      ),
      apiCallMapper: ApiCallMapper(),
      apiCallAcceptMapper: ApiCallAcceptMapper(),
      apiCallTokenMapper: ApiCallTokenMapper(),
      pendingCallStorage: PendingCallStorageImpl()
  );
  final notificationService = NotificationService(plugin, callRepository);
  final pendingCallStorage = PendingCallStorageImpl();
  final router = NotificationRouter(notificationService, pendingCallStorage);
  final data = Map<String, dynamic>.from(message.data);
  final title = message.notification?.title;
  final body = message.notification?.body;
  if (!data.containsKey('title') && title != null && title.trim().isNotEmpty) {
    data['title'] = title;
  }
  if (!data.containsKey('body') && body != null && body.trim().isNotEmpty) {
    data['body'] = body;
  }
  await router.route(data);
  debugPrint('FCMBackgroundHandler: background message routed successfully');
}

// Function to provide a dio with no interceptors for background use
Dio authDioForBackground() {
  final dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 10)));
  final tokenDts = AuthPrefDataSourceImpl();
  final authRemoteService = AuthRemoteServiceImpl();

  dio.interceptors.add(
    AuthInterceptor(
      authPrefDataSource: tokenDts,
      authRemoteService: authRemoteService,
      dio: dio,
      onUnauthorized: () async {
        final hadAccessToken =
            (await tokenDts.getAccessToken())?.trim().isNotEmpty == true;
        final hadRefreshToken =
            (await tokenDts.getRefreshToken())?.trim().isNotEmpty == true;

        await tokenDts.clearToken();
        await tokenDts.clearCache();

        if (hadAccessToken || hadRefreshToken) {
          await tokenDts.clearToken();
          await tokenDts.clearCache();
        }
      },
    ),
  );

  return dio;
}