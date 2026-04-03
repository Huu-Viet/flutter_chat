import 'package:flutter/material.dart';
import 'package:flutter_chat/app/app_providers.dart';
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
    ref.read(databaseProvider);
    ref.read(fcmServiceProvider);

    return MaterialApp.router(
      title: 'Flutter Chat',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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