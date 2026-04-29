import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/application/realtime/events/app_event.dart';
import 'package:flutter_chat/application/realtime/subscribers/app_event_subscriber.dart';
import 'package:flutter_chat/features/call/data/mappers/api_call_mapper.dart';
import 'package:flutter_chat/features/call/export.dart';

class CallAppEventSubscriber extends AppEventSubscriber {
  final void Function(CallInfo call) setIncomingCall;
  final void Function(CallInfo? call) updateIncomingCall;
  final void Function(CallSession? session) updateCurrentCallSession;
  final CallSession? Function() getCurrentCallSession;
  final CallRepository callRepository;

  const CallAppEventSubscriber({
    required this.setIncomingCall,
    required this.updateIncomingCall,
    required this.updateCurrentCallSession,
    required this.getCurrentCallSession,
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
        final call = _mapEventCall(event.payload, fallbackStatus: 'ACTIVE');
        debugPrint(
          '[CALL] parsed accepted call -> id=${call.id}, conversationId=${call.conversationId}, callerId=${call.callerId}, status=${call.status}',
        );

        updateIncomingCall(null);

        final currentSession = await callRepository.getCallToken(call.id);
        currentSession.fold(
          (failure) => debugPrint(
            '[CALL] failed to fetch token after accepted event: ${failure.message}',
          ),
          (token) {
            final previousSession = getCurrentCallSession();
            final resolvedCall = _mergeAcceptedCall(
              previousSession?.call,
              call,
            );
            updateCurrentCallSession(
              CallSession(
                call: resolvedCall,
                token: token.token,
                roomName: token.roomName,
                liveKitUrl: token.liveKitUrl,
                isIncoming: previousSession?.isIncoming ?? false,
              ),
            );
          },
        );
        break;
      case 'call:declined':
        debugPrint('[CALL] event received: ${event.type}');
        final declinedPayload = _eventPayloadMap(event.payload);
        final declinedCallId = declinedPayload['callId'] as String?;
        if (declinedCallId != null && declinedCallId.isNotEmpty) {
          await callRepository.leaveSocketCall(declinedCallId);
        }
        updateIncomingCall(null);
        updateCurrentCallSession(null);
        break;
      case 'call:end':
      case 'call:ended':
        debugPrint('[CALL] event received: ${event.type}');
        final endedPayload = _eventPayloadMap(event.payload);
        final endedCallId = endedPayload['callId'] as String?;
        if (endedCallId != null && endedCallId.isNotEmpty) {
          await callRepository.leaveSocketCall(endedCallId);
        }
        updateIncomingCall(null);
        updateCurrentCallSession(null);
        break;
    }
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

  CallInfo _mergeAcceptedCall(CallInfo? previousCall, CallInfo acceptedCall) {
    if (previousCall == null) {
      return acceptedCall;
    }

    final acceptedCallId = acceptedCall.id.trim();
    final previousCallId = previousCall.id.trim();
    if (acceptedCallId.isNotEmpty &&
        previousCallId.isNotEmpty &&
        previousCallId != acceptedCallId) {
      return acceptedCall;
    }

    return CallInfo(
      id: acceptedCallId.isNotEmpty ? acceptedCall.id : previousCall.id,
      conversationId: acceptedCall.conversationId.isNotEmpty
          ? acceptedCall.conversationId
          : previousCall.conversationId,
      callerId: acceptedCall.callerId.isNotEmpty
          ? acceptedCall.callerId
          : previousCall.callerId,
      status: acceptedCall.status.isNotEmpty
          ? acceptedCall.status
          : previousCall.status,
      createdAt: acceptedCall.createdAt,
      startedAt: acceptedCall.startedAt,
      endedAt: acceptedCall.endedAt,
      participants: acceptedCall.participants.isNotEmpty
          ? acceptedCall.participants
          : previousCall.participants,
    );
  }
}
