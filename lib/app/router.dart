import 'package:flutter_chat/presentation/auth/pages/forgot_pass_page.dart';
import 'package:flutter_chat/presentation/auth/pages/login_page.dart';
import 'package:flutter_chat/presentation/auth/pages/registry_page.dart';
import 'package:flutter_chat/presentation/call/presentation/in_call_page.dart';
import 'package:flutter_chat/presentation/chat/page/chat_page.dart';
import 'package:flutter_chat/presentation/main_scaffold.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/presentation/profile/pages/profile_page.dart';
import 'package:flutter_chat/presentation/profile/pages/set_profile_page.dart';
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
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage()
      ),
      GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordPage()
      ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegistryPage()
        ),
      GoRoute(
        path: '/set-profile',
        name: 'set-profile',
        builder: (context, state) {
          final initialUser = state.extra is MyUser ? state.extra as MyUser : null;
          return SetProfilePage(initialUser: initialUser);
        },
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
        path: '/in-call',
        name: 'in-call',
        builder: (context, state) {
          // Navigation uses query params (?conversationId=&roomName=) since
          // /in-call has no path segments.
          final conversationId =
              state.uri.queryParameters['conversationId'] ?? '';
          final roomName = state.uri.queryParameters['roomName'] ?? '';
          return InCallPage(
            conversationId: conversationId,
            initialRoomName: roomName,
          );
        },
      ),
      GoRoute(
        path: '/chat/:conversationId/:friendName',
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId'] ?? '';
          final friendName = state.pathParameters['friendName'] ?? '';
          return ChatPage(
            conversationId: conversationId,
            friendName: friendName,
          );
        },
      ),
    ],
  );
});