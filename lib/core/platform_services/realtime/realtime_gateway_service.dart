import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/utils/token_utils.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/auth_pref_datasource.dart';
import 'package:flutter_chat/features/auth/domain/usecases/get_refresh_token_usecase.dart';
import 'package:flutter_chat/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class RealtimeGatewayEvent {
  final String namespace;
  final String event;
  final dynamic payload;
  final DateTime timestamp;

  const RealtimeGatewayEvent({
    required this.namespace,
    required this.event,
    required this.payload,
    required this.timestamp,
  });
}

class RealtimeGatewayService {
  static String get _wsBaseUrl => dotenv.get('WS_BASE_URL', fallback: 'ws://localhost:3002');
  static const Duration _connectTimeout = Duration(seconds: 30);

  final AuthPrefDataSource _authPrefDataSource;
  final FirebaseMessaging _firebaseMessaging;
  final GetRefreshTokenUseCase _getRefreshTokenUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;

  dynamic _chatSocket;
  dynamic _callSocket;

  bool _isInitialized = false;
  bool _isConnecting = false;
  bool _isRefreshingToken = false;
  bool _chatAuthenticated = false;
  bool _callAuthenticated = false;
  Timer? _reconnectTimer;

  final StreamController<RealtimeGatewayEvent> _eventsController =
      StreamController<RealtimeGatewayEvent>.broadcast();

  RealtimeGatewayService({
    required AuthPrefDataSource authPrefDataSource,
    required FirebaseMessaging firebaseMessaging,
    required GetRefreshTokenUseCase getRefreshTokenUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
  })  : _authPrefDataSource = authPrefDataSource,
        _firebaseMessaging = firebaseMessaging,
        _getRefreshTokenUseCase = getRefreshTokenUseCase,
        _refreshTokenUseCase = refreshTokenUseCase;

  Stream<RealtimeGatewayEvent> get events => _eventsController.stream;

  bool get isConnected => _chatAuthenticated || _callAuthenticated;

  Future<void> initialize() async {
    if (_isInitialized || _isConnecting) return;
    _isInitialized = true;
    await reconnect();

    // Keep trying in background so service can connect after login/token availability.
    _reconnectTimer ??= Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isConnecting && !isConnected) {
        unawaited(reconnect());
      }
    });
  }

  Future<void> reconnect() async {
    if (_isConnecting || isConnected) return;
    _isConnecting = true;

    try {
      final accessToken = await _resolveAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('[RealtimeGatewayService] Skip connect: missing access token');
        return;
      }

      // deviceId must be FCM device token for notification routing.
      final deviceToken = await _firebaseMessaging.getToken();
      if (deviceToken == null || deviceToken.isEmpty) {
        throw Exception('Missing FCM device token for websocket authenticate');
      }

      _disposeSockets();

      await _connectChatNamespace(accessToken: accessToken, deviceToken: deviceToken);
      await _connectCallNamespace(accessToken: accessToken);
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _connectChatNamespace({
    required String accessToken,
    required String deviceToken,
  }) async {
    final socket = io.io(
      '$_wsBaseUrl/chat',
      io.OptionBuilder()
          .setAuth({'token': 'Bearer $accessToken'})
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(1000)
          .setTransports(['websocket'])
          .build(),
    );

    _chatSocket = socket;
    _attachBaseListeners(socket: socket, namespace: '/chat', onDisconnected: () {
      _chatAuthenticated = false;
    });

    await _waitForConnected(socket, '/chat');

    await _waitForAuthenticated(
      socket: socket,
      namespace: '/chat',
      payload: {
        'token': accessToken,
        'deviceId': deviceToken,
        'deviceType': 'mobile',
      },
      onAuthenticated: () => _chatAuthenticated = true,
    );

    _attachChatEventListeners(socket);
  }

  Future<void> _connectCallNamespace({
    required String accessToken,
  }) async {
    final socket = io.io(
      '$_wsBaseUrl/call',
      io.OptionBuilder()
          .setAuth({'token': 'Bearer $accessToken'})
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(1000)
          .setTransports(['websocket'])
          .build(),
    );

    _callSocket = socket;
    _attachBaseListeners(socket: socket, namespace: '/call', onDisconnected: () {
      _callAuthenticated = false;
    });

    await _waitForConnected(socket, '/call');

    await _waitForAuthenticated(
      socket: socket,
      namespace: '/call',
      payload: {'token': accessToken},
      onAuthenticated: () => _callAuthenticated = true,
    );

    _attachCallEventListeners(socket);
  }

  void _attachBaseListeners({
    required dynamic socket,
    required String namespace,
    required VoidCallback onDisconnected,
  }) {
    socket.on('disconnect', (reason) {
      debugPrint('[RealtimeGatewayService] $namespace disconnected: $reason');
      onDisconnected();
    });

    socket.on('connect_error', (error) {
      debugPrint('[RealtimeGatewayService] $namespace connect_error: $error');
      _publishEvent(namespace: namespace, event: 'connect_error', payload: error);
      _maybeRecoverFromAuthError(error);
    });

    socket.on('error', (error) {
      debugPrint('[RealtimeGatewayService] $namespace error: $error');
      _publishEvent(namespace: namespace, event: 'error', payload: error);
      _maybeRecoverFromAuthError(error);
    });
  }

  Future<void> _waitForConnected(dynamic socket, String namespace) {
    final completer = Completer<void>();
    late Timer timeout;

    timeout = Timer(_connectTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(Exception('$namespace connect timeout after ${_connectTimeout.inSeconds}s'));
      }
    });

    socket.onConnect((_) {
      if (!completer.isCompleted) {
        timeout.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> _waitForAuthenticated({
    required dynamic socket,
    required String namespace,
    required Map<String, dynamic> payload,
    required VoidCallback onAuthenticated,
  }) {
    final completer = Completer<void>();
    late Timer timeout;

    timeout = Timer(_connectTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('$namespace authenticate timeout after ${_connectTimeout.inSeconds}s'),
        );
      }
    });

    socket.on('authenticated', (data) {
      if (!completer.isCompleted) {
        onAuthenticated();
        timeout.cancel();
        completer.complete();
      }
      _publishEvent(namespace: namespace, event: 'authenticated', payload: data);
    });

    socket.emit('authenticate', payload);
    return completer.future;
  }

  void _attachChatEventListeners(dynamic socket) {
    const events = <String>[
      'message:new',
      'message:saved',
      'message:notify',
      'message:edited',
      'message:deleted',
      'message:updated',
      'message:queued',
      'message:rejected',
      'message:error',
      'typing:started',
      'typing:stopped',
      'user:online',
      'user:offline',
      'conversation:member-added',
      'conversation:member-removed',
      'conversation:removed',
      'conversation:updated',
      'cursor:seen_updated',
      'cursor:delivered_updated',
      'heartbeat:ack',
    ];

    for (final event in events) {
      socket.on(event, (payload) {
        _publishEvent(namespace: '/chat', event: event, payload: payload);
      });
    }
  }

  void _attachCallEventListeners(dynamic socket) {
    const events = <String>[
      'meeting:started',
      'meeting:join_requested',
      'meeting:participant_joined',
      'meeting:participant_left',
      'meeting:approved',
      'meeting:rejected',
      'meeting:ended',
      'meeting:media_state',
      'meeting:recording_state',
      'meeting:participant_moderated',
      'meeting:kicked',
    ];

    for (final event in events) {
      socket.on(event, (payload) {
        _publishEvent(namespace: '/call', event: event, payload: payload);
      });
    }
  }

  void _publishEvent({
    required String namespace,
    required String event,
    required dynamic payload,
  }) {
    if (_eventsController.isClosed) return;
    _eventsController.add(
      RealtimeGatewayEvent(
        namespace: namespace,
        event: event,
        payload: payload,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<String?> _resolveAccessToken() async {
    final accessToken = await _authPrefDataSource.getAccessToken();
    if (TokenUtils.isTokenValid(accessToken)) {
      return accessToken;
    }

    final refreshed = await _tryRefreshAccessToken();
    if (refreshed == null || refreshed.isEmpty) {
      debugPrint('[RealtimeGatewayService] Unable to refresh expired access token');
      return null;
    }

    return refreshed;
  }

  Future<String?> _tryRefreshAccessToken() async {
    final refreshResult = await _getRefreshTokenUseCase();
    final refreshToken = refreshResult.fold((_) => null, (token) => token);
    if (!TokenUtils.isRefreshTokenValid(refreshToken)) {
      return null;
    }

    final result = await _refreshTokenUseCase(refreshToken!);
    final refreshed = result.fold((_) => false, (_) => true);
    if (!refreshed) {
      return null;
    }

    final newAccessToken = await _authPrefDataSource.getAccessToken();
    return TokenUtils.isTokenValid(newAccessToken) ? newAccessToken : null;
  }

  void _maybeRecoverFromAuthError(dynamic error) {
    if (_isRefreshingToken) return;
    if (!_looksLikeAuthError(error)) return;
    unawaited(_refreshAndReconnect());
  }

  bool _looksLikeAuthError(dynamic error) {
    final text = (error ?? '').toString().toLowerCase();
    return text.contains('401') ||
        text.contains('unauthorized') ||
        text.contains('jwt') ||
        text.contains('token') ||
        text.contains('forbidden');
  }

  Future<void> _refreshAndReconnect() async {
    if (_isRefreshingToken) return;
    _isRefreshingToken = true;

    try {
      final refreshedAccessToken = await _tryRefreshAccessToken();
      if (refreshedAccessToken == null || refreshedAccessToken.isEmpty) {
        return;
      }

      _chatAuthenticated = false;
      _callAuthenticated = false;
      _disposeSockets();
      await reconnect();
    } finally {
      _isRefreshingToken = false;
    }
  }

  Future<void> dispose() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _disposeSockets();
    await _eventsController.close();
    _chatAuthenticated = false;
    _callAuthenticated = false;
    _isInitialized = false;
  }

  void _disposeSockets() {
    _chatSocket?.disconnect();
    _chatSocket?.dispose();
    _chatSocket = null;

    _callSocket?.disconnect();
    _callSocket?.dispose();
    _callSocket = null;
  }
}
