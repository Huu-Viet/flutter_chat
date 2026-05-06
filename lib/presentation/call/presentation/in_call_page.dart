import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/core/platform_services/platform_service_providers.dart';
import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_chat/presentation/call/blocs/in_call_bloc.dart';
import 'package:flutter_chat/presentation/call/providers/call_bloc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';

part 'widgets/in_call_media_widgets.dart';
part 'widgets/in_call_control_widgets.dart';

class InCallPage extends ConsumerWidget {
  final String conversationId;
  final String initialRoomName;

  const InCallPage({
    super.key,
    required this.conversationId,
    required this.initialRoomName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bloc = ref.watch(inCallBlocProvider);

    return BlocProvider<InCallBloc>.value(
      value: bloc,
      child: BlocListener<InCallBloc, InCallState>(
        listenWhen: (previous, current) =>
            current is InCallEnded ||
            previous.errorMessage != current.errorMessage ||
            previous.mediaErrorMessage != current.mediaErrorMessage ||
            previous.endStatus != current.endStatus,
        listener: (context, state) {
          if (state is InCallEnded) {
            ref.read(notiServiceProvider).endCallKit(state.endedCallId);
            debugPrint('[InCallPage]Check conversation: $conversationId');
            if ((state.endedCallId ?? '').trim().isEmpty &&
                conversationId.trim().isNotEmpty) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(
                  '/chat/${Uri.encodeComponent(conversationId)}/${Uri.encodeComponent(initialRoomName.trim().isEmpty ? 'Group' : initialRoomName)}',
                );
              }
              return;
            }
            context.go('/home');
          }

          final message = state.errorMessage ?? state.mediaErrorMessage;
          if (message != null && message.trim().isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            context.read<InCallBloc>().add(const InCallErrorCleared());
          }
        },
        child: BlocBuilder<InCallBloc, InCallState>(
          builder: (context, state) {
            final activeSession = state.session;

            // Show error UI if there's an error and no session
            if (activeSession == null &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (activeSession == null) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final participantCount = _activeParticipantCount(
              state,
              activeSession,
            );
            final isRinging = _isRinging(activeSession);
            final willEndCall =
                !activeSession.isGroupCall || participantCount <= 2;

            if (!isRinging) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    Positioned.fill(
                      // Use a nested BlocBuilder with buildWhen so the video
                      // stage only rebuilds when tracks/participants actually
                      // change (videoRevision bump). This prevents
                      // VideoTrackRenderer from being recreated on every
                      // ActiveSpeakersChanged event, which is the main cause
                      // of the partner video flickering.
                      child: BlocBuilder<InCallBloc, InCallState>(
                        buildWhen: (previous, current) =>
                            previous.room != current.room ||
                            previous.isConnectingRoom !=
                                current.isConnectingRoom ||
                            previous.isAcceptingCall !=
                                current.isAcceptingCall ||
                            previous.mediaErrorMessage !=
                                current.mediaErrorMessage ||
                            previous.videoRevision != current.videoRevision,
                        builder: (context, videoState) => _LiveKitCallStage(
                          room: videoState.room,
                          session: activeSession,
                          isConnecting:
                              videoState.isConnectingRoom ||
                              videoState.isAcceptingCall,
                          errorMessage: videoState.mediaErrorMessage,
                          peerName: initialRoomName.isNotEmpty
                              ? initialRoomName
                              : (activeSession.call.callerName.isNotEmpty
                                  ? activeSession.call.callerName
                                  : 'Participant'),
                          peerAvatar: activeSession.call.callerAvatar.isNotEmpty
                              ? activeSession.call.callerAvatar
                              : null,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              color: Colors.white,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                            ),
                            const Spacer(),
                            _CallInfoPill(
                              title: initialRoomName.isNotEmpty
                                  ? initialRoomName
                                  : 'Call in Progress',
                              subtitle: 'Participants: $participantCount',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: _ActiveCallControls(
                          isEndingCall: state.isEndingCall,
                          isMicEnabled: state.isMicEnabled,
                          isCameraEnabled: state.isCameraEnabled,
                          isSpeakerOn: state.isSpeakerOn,
                          isGroupCall: activeSession.isGroupCall,
                          willEndCall: willEndCall,
                          isMicUpdating: state.isMicUpdating,
                          isCameraUpdating: state.isCameraUpdating,
                          onToggleMic: () => context.read<InCallBloc>().add(
                            const InCallToggleMicrophoneRequested(),
                          ),
                          onToggleCamera: () => context.read<InCallBloc>().add(
                            const InCallToggleCameraRequested(),
                          ),
                          onToggleSpeaker: () => context.read<InCallBloc>().add(
                            const InCallToggleSpeakerRequested(),
                          ),
                          onEndCall: () {
                            if (!willEndCall) {
                              _cacheActiveGroupCallForRejoin(
                                ref,
                                activeSession.call,
                                participantCount,
                              );
                            }
                            context.read<InCallBloc>().add(
                              const InCallEndRequested(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A1A2E), Color(0xFF050510)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            color: Colors.white,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Pulsing avatar
                      _PulsingCallAvatar(
                        name: initialRoomName.isNotEmpty
                            ? initialRoomName
                            : (activeSession.call.callerName.isNotEmpty
                                ? activeSession.call.callerName
                                : '?'),
                        avatarUrl: activeSession.call.callerAvatar.isNotEmpty
                            ? activeSession.call.callerAvatar
                            : null,
                        size: 96,
                      ),
                      const SizedBox(height: 32),
                      // Name
                      if (initialRoomName.isNotEmpty) ...[
                        Text(
                          initialRoomName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Status
                      Text(
                        activeSession.isIncoming
                            ? 'Connecting...'
                            : 'Calling...',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      // Cancel button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: _RingingCallPanel(
                          isEndingCall: state.isEndingCall,
                          onCancel: () => context.read<InCallBloc>().add(
                            const InCallEndRequested(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isRinging(CallSession session) {
    final status = session.call.status.trim().toUpperCase();
    final hasMediaSession =
        session.token.trim().isNotEmpty ||
        session.roomName.trim().isNotEmpty ||
        session.liveKitUrl.trim().isNotEmpty;
    if (hasMediaSession) return false;
    return !{
      'ACTIVE',
      'ACCEPTED',
      'CONNECTED',
      'ENDED',
      'DECLINED',
      'CANCELLED',
      'CANCELED',
      'FAILED',
    }.contains(status);
  }

  int _activeParticipantCount(InCallState state, CallSession session) {
    final room = state.room;
    if (room != null) {
      return room.remoteParticipants.length + 1;
    }
    return session.call.participants.isNotEmpty
        ? session.call.participants.length
        : 1;
  }

  void _cacheActiveGroupCallForRejoin(
    WidgetRef ref,
    CallInfo call,
    int participantCount,
  ) {
    final normalizedConversationId = call.conversationId.trim().isNotEmpty
        ? call.conversationId.trim()
        : conversationId.trim();
    final normalizedCallId = call.id.trim();
    if (normalizedConversationId.isEmpty ||
        normalizedCallId.isEmpty ||
        participantCount <= 2) {
      return;
    }

    final previous = ref.read(activeGroupCallsProvider);
    ref.read(activeGroupCallsProvider.notifier).state = {
      ...previous,
      normalizedConversationId: ActiveGroupCallState(
        call: call,
        participantCount: participantCount,
      ),
    };
  }
}
