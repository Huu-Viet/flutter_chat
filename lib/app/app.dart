import 'package:flutter/material.dart';
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/features/auth/auth_session_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/core/platform_services/platform_service_providers.dart';
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