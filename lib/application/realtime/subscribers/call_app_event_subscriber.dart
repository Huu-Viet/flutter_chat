import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_mapper.dart';
import 'package:flutter_chat/features/call/export.dart';

class CallAppEventSubscriber extends AppEventSubscriber {
  final void Function(CallInfo call) setIncomingCall;
  final void Function(CallInfo? call) updateIncomingCall;

  final void Function(String callId) onCallAccepted;
  final void Function(String callId) onCallDeclined;
  final void Function(String callId) onCallEnded;

  final bool Function(String callId) isClosedCall;
  final void Function(String callId) markClosedCall;
  final CallRepository callRepository;

  CallAppEventSubscriber({
    required this.setIncomingCall,
    required this.updateIncomingCall,
    required this.onCallAccepted,
    required this.onCallDeclined,
    required this.onCallEnded,
    required this.isClosedCall,
    required this.markClosedCall,
    required this.callRepository,
  });

  @override
  bool supports(AppEvent event) => event.namespace == '/call';

  @override
  Future<void> onEvent(AppEvent event) async {
    switch (event.type) {
      case 'call:ringing':
        debugPrint(
          '[CALL] event received: ${event.type}, payload=${event.payload}',
        );
        final call = _mapEventCall(event.payload, fallbackStatus: 'RINGING');
        if (_isClosedCall(call.id)) {
          debugPrint('[CALL] ignored ringing for closed call id=${call.id}');
          break;
        }
        debugPrint(
          '[CALL] parsed ringing call -> id=${call.id}, conversationId=${call.conversationId}, callerId=${call.callerId}, status=${call.status}',
        );

        // 1. update state
        setIncomingCall(call);

        // 2. side effect
        await callRepository.joinSocketCall(call.id);

        break;
      case 'call:accepted':
        debugPrint(
          '[CALL] event received: ${event.type}, payload=${event.payload}',
        );
        final payload = _eventPayloadMap(event.payload);
        final call = _mapEventCall(payload, fallbackStatus: 'ACTIVE');
        if (_isClosedCall(call.id)) {
          debugPrint('[CALL] ignored accepted for closed call id=${call.id}');
          break;
        }
        debugPrint(
          '[CALL] parsed accepted call -> id=${call.id}, conversationId=${call.conversationId}, callerId=${call.callerId}, status=${call.status}',
        );

        updateIncomingCall(null);

        final callId = call.id.trim().isNotEmpty
            ? call.id
            : (_extractCallId(payload) ?? '');
        if (callId.isNotEmpty) {
          onCallAccepted(callId);
        }
        break;
      case 'call:declined':
        final payload = _eventPayloadMap(event.payload);
        final callId = _extractCallId(payload);
        final isGroupCall = _isGroupPayload(payload);

        if (!isGroupCall) {
          _markClosedCall(callId);
        }

        updateIncomingCall(null);

        if (!isGroupCall && callId != null && callId.isNotEmpty) {
          onCallDeclined(callId);
        }

        break;
      case 'call:end':
      case 'call:ended':
        final payload = _eventPayloadMap(event.payload);
        final callId = _extractCallId(payload);

        _markClosedCall(callId);

        updateIncomingCall(null);

        if (callId != null && callId.isNotEmpty) {
          onCallEnded(callId);
        }

        break;
    }
  }

  bool _isClosedCall(String callId) {
    final normalizedCallId = callId.trim();
    return normalizedCallId.isNotEmpty && isClosedCall(normalizedCallId);
  }

  void _markClosedCall(String? callId) {
    final normalizedCallId = callId?.trim();
    if (normalizedCallId == null || normalizedCallId.isEmpty) return;
    markClosedCall(normalizedCallId);
  }

  CallInfo _mapEventCall(dynamic payload, {required String fallbackStatus}) {
    final data = _eventPayloadMap(payload);
    data['status'] ??= fallbackStatus;
    return ApiCallMapper().toDomain(CallDto.fromJson(data));
  }

  Map<String, dynamic> _eventPayloadMap(dynamic payload) {
    final data = payload is Map<String, dynamic>
        ? Map<String, dynamic>.from(payload)
        : Map<String, dynamic>.from(payload as Map);
    final nested = data['data'] ?? data['call'];
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }
    return data;
  }

  String? _extractCallId(Map<String, dynamic> payload) {
    final candidates = [
      payload['callId'],
      payload['call_id'],
      payload['id'],
      payload['call'] is Map ? (payload['call'] as Map)['id'] : null,
      payload['data'] is Map ? (payload['data'] as Map)['id'] : null,
      payload['data'] is Map ? (payload['data'] as Map)['callId'] : null,
    ];
    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  bool _isGroupPayload(Map<String, dynamic> payload) {
    final type = payload['conversationType'] ?? payload['type'];
    if (type?.toString().toLowerCase() == 'group') return true;
    final participants = payload['participants'];
    if (participants is List && participants.length > 2) return true;
    return false;
  }
}
