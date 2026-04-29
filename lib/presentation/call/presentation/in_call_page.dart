import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:flutter_chat/presentation/call/blocs/in_call_bloc.dart';
import 'package:flutter_chat/presentation/call/providers/call_bloc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InCallPage extends ConsumerStatefulWidget {
  const InCallPage({super.key});

  @override
  ConsumerState<InCallPage> createState() => _InCallPageState();
}

class _InCallPageState extends ConsumerState<InCallPage> {
  late final ProviderSubscription _sessionSubscription;
  bool _isClosingPage = false;

  @override
  void initState() {
    super.initState();
    _sessionSubscription = ref.listenManual<CallSession?>(
      currentCallSessionProvider,
      (previous, next) {
        ref.read(inCallBlocProvider).add(InCallSessionChanged(next));
        if (previous != null && next == null) {
          _closePage();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _sessionSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ref.watch(inCallBlocProvider);

    return BlocProvider<InCallBloc>.value(
      value: bloc,
      child: BlocListener<InCallBloc, InCallState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.endStatus != current.endStatus,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<InCallBloc>().add(const InCallErrorCleared());
          }

          if (state.endStatus == InCallEndStatus.success) {
            ref.read(currentCallSessionProvider.notifier).state = null;
            context.read<InCallBloc>().add(const InCallEndStatusConsumed());
            _closePage();
          }
        },
        child: BlocBuilder<InCallBloc, InCallState>(
          builder: (context, state) {
            final activeSession = state.session;

            if (activeSession == null) {
              _closePage();
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final participantCount = activeSession.call.participants.length;
            final isRinging = _isRinging(activeSession);

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
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
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
                        isRinging
                            ? (activeSession.isIncoming
                                  ? 'Connecting...'
                                  : 'Ringing...')
                            : 'Call in Progress',
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
                        'Room: ${activeSession.roomName}',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 6),
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
                      if (isRinging)
                        _RingingCallPanel(
                          isEndingCall: state.isEndingCall,
                          onCancel: () {
                            context.read<InCallBloc>().add(
                              const InCallEndRequested(),
                            );
                          },
                        )
                      else
                        _ActiveCallControls(
                          isEndingCall: state.isEndingCall,
                          onEndCall: () {
                            context.read<InCallBloc>().add(
                              const InCallEndRequested(),
                            );
                          },
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
    return status == 'RINGING' && !hasMediaSession;
  }

  void _closePage() {
    if (_isClosingPage) return;
    _isClosingPage = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }
}

class _RingingCallPanel extends StatelessWidget {
  final bool isEndingCall;
  final VoidCallback onCancel;

  const _RingingCallPanel({required this.isEndingCall, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          'Waiting for the other person to answer...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
          onPressed: isEndingCall ? null : onCancel,
          icon: isEndingCall
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.call_end),
          label: Text(isEndingCall ? 'Cancelling...' : 'Cancel'),
        ),
      ],
    );
  }
}

class _ActiveCallControls extends StatelessWidget {
  final bool isEndingCall;
  final VoidCallback onEndCall;

  const _ActiveCallControls({
    required this.isEndingCall,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Call UI placeholder is ready. Media setup can be attached next.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CallActionButton(
                icon: Icons.mic_off,
                label: 'Mute',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mute action is not connected yet.'),
                    ),
                  );
                },
              ),
              _CallActionButton(
                icon: Icons.volume_up,
                label: 'Speaker',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Speaker action is not connected yet.'),
                    ),
                  );
                },
              ),
              _CallActionButton(
                icon: Icons.videocam,
                label: 'Video',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Video action is not connected yet.'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: isEndingCall ? null : onEndCall,
              icon: isEndingCall
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.call_end),
              label: Text(isEndingCall ? 'Ending...' : 'End Call'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
