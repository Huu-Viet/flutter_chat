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
  final bool isGroupCall;
  final bool willEndCall;
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
    required this.isGroupCall,
    required this.willEndCall,
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
              label: Text(
                isEndingCall
                    ? (willEndCall ? 'Ending...' : 'Leaving...')
                    : (willEndCall ? 'End Call' : 'Leave'),
              ),
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
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _PulsingCallAvatar extends StatefulWidget {
  final String name;
  final String? avatarUrl;
  final double size;

  const _PulsingCallAvatar({
    required this.name,
    this.avatarUrl,
    this.size = 96,
  });

  @override
  State<_PulsingCallAvatar> createState() => _PulsingCallAvatarState();
}

class _PulsingCallAvatarState extends State<_PulsingCallAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final initial = widget.name.trim().isNotEmpty
        ? widget.name.trim()[0].toUpperCase()
        : '?';
    final hasAvatar =
        widget.avatarUrl != null && widget.avatarUrl!.trim().isNotEmpty;
    return SizedBox(
      width: s * 2,
      height: s * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                      .withValues(alpha: _opacityAnim.value),
                ),
              ),
            ),
          ),
          // Avatar circle
          Container(
            width: s,
            height: s,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF3C4043),
            ),
            child: ClipOval(
              child: hasAvatar
                  ? Image.network(
                      widget.avatarUrl!,
                      width: s,
                      height: s,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: s * 0.36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: s * 0.36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
