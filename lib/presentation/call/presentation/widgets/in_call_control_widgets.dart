part of '../in_call_page.dart';

class _CenteredCallStatus extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showProgress;

  const _CenteredCallStatus({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 56),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60),
            ),
            if (showProgress) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

class _CallInfoPill extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CallInfoPill({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
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
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final bool isSpeakerOn;
  final bool isMicUpdating;
  final bool isCameraUpdating;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onEndCall;

  const _ActiveCallControls({
    required this.isEndingCall,
    required this.isMicEnabled,
    required this.isCameraEnabled,
    required this.isSpeakerOn,
    required this.isMicUpdating,
    required this.isCameraUpdating,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleSpeaker,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CallActionButton(
                icon: isMicEnabled ? Icons.mic : Icons.mic_off,
                label: isMicUpdating
                    ? 'Mic...'
                    : (isMicEnabled ? 'Mute' : 'Unmute'),
                isActive: isMicEnabled,
                onTap: onToggleMic,
              ),
              _CallActionButton(
                icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                label: 'Speaker',
                isActive: isSpeakerOn,
                onTap: onToggleSpeaker,
              ),
              _CallActionButton(
                icon: isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                label: isCameraUpdating
                    ? 'Video...'
                    : (isCameraEnabled ? 'Video On' : 'Video Off'),
                isActive: isCameraEnabled,
                onTap: onToggleCamera,
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
  final bool isActive;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
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
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? Colors.black : Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
