import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/core/platform_services/fcm/fcm_service_background_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsfw_detector_flutter/nsfw_detector_flutter.dart';
import 'app/app.dart';
import 'package:flutter_chat/features/nsfw_detector/nsfw_detect_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.local');
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final imageDetector = await NsfwDetector.load();
  runApp(ProviderScope(
    overrides: [
      nsfwDetectProvider.overrideWith((ref) => Future.value(imageDetector)),
    ],
    child: MyApp()
  ));
}
