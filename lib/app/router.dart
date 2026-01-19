import 'package:flutter_chat/presentation/main_scaffold.dart';
import 'package:flutter_chat/presentation/auth/pages/otp_verification_page.dart';
import 'package:flutter_chat/presentation/auth/pages/phone_input_page.dart';
import 'package:flutter_chat/presentation/profile/presentation/profile_page.dart';
import 'package:flutter_chat/presentation/profile/presentation/set_profile_page.dart';
import 'package:flutter_chat/presentation/splash/pages/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/phone-auth',
        name: 'phone-auth',
        builder: (context, state) => const PhoneInputPage(),
      ),
      GoRoute(
        path: '/otp-verify',
        name: 'otp-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return OTPVerificationPage(
            verificationId: extra['verificationId']!,
            phoneNumber: extra['phoneNumber']!,
          );
        },
      ),
      GoRoute(
        path: '/set-profile',
        name: 'set-profile',
        builder: (context, state) => const SetProfilePage(),
      ),
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});