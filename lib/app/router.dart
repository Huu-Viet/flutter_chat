import 'package:flutter_chat/presentation/auth/pages/login_page.dart';
import 'package:flutter_chat/presentation/main_scaffold.dart';
import 'package:flutter_chat/presentation/profile/pages/profile_page.dart';
import 'package:flutter_chat/presentation/profile/pages/set_profile_page.dart';
import 'package:flutter_chat/presentation/splash/pages/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/chat/presentation/chat_page.dart';

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
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage()
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
      GoRoute(
        path: '/chat/:friendName',
        name: 'chat',
        builder: (context, state) {
          final friendName = state.pathParameters['friendName'] ?? 'Unknown';
          return ChatPage(friendName: friendName);
        },
      ),
    ],
  );
});