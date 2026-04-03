import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:googleapis_auth/auth_io.dart';

abstract class CallRemoteDataSource {
  Stream<RtcCallDataDto> observeImminentCall(MediaStream mediaStream, String channelId, String userId);
  Future<void> sendDataToPartner(RtcCallDataDto callData);
  Future<void> notifyCallActivity(String partnerId, String roomId);
  Future<void> deleteCallInfo(String channelId);
  Future<void> sendCallNotification(String deviceToken, String message, String channelId);
  void dispose();
}

class FirebaseCallRemoteDS implements CallRemoteDataSource {
  static const String _tag = "FirebaseCallRemoteDS";
  static const String _callRoom = "call_room";
  static const String _deviceToken = "device_token";
  static const String _latestEvent = "latest_event";
  static const String fcmApiUrl = "https://fcm.googleapis.com/v1/projects/momo-9bb17/messages:send";

  final DatabaseReference databaseRef;

  FirebaseCallRemoteDS({
    required this.databaseRef,
  });

  @override
  Stream<RtcCallDataDto> observeImminentCall(
      MediaStream mediaStream,
      String channelId,
      String userId
  ) {
    final ref = databaseRef
        .child(_callRoom)
        .child(channelId)
        .child(userId)
        .child(_latestEvent);

    return ref.onValue.map((event) {
      debugPrint("$_tag: Received call event: ${event.snapshot.value}");
      return RtcCallDataDto.fromJson(
        Map<String, dynamic>.from(event.snapshot.value as Map)
      );
    });
  }

  @override
  Future<void> sendDataToPartner(RtcCallDataDto callData) {
    final ref = databaseRef
        .child(_callRoom)
        .child(callData.channelId)
        .child(callData.target)
        .child(_latestEvent);

    return ref.set(callData.toJson()).whenComplete(() {
      debugPrint("$_tag: Successfully sent call data to partner ${callData.target}");
    }).catchError((e) {
      debugPrint("$_tag: Error sending call data: $e");
    });
  }

  @override
  Future<void> notifyCallActivity(String partnerId, String roomId) {
    // TODO: implement deleteCallInfo when notify FCM complete
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCallInfo(String channelId) {
    // TODO: implement deleteCallInfo
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<void> sendCallNotification(String deviceToken, String message, String channelId) async {
    try {
      final dio = Dio();

      final accessToken = await getAccessToken();

      final body = {
        "message": {
          "token": deviceToken,
          "data": {
            "title": "New call",
            "body": message,
            "call_room_id": channelId,
            "click_action": "",
          }
        }
      };

      final response = await dio.post(
        fcmApiUrl,
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      debugPrint("$_tag: sendCallNotification response: ${response.statusCode} - ${response.data}");
      if (response.statusCode != 200) {
        throw Exception("Unexpected response ${response.statusCode}");
      }

    } catch (e) {
      debugPrint("sendCallNotification error: $e");
    }
  }

  Future<String> getAccessToken() async {
    final jsonString =
    await rootBundle.loadString('assets/momo-9bb17-firebase-adminsdk-ykor4-b67ec5b044.json');

    final credentials = ServiceAccountCredentials.fromJson(jsonString);

    final scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ];

    final client = await clientViaServiceAccount(credentials, scopes);
    final accessToken = client.credentials.accessToken.data;
    client.close();

    return accessToken;
  }
}
