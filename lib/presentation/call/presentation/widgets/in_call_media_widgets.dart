part of '../in_call_page.dart';

class _LiveKitCallStage extends StatelessWidget {
  final Room? room;
  final CallSession session;
  final bool isConnecting;
  final String? errorMessage;

  const _LiveKitCallStage({
    required this.room,
    required this.session,
    required this.isConnecting,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final activeRoom = room;
    if (isConnecting) {
      return const _CenteredCallStatus(
        icon: Icons.call,
        title: 'Connecting media...',
        subtitle: 'Joining LiveKit room',
        showProgress: true,
      );
    }

    if (errorMessage != null) {
      return _CenteredCallStatus(
        icon: Icons.error_outline,
        title: 'Media unavailable',
        subtitle: errorMessage!,
      );
    }

    if (activeRoom == null) {
      return const _CenteredCallStatus(
        icon: Icons.call,
        title: 'Call in Progress',
        subtitle: 'Waiting for media session',
      );
    }

    final remoteTiles = activeRoom.remoteParticipants.values
        .map(_VideoTileData.fromParticipant)
        .where((tile) => tile.hasCameraTrack)
        .toList();
    final localTile = _localTile(activeRoom.localParticipant);
    final localVideoTile = localTile?.hasCameraTrack == true ? localTile : null;

    if (remoteTiles.isEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _AudioOnlyCallView(room: activeRoom, session: session),
          if (localVideoTile != null)
            Positioned(
              right: 20,
              bottom: 148,
              child: _PictureInPictureVideo(tile: localVideoTile),
            ),
        ],
      );
    }

    if (remoteTiles.length == 1) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _VideoTile(tile: remoteTiles.first, fill: true),
          if (localVideoTile != null)
            Positioned(
              right: 20,
              bottom: 148,
              child: _PictureInPictureVideo(tile: localVideoTile),
            ),
        ],
      );
    }

    final tiles = <_VideoTileData>[
      ...remoteTiles,
      if (localVideoTile != null) localVideoTile,
    ];
    return _VideoGrid(tiles: tiles);
  }

  _VideoTileData? _localTile(LocalParticipant? participant) {
    if (participant == null) return null;
    return _VideoTileData.fromParticipant(participant, isLocal: true);
  }
}

class _VideoTileData {
  final Participant participant;
  final VideoTrack? track;
  final bool isLocal;
  final bool hasCameraTrack;

  const _VideoTileData({
    required this.participant,
    required this.track,
    required this.isLocal,
    required this.hasCameraTrack,
  });

  factory _VideoTileData.fromParticipant(
    Participant participant, {
    bool isLocal = false,
  }) {
    final track = _activeCameraTrack(participant);
    return _VideoTileData(
      participant: participant,
      track: track,
      isLocal: isLocal,
      hasCameraTrack: track != null,
    );
  }

  String get title {
    final displayName = participant.name.trim().isNotEmpty
        ? participant.name.trim()
        : participant.identity.trim();
    if (displayName.isEmpty) return isLocal ? 'You' : 'Participant';
    return isLocal ? 'You' : displayName;
  }

  static VideoTrack? _activeCameraTrack(Participant participant) {
    for (final publication in participant.videoTrackPublications) {
      if (publication.isScreenShare || publication.muted) continue;
      final track = publication.track;
      if (track is VideoTrack && !track.muted) return track;
    }
    return null;
  }
}

class _VideoTile extends StatelessWidget {
  final _VideoTileData tile;
  final bool fill;

  const _VideoTile({required this.tile, this.fill = false});

  @override
  Widget build(BuildContext context) {
    final track = tile.track;
    return Container(
      color: Colors.black,
      foregroundDecoration: tile.participant.isSpeaking
          ? BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 3),
            )
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (track != null)
            VideoTrackRenderer(
              track,
              fit: fill ? VideoViewFit.cover : VideoViewFit.contain,
              renderMode: VideoRenderMode.auto,
            )
          else
            _ParticipantAvatar(
              title: tile.title,
              isSpeaking: tile.participant.isSpeaking,
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _ParticipantLabel(
              title: tile.title,
              isMuted: !_hasActiveAudio(tile.participant),
            ),
          ),
        ],
      ),
    );
  }

  static bool _hasActiveAudio(Participant participant) {
    for (final publication in participant.audioTrackPublications) {
      if (!publication.muted && publication.subscribed) return true;
    }
    return false;
  }
}

class _PictureInPictureVideo extends StatelessWidget {
  final _VideoTileData tile;

  const _PictureInPictureVideo({required this.tile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 170,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _VideoTile(tile: tile, fill: true),
    );
  }
}

class _VideoGrid extends StatelessWidget {
  final List<_VideoTileData> tiles;

  const _VideoGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 72, 12, 132),
      child: GridView.builder(
        itemCount: tiles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: tiles.length <= 2 ? 1 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: tiles.length <= 2 ? 16 / 10 : 3 / 4,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _VideoTile(tile: tiles[index], fill: true),
          );
        },
      ),
    );
  }
}

class _AudioOnlyCallView extends StatelessWidget {
  final Room room;
  final CallSession session;

  const _AudioOnlyCallView({required this.room, required this.session});

  @override
  Widget build(BuildContext context) {
    final participants = <Participant>[
      ...room.remoteParticipants.values,
      if (room.localParticipant != null) room.localParticipant!,
    ];
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF202020), Color(0xFF050505)],
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 92, 24, 160),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ParticipantAvatar(
              title: session.call.callerId,
              isSpeaking: false,
              size: 112,
            ),
            const SizedBox(height: 24),
            const Text(
              'Audio Call',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Video will appear when someone turns on camera',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: participants
                  .map(
                    (participant) => _AudioParticipantChip(
                      participant: participant,
                      isLocal: participant is LocalParticipant,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioParticipantChip extends StatelessWidget {
  final Participant participant;
  final bool isLocal;

  const _AudioParticipantChip({
    required this.participant,
    required this.isLocal,
  });

  @override
  Widget build(BuildContext context) {
    final title = participant.name.trim().isNotEmpty
        ? participant.name.trim()
        : participant.identity.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: participant.isSpeaking
            ? Colors.green.withValues(alpha: 0.25)
            : Colors.white10,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: participant.isSpeaking ? Colors.greenAccent : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            participant.isSpeaking ? Icons.graphic_eq : Icons.person,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isLocal ? 'You' : (title.isEmpty ? 'Participant' : title),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  final String title;
  final bool isSpeaking;
  final double size;

  const _ParticipantAvatar({
    required this.title,
    required this.isSpeaking,
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    final initial = title.trim().isNotEmpty
        ? title.trim()[0].toUpperCase()
        : '?';
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white12,
          border: Border.all(
            color: isSpeaking ? Colors.greenAccent : Colors.white24,
            width: isSpeaking ? 4 : 1,
          ),
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantLabel extends StatelessWidget {
  final String title;
  final bool isMuted;

  const _ParticipantLabel({required this.title, required this.isMuted});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
