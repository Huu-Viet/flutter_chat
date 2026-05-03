import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            debugPrint('[InCallPage]Check conversation: $conversationId');
            if (conversationId.trim().isNotEmpty) {
              context.go('/chat/$conversationId/$initialRoomName');
            } else {
              context.go('/home');
            }
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

            if (activeSession == null) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final participantCount = activeSession.call.participants.length;
            final isRinging = _isRinging(activeSession);

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
                            previous.isConnectingRoom != current.isConnectingRoom ||
                            previous.isAcceptingCall != current.isAcceptingCall ||
                            previous.mediaErrorMessage != current.mediaErrorMessage ||
                            previous.videoRevision != current.videoRevision,
                        builder: (context, videoState) => _LiveKitCallStage(
                          room: videoState.room,
                          session: activeSession,
                          isConnecting: videoState.isConnectingRoom || videoState.isAcceptingCall,
                          errorMessage: videoState.mediaErrorMessage,
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
                              title: activeSession.roomName.isNotEmpty
                                  ? activeSession.roomName
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
                          onEndCall: () => context.read<InCallBloc>().add(
                            const InCallEndRequested(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          color: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white12,
                        child: Text(
                          activeSession.call.callerId.isNotEmpty
                              ? activeSession.call.callerId
                                    .substring(0, 1)
                                    .toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        activeSession.isIncoming
                            ? 'Connecting...'
                            : 'Ringing...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeSession.call.callerId,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Participants: $participantCount',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Status: ${activeSession.call.status}',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const Spacer(),
                      _RingingCallPanel(
                        isEndingCall: state.isEndingCall,
                        onCancel: () => context.read<InCallBloc>().add(
                          const InCallEndRequested(),
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
}
