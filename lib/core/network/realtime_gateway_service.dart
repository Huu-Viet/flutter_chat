import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/core/utils/token_utils.dart';
import 'package:flutter_chat/features/auth/data/datasources/local/auth_pref_datasource.dart';
import 'package:flutter_chat/features/auth/domain/usecases/get_refresh_token_usecase.dart';
import 'package:flutter_chat/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class RealtimeGatewayService implements RealtimeGateway {
  static String get _wsBaseUrl => dotenv.get('WS_BASE_URL');
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
  Timer? _chatHeartbeatTimer;
  Timer? _callHeartbeatTimer;

  final StreamController<RealtimeGatewayEvent> _eventsController =
      StreamController<RealtimeGatewayEvent>.broadcast();

  static const bool _enableRealtimeLogs = true;

  RealtimeGatewayService({
    required AuthPrefDataSource authPrefDataSource,
    required FirebaseMessaging firebaseMessaging,
    required GetRefreshTokenUseCase getRefreshTokenUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
  }) : _authPrefDataSource = authPrefDataSource,
       _firebaseMessaging = firebaseMessaging,
       _getRefreshTokenUseCase = getRefreshTokenUseCase,
       _refreshTokenUseCase = refreshTokenUseCase;

  @override
  Stream<RealtimeGatewayEvent> get events => _eventsController.stream;

  @override
  bool get isConnected => _chatAuthenticated || _callAuthenticated;

  @override
  Future<void> emitChatEvent(String event, Map<String, dynamic> payload) async {
    if (_chatSocket == null || !_chatAuthenticated) {
      throw Exception('Chat socket is not connected');
    }

    debugPrint('[RealtimeGatewayService] emit /chat $event: $payload');
    _chatSocket.emit(event, payload);
  }

  @override
  Future<void> emitCallEvent(String event, Map<String, dynamic> payload) async {
    if (_callSocket == null || !_callAuthenticated) {
      throw Exception('Call socket is not connected');
    }

    if (_enableRealtimeLogs) {
      debugPrint('[RealtimeGatewayService] emit /call $event: $payload');
    }
    _callSocket.emit(event, payload);
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized || _isConnecting) return;
    if (_enableRealtimeLogs) {
      debugPrint('[RealtimeGatewayService] initialize requested');
    }
    _isInitialized = true;
    _reconnectTimer ??= Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isConnecting && !isConnected) {
        unawaited(reconnect());
      }
    });

    // Initial attempt should never crash startup flow.
    unawaited(reconnect());
  }

  @override
  Future<void> reconnect() async {
    if (_isConnecting || isConnected) return;
    _isConnecting = true;

    if (_enableRealtimeLogs) {
      debugPrint('[RealtimeGatewayService] reconnect requested');
    }

    try {
      final accessToken = await _resolveAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint(
          '[RealtimeGatewayService] Skip connect: missing access token',
        );
        return;
      }

      if (_enableRealtimeLogs) {
        debugPrint(
          '[RealtimeGatewayService] access token ready for connect (${accessToken.length} chars)',
        );
      }

      // deviceId must be FCM device token for notification routing.
      final deviceToken = await _firebaseMessaging.getToken();
      if (deviceToken == null || deviceToken.isEmpty) {
        throw Exception('Missing FCM device token for websocket authenticate');
      }

      if (_enableRealtimeLogs) {
        debugPrint(
          '[RealtimeGatewayService] FCM token ready for connect (${deviceToken.length} chars)',
        );
      }

      _disposeSockets();

      await _connectChatNamespace(
        accessToken: accessToken,
        deviceToken: deviceToken,
      );
      await _connectCallNamespace(accessToken: accessToken);
    } catch (e) {
      debugPrint('[RealtimeGatewayService] reconnect failed: $e');
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _connectChatNamespace({
    required String accessToken,
    required String deviceToken,
  }) async {
    if (_enableRealtimeLogs) {
      debugPrint(
        '[RealtimeGatewayService] connecting namespace /chat -> $_wsBaseUrl/chat',
      );
    }

    final socket = io.io(
      '$_wsBaseUrl/chat',
      io.OptionBuilder()
          .setAuth({'token': accessToken})
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(1000)
          .setTransports(['websocket'])
          .build(),
    );

    _chatSocket = socket;
    _attachBaseListeners(
      socket: socket,
      namespace: '/chat',
      onDisconnected: () {
        _chatAuthenticated = false;
        _stopChatHeartbeat();
      },
    );

    await _waitForConnected(socket, '/chat');
    debugPrint('[RealtimeGatewayService] /chat connected');

    await _waitForAuthenticated(
      socket: socket,
      namespace: '/chat',
      payload: {
        'token': accessToken,
        'deviceId': deviceToken,
        'deviceType': 'mobile',
      },
      onAuthenticated: () {
        _chatAuthenticated = true;
        _startHeartbeat();
        debugPrint('[RealtimeGatewayService] /chat authenticated');
      },
    );

    _attachChatEventListeners(socket);
  }

  Future<void> _connectCallNamespace({required String accessToken}) async {
    if (_enableRealtimeLogs) {
      debugPrint(
        '[RealtimeGatewayService] connecting namespace /call -> $_wsBaseUrl/call',
      );
    }

    final socket = io.io(
      '$_wsBaseUrl/call',
      io.OptionBuilder()
          .setAuth({'token': accessToken})
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(1000)
          .setTransports(['websocket'])
          .build(),
    );

    _callSocket = socket;
    _attachBaseListeners(
      socket: socket,
      namespace: '/call',
      onDisconnected: () {
        _callAuthenticated = false;
        _stopCallHeartbeat();
      },
    );

    await _waitForConnected(socket, '/call');
    debugPrint('[RealtimeGatewayService] /call connected');

    await _waitForAuthenticated(
      socket: socket,
      namespace: '/call',
      payload: {'token': accessToken},
      onAuthenticated: () {
        _callAuthenticated = true;
        _startCallHeartbeat();
        debugPrint('[RealtimeGatewayService] /call authenticated');
      },
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
      _publishEvent(
        namespace: namespace,
        event: 'connect_error',
        payload: error,
      );
      _maybeRecoverFromAuthError(error);
    });

    socket.on('error', (error) {
      debugPrint('[RealtimeGatewayService] $namespace error: $error');
      _publishEvent(namespace: namespace, event: 'error', payload: error);
      _maybeRecoverFromAuthError(error);
    });
  }

  Future<void> _waitForConnected(dynamic socket, String namespace) {
    if (socket.connected == true) {
      return Future.value();
    }

    final completer = Completer<void>();
    late Timer timeout;

    timeout = Timer(_connectTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception(
            '$namespace connect timeout after ${_connectTimeout.inSeconds}s',
          ),
        );
      }
    });

    socket.on('connect', (_) {
      if (_enableRealtimeLogs) {
        debugPrint(
          '[RealtimeGatewayService] $namespace connect event received',
        );
      }
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
          Exception(
            '$namespace authenticate timeout after ${_connectTimeout.inSeconds}s',
          ),
        );
      }
    });

    socket.on('authenticated', (data) {
      if (_enableRealtimeLogs) {
        debugPrint(
          '[RealtimeGatewayService] $namespace authenticated payload: $data',
        );
      }
      if (!completer.isCompleted) {
        onAuthenticated();
        timeout.cancel();
        completer.complete();
      }
      _publishEvent(
        namespace: namespace,
        event: 'authenticated',
        payload: data,
      );
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
      'message:revoked',
      'message:deleted',
      'message:deleted_for_me',
      'message:updated',
      'message:pinned',
      'message:unpinned',
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
      'conversation:new',
      'conversation:created',
      'conversation:added',
      'group:created',
      'group:settings_updated',
      'group:member_role_changed',
      'group:member_kicked',
      'group:join_requested',
      'group:join_approved',
      'group:join_rejected',
      'group:disbanded',
      'group:poll_created',
      'group:poll_voted',
      'group:poll_closed',
      'friendship:request_sent',
      'friendship:request_received',
      'friendship:request_accepted',
      'friendship:request_rejected',
      'friendship:removed',
      'friendship:blocked',
      'friendship:unblocked',
      'cursor:seen_updated',
      'cursor:delivered_updated',
      'heartbeat:ack',
      'session_revoked',
    ];

    for (final event in events) {
      socket.on(event, (payload) {
        if (_enableRealtimeLogs) {
          _logChatEvent(event, payload);
        }
        if (event == 'session_revoked') {
          debugPrint(
            '[RealtimeGatewayService] ⚠️ SERVER SENT session_revoked: $payload',
          );
        }
        if (event == 'conversation:new') {
          debugPrint(
            '🔔 [Gateway] conversation:new RECEIVED at socket layer: $payload',
          );
        }
        _publishEvent(namespace: '/chat', event: event, payload: payload);
      });
    }
  }

  void _attachCallEventListeners(dynamic socket) {
    const events = <String>[
      'call:accept',
      'call:decline',
      'call:end',
      'call:ringing',
      'call:join_room',
      'call:leave_room',
      'call:accepted',
      'call:declined',
      'call:ended',
    ];

    for (final event in events) {
      socket.on(event, (payload) {
        debugPrint(
          '[RealtimeGatewayService] /call event received: $event -> $payload',
        );
        _publishEvent(namespace: '/call', event: event, payload: payload);
      });
    }
  }

  void _publishEvent({
    required String namespace,
    required String event,
    required dynamic payload,
  }) {
    if (_enableRealtimeLogs && event != 'heartbeat:ack') {
      debugPrint('[RealtimeGatewayService] publish $namespace::$event');
    }
    if (event == 'session_revoked') {
      debugPrint(
        '[RealtimeGatewayService] 📤 PUBLISHING session_revoked to event bus: $payload',
      );
    }
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
      debugPrint(
        '[RealtimeGatewayService] Unable to refresh expired access token',
      );
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

  @override
  Future<void> dispose() async {
    debugPrint('[RealtimeGatewayService] dispose start');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopAllHeartbeats();
    _disposeSockets();
    await _eventsController.close();
    _chatAuthenticated = false;
    _callAuthenticated = false;
    _isInitialized = false;
    debugPrint('[RealtimeGatewayService] dispose done');
  }

  void _startHeartbeat() {
    _stopChatHeartbeat();
    _chatHeartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_chatAuthenticated || _chatSocket == null) {
        return;
      }
      // debugPrint('[RealtimeGatewayService] /chat heartbeat -> emit');
      _chatSocket.emit('heartbeat');
    });
  }

  void _startCallHeartbeat() {
    _stopCallHeartbeat();
    _callHeartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (!_callAuthenticated || _callSocket == null) {
        return;
      }
      _callSocket.emit('heartbeat');
    });
  }

  void _stopChatHeartbeat() {
    _chatHeartbeatTimer?.cancel();
    _chatHeartbeatTimer = null;
  }

  void _stopCallHeartbeat() {
    _callHeartbeatTimer?.cancel();
    _callHeartbeatTimer = null;
  }

  void _stopAllHeartbeats() {
    _stopChatHeartbeat();
    _stopCallHeartbeat();
  }

  void _disposeSockets() {
    _stopAllHeartbeats();

    if (_chatSocket != null) {
      debugPrint('[RealtimeGatewayService] closing /chat socket');
    }
    _chatSocket?.disconnect();
    _chatSocket?.dispose();
    _chatSocket = null;

    if (_callSocket != null) {
      debugPrint('[RealtimeGatewayService] closing /call socket');
    }
    _callSocket?.disconnect();
    _callSocket?.dispose();
    _callSocket = null;
  }

  void _logChatEvent(String event, dynamic payload) {
    if (event == 'heartbeat:ack') {
      return;
    }

    final payloadPreview = _safePayloadPreview(payload);
    debugPrint(
      '[RealtimeGatewayService] /chat event received: $event -> $payloadPreview',
    );
  }

  String _safePayloadPreview(dynamic payload) {
    final text = payload?.toString() ?? 'null';
    if (text.length <= 500) {
      return text;
    }
    return '${text.substring(0, 500)}...';
  }
}
