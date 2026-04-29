import 'package:flutter/material.dart';
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/core/widgets/call_banner_overlay.dart';
import 'package:flutter_chat/features/auth/auth_session_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/core/platform_services/platform_service_providers.dart';
import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeAsync = ref.watch(themeProvider);
    ref.read(databaseProvider);
    ref.read(fcmServiceProvider);


    Future<void> handleIncomingCall(
        WidgetRef ref,
        CallInfo call,
        CallBannerOverlay overlay,
        OverlayState overlayState,
        ) async {
      final result =
      await ref.read(getUserByIdUseCaseProvider)(call.callerId);

      final callerName = result.fold(
            (l) => 'Unknown',
            (r) => r.fullName,
      );

      overlay.show(
        overlayState: overlayState,
        callerName: callerName,
        onAccept: () async {
          final acceptResult = await ref.read(acceptIncomingCallUseCaseProvider)(call.id);

          acceptResult.fold(
            (failure) {
              debugPrint('[MyApp] accept incoming call failed: ${failure.message}');
            },
            (acceptedCall) {
              ref.read(currentCallSessionProvider.notifier).state = CallSession(
                call: acceptedCall.call,
                token: acceptedCall.token,
                roomName: acceptedCall.roomName,
                liveKitUrl: acceptedCall.liveKitUrl,
                isIncoming: true,
              );
              ref.read(incomingCallProvider.notifier).state = null;
              overlay.hide();
            },
          );
        },
        onDecline: () {
          overlay.hide();
          ref.read(incomingCallProvider.notifier).state = null;
        },
      );
    }

    ref.listen<CallInfo?>(
      incomingCallProvider,
      (prev, next) async {
        final overlay = ref.read(callBannerOverlayProvider);

        final overlayState =
            router.routerDelegate.navigatorKey.currentState?.overlay;

        if (overlayState == null) return;

        if (next == null) {
          overlay.hide();
          return;
        }

        handleIncomingCall(ref, next, overlay, overlayState);
      },
    );

    ref.listen<CallSession?>(
      currentCallSessionProvider,
      (previous, next) {
        final currentPath = router.routeInformationProvider.value.uri.path;

        if (next != null) {
          if (currentPath != '/in-call') {
            ref.read(lastRouteBeforeInCallProvider.notifier).state = currentPath;
            router.push('/in-call');
          }
          return;
        }

        if (previous != null && next == null) {
          final fallbackRoute = ref.read(lastRouteBeforeInCallProvider);
          final normalizedFallbackRoute =
              fallbackRoute == null || fallbackRoute == '/call'
                  ? '/home'
                  : fallbackRoute;
          ref.read(lastRouteBeforeInCallProvider.notifier).state = null;
          if (currentPath != normalizedFallbackRoute) {
            router.go(normalizedFallbackRoute);
          }
        }
      },
    );

    ref.listen<int>(forceLogoutTickProvider, (previous, next) {
      if (previous == next) {
        return;
      }

      final currentPath = router.routeInformationProvider.value.uri.path;
      const authRoutes = <String>{
        '/splash',
        '/login',
        '/forgot-password',
        '/register',
        '/set-profile',
      };
      final isOnAuthRoute = authRoutes.contains(currentPath);

      if (isOnAuthRoute) {
        debugPrint('[MyApp] forceLogoutTick changed: $previous -> $next; skip dialog on auth route $currentPath');
        return;
      }

      final currentContext = router.routerDelegate.navigatorKey.currentContext;
      if (currentContext == null) {
        debugPrint('[MyApp] forceLogoutTick changed: $previous -> $next; navigator context unavailable, going to /login');
        router.go('/login');
        return;
      }

      final l10n = AppLocalizations.of(currentContext);

      debugPrint('[MyApp] forceLogoutTick changed: $previous -> $next; showing revoke-session dialog');

      showDialog<void>(
        context: currentContext,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n?.error_session_expired_title ?? 'Session Expired'),
          content: Text(
            l10n?.error_session_expired_message ??
                'Your account has been logged in on another device. Please sign in again.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n?.accept ?? 'OK'),
            ),
          ],
        ),
      ).then((_) {
        debugPrint('[MyApp] revoke-session dialog confirmed; navigating to /login');
        router.go('/login');
      });
    });

    final themeMode = themeAsync.when(
      data: (data) => data,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'Flutter Chat',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('vi'),
      ],
    );
  }
}