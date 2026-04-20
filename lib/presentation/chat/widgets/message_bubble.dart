import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat/core/utils/animated_sticker_sprite.dart';
import 'package:flutter_chat/core/utils/date_utils.dart';
import 'package:flutter_chat/core/utils/waveform_utils.dart';
import 'package:flutter_chat/presentation/chat/chat_image_cache_manager.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_reactions_bar.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;
  final ValueChanged<LongPressStartDetails>? onLongPressStart;
  final VoidCallback? onReactPressed;
  final bool showReactAction;

  const MessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
    this.onLongPressStart,
    this.onReactPressed,
    this.showReactAction = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _completeSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _completeSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayAudio(String audioUrl) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final normalized = audioUrl.trim();
        final uri = Uri.tryParse(normalized);
        final isRemote = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
        if (isRemote) {
          await _audioPlayer.play(UrlSource(normalized));
        } else {
          await _audioPlayer.play(DeviceFileSource(normalized));
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVisualMedia = message.imagePath != null;
    final bubble = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: hasVisualMedia ? EdgeInsets.zero : const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: hasVisualMedia
                ? Colors.transparent
                : message.isSentByMe
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(hasVisualMedia ? 8 : 16),
          ),
          child: _buildMessageContent(context),
        ),
        if (showReactAction)
          Positioned(
            right: message.isSentByMe ? null : -6,
            left: message.isSentByMe ? -6 : null,
            bottom: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onReactPressed,
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceBright,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.surfaceBright.withAlpha(20),
                        blurRadius: 36,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: 11,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Align(
      alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        onLongPressStart: onLongPressStart,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // Avatar for received messages — only on last in group
            if (!message.isSentByMe)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: message.isLastInGroup
                    ? CircleAvatar(
                        radius: 16,
                        backgroundImage: message.conversationAvatarUrl != null && message.conversationAvatarUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(message.conversationAvatarUrl!)
                            : null,
                        child: message.conversationAvatarUrl == null || message.conversationAvatarUrl!.isEmpty
                            ? const Icon(Icons.person, size: 18)
                            : null,
                      )
                    : const SizedBox(width: 32),
              ),
            Column(
              crossAxisAlignment:
                  message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                bubble,
                MessageReactionsBar(
                  reactions: message.reactions,
                  isSentByMe: message.isSentByMe,
                ),
              ],
            ),
          ],
        ),
    final isAudio = widget.message.messageType.trim().toLowerCase() == 'audio';

    return Align(
      alignment: widget.message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        width: isAudio ? MediaQuery.of(context).size.width * 0.7 : null,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: widget.message.isSentByMe ? Theme.of(context).colorScheme.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildMessageContent(),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.imagePath != null) {
      final imagePath = message.imagePath!;
      final isStickerMessage = message.type.trim().toLowerCase() == 'sticker';
      final isSpriteSticker = _isSpriteSticker();
      final uri = Uri.tryParse(imagePath);
      final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      final imageHeight = isStickerMessage ? 120.0 : 200.0;
      final imageFit = isStickerMessage ? BoxFit.contain : BoxFit.cover;

      final imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isSpriteSticker && isNetworkImage
            ? AnimatedStickerSprite(
                imageProvider: NetworkImage(imagePath),
                width: imageHeight,
                height: imageHeight,
                fps: 12,
                fit: BoxFit.contain,
              )
            : isNetworkImage
            ? CachedNetworkImage(
                imageUrl: imagePath,
                cacheKey: widget.message.mediaId,
                height: imageHeight,
                fit: imageFit,
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                cacheManager: chatImageCacheManager,
              )
            : Image.file(
                File(imagePath),
                height: imageHeight,
                fit: imageFit,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
              ),
      );

      if (!widget.message.isUploading) {
        return imageWidget;
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          imageWidget,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ],
      );
    }

    if (widget.message.messageType.trim().toLowerCase() == 'audio') {
      final hasValidAudioUrl = widget.message.audioUrl != null && widget.message.audioUrl!.isNotEmpty;
      final primaryColor = Theme.of(context).colorScheme.primary;

      final playBtnColor = widget.message.isSentByMe ? Colors.white : primaryColor;
      final playIconColor = widget.message.isSentByMe ? primaryColor : Colors.white;
      final waveformColor = widget.message.isSentByMe ? Colors.white : primaryColor;

      Widget playButton = GestureDetector(
        onTap: hasValidAudioUrl ? () => _togglePlayAudio(widget.message.audioUrl!) : null,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasValidAudioUrl ? playBtnColor : Colors.grey[400],
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: hasValidAudioUrl ? playIconColor : Colors.grey[600],
            size: 26,
          ),
        ),
      );

      Widget waveformAndDuration = Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildWaveform(waveformColor),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!hasValidAudioUrl) ...[
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.message.isSentByMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  _formatAudioDuration(widget.message.audioDurationSeconds),
                  style: TextStyle(
                    color: widget.message.isSentByMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      Widget audioRow = Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.message.isSentByMe
            ? [
                waveformAndDuration,
                const SizedBox(width: 12),
                playButton,
              ]
            : [
                playButton,
                const SizedBox(width: 12),
                waveformAndDuration,
              ],
      );

      return Column(
        crossAxisAlignment: widget.message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          audioRow,
          const SizedBox(height: 8),
          Text(
            AppDateUtils.formatTime(widget.message.timestamp),
            style: TextStyle(
              color: widget.message.isSentByMe ? Colors.white70 : Colors.grey[600],
              fontSize: 10,
            ),
            textAlign: widget.message.isSentByMe ? TextAlign.right : TextAlign.left,
          ),
        ],
      );
    }

    if (widget.message.isResolvingImage) {
      return SizedBox(
        height: 160,
        width: 160,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: widget.message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          widget.message.text ?? '',
          style: TextStyle(
            color: widget.message.isDeleted
                ? (widget.message.isSentByMe ? Colors.white70 : Colors.black45)
                : widget.message.isSentByMe
                ? Colors.white
                : Colors.black,
            fontStyle: widget.message.isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        // Timestamp + status badge only on last message in group
        if (widget.message.isLastInGroup) ...
          [
            const SizedBox(height: 4),
            Text(
              AppDateUtils.formatTime(widget.message.timestamp),
              style: TextStyle(
                color: widget.message.isSentByMe ? Colors.grey[300] : Colors.grey[600],
                fontSize: 10,
              ),
              textAlign: widget.message.isSentByMe ? TextAlign.right : TextAlign.left,
            ),
          ],
      ],
    );
  }

  bool _isSpriteSticker() {
    final stickerId = widget.message.stickerId?.toLowerCase() ?? '';
    final imagePath = widget.message.imagePath?.toLowerCase() ?? '';
    return stickerId.contains('sprite') || imagePath.contains('sprite');
  }
}

  Widget _buildWaveform(Color barColor) {
    final bars = WaveformUtils.normalize(widget.message.audioWaveform, maxBars: 64);

    return SizedBox(
      height: 24, // Fix fixed height constraint
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center, // Center the bars vertically
        children: bars
            .map(
              (value) => Container(
                width: 2,
                height: WaveformUtils.barHeight(value),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  String _formatAudioDuration(int? seconds) {
    if (seconds == null || seconds < 0) {
      return '00:00';
    }

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
