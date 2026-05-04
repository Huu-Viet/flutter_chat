import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/application/realtime/call_action.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_chat/features/auth/auth_session_providers.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/core/platform_services/platform_service_providers.dart';
import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_chat/presentation/call/blocs/in_call_bloc.dart';
import 'package:flutter_chat/presentation/call/providers/call_bloc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  static const String _inviteDeepLinkHost = 'zolo-smoky.vercel.app';

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _deepLinkSubscription;
  StreamSubscription<CallEvent?>? _callKitEventSubscription;
  final Map<String, CallInfo> _incomingCallsById = <String, CallInfo>{};
  final Set<String> _shownCallKitIds = <String>{};

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
    _initCallKitEvents();
  }

  void _initCallKitEvents() {
    _callKitEventSubscription = FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) {
        return;
      }

      final callId = _extractCallIdFromCallKitEvent(event);
      if (callId == null || callId.isEmpty) {
        return;
      }

      switch (event.event) {
        case Event.actionCallAccept:
          final call = _incomingCallsById[callId];
          if (call == null) {
            break;
          }

          ref
              .read(inCallBlocProvider)
              .add(
                InCallIncomingAccepted(
                  call,
                  isGroupCall: call.participants.length > 2,
                ),
              );
          ref.read(incomingCallProvider.notifier).state = null;
          _incomingCallsById.remove(callId);
          _shownCallKitIds.remove(callId);

          final router = ref.read(routerProvider);
          final currentPath = router.routeInformationProvider.value.uri.path;
          if (currentPath != '/in-call') {
            router.go('/in-call');
          }
          break;

        case Event.actionCallDecline:
        case Event.actionCallEnded:
        case Event.actionCallTimeout:
          if (!_incomingCallsById.containsKey(callId) &&
              !_shownCallKitIds.contains(callId)) {
            break;
          }
          ref.read(inCallBlocProvider).add(InCallIncomingDeclined(callId));
          ref.read(incomingCallProvider.notifier).state = null;
          _incomingCallsById.remove(callId);
          _shownCallKitIds.remove(callId);
          break;

        default:
          break;
      }
    });
  }

  String? _extractCallIdFromCallKitEvent(CallEvent event) {
    final body = event.body;
    if (body is! Map) {
      return null;
    }

    final id = body['id'] ?? body['callId'];
    if (id == null) {
      return null;
    }

    final callId = id.toString().trim();
    return callId.isEmpty ? null : callId;
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (error) {
      debugPrint('[MyApp] failed to read initial deep link: $error');
    }

    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (Object error) {
        debugPrint('[MyApp] deep link stream error: $error');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (!_isJoinInviteDeepLink(uri)) {
      return;
    }

    final pathSegments = uri.pathSegments;
    final token = pathSegments[1].trim();
    if (token.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final router = ref.read(routerProvider);
      final targetPath = '/join/${Uri.encodeComponent(token)}';
      final currentPath = router.routeInformationProvider.value.uri.path;
      if (currentPath == targetPath) {
        return;
      }

      router.go(targetPath);
    });
  }

  bool _isJoinInviteDeepLink(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    if ((scheme != 'https' && scheme != 'http') ||
        host != _inviteDeepLinkHost) {
      return false;
    }

    final pathSegments = uri.pathSegments;
    if (pathSegments.length < 2) {
      return false;
    }

    return pathSegments.first == 'join';
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _callKitEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeAsync = ref.watch(themeProvider);
    ref.read(databaseProvider);
    ref.read(fcmServiceProvider);

    ref.listen<CallInfo?>(incomingCallProvider, (prev, next) async {
      if (next == null) {
        return;
      }

      final callId = next.id.trim();
      if (callId.isEmpty) {
        return;
      }

      _incomingCallsById[callId] = next;
      if (_shownCallKitIds.contains(callId)) {
        return;
      }

      // Use caller info embedded in the socket payload first (new enriched payload).
      // Fall back to a user API lookup only when the name is missing.
      String callerName = next.callerName.trim();
      String callerAvatar = next.callerAvatar.trim();
      if (callerName.isEmpty) {
        final result = await ref.read(getUserByIdUseCaseProvider)(next.callerId);
        callerName = result.fold((_) => 'Incoming call', (user) {
          final fullName = user.fullName.trim();
          return fullName.isNotEmpty ? fullName : user.username;
        });
        if (callerAvatar.isEmpty) {
          callerAvatar = result.fold((_) => '', (user) => user.avatarUrl?.trim() ?? '');
        }
      }

      if (!mounted) {
        return;
      }

      _shownCallKitIds.add(callId);
      await ref.read(notiServiceProvider).showCallKitIncoming(
        callId, null,
        callerName.isNotEmpty ? callerName : 'Incoming call',
        callerAvatar: callerAvatar.isNotEmpty ? callerAvatar : null,
      );
    });

    ref.listen<CallAction?>(callActionProvider, (prev, next) {
      if (next == null) return;

      final bloc = ref.read(inCallBlocProvider);

      switch (next.type) {
        case CallActionType.accepted:
          if (bloc.state.session?.call.id == next.callId) {
            bloc.add(InCallRemoteAccepted(next.callId));
          }

          final currentPath = router.routeInformationProvider.value.uri.path;
          debugPrint(
            '[MyApp] callActionProvider accepted: callId=${next.callId}, currentPath=$currentPath',
          );
          // Only navigate when the caller/callee is NOT already on the
          // in-call page. The caller is already there after starting the call,
          // so re-navigating would rebuild the page with empty conversationId.
          if (currentPath != '/in-call') {
            router.go('/in-call');
          }
          break;

        case CallActionType.declined:
          ref.read(notiServiceProvider).endCallKit(next.callId);
          bloc.add(InCallRemoteDeclined(next.callId));
          break;

        case CallActionType.ended:
          ref.read(notiServiceProvider).endCallKit(next.callId);
          bloc.add(InCallRemoteEnded(next.callId));
          break;
      }

      ref.read(callActionProvider.notifier).state = null;
    });

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
        debugPrint(
          '[MyApp] forceLogoutTick changed: $previous -> $next; skip dialog on auth route $currentPath',
        );
        return;
      }

      final currentContext = router.routerDelegate.navigatorKey.currentContext;
      if (currentContext == null) {
        debugPrint(
          '[MyApp] forceLogoutTick changed: $previous -> $next; navigator context unavailable, going to /login',
        );
        router.go('/login');
        return;
      }

      final l10n = AppLocalizations.of(currentContext);

      debugPrint(
        '[MyApp] forceLogoutTick changed: $previous -> $next; showing revoke-session dialog',
      );

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
        debugPrint(
          '[MyApp] revoke-session dialog confirmed; navigating to /login',
        );
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
      supportedLocales: [Locale('en'), Locale('vi')],
    );
  }
}
