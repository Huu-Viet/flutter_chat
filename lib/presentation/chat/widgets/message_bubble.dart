// filepath: d:\KIENTRUCPM\flutter_chat\lib\presentation\chat\widgets\message_bubble.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat/core/utils/animated_sticker_sprite.dart';
import 'package:flutter_chat/core/utils/date_utils.dart';
import 'package:flutter_chat/core/utils/waveform_utils.dart';
import 'package:flutter_chat/presentation/chat/chat_image_cache_manager.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_reactions_bar.dart';

<<<<<<< feature/integrate-emoji
import '../models/chat_message.dart';

class MessageBubble extends StatefulWidget {
=======
class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color color;

  WaveformPainter({
    required this.waveform,
    this.color = Colors.white70,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveform.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final centerY = height / 2;
    final barWidth = width / waveform.length;

    for (int i = 0; i < waveform.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final normalizedValue = (waveform[i] * 100).clamp(0, 100) / 100;
      final barHeight = (height / 2) * normalizedValue;

      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveform != waveform || oldDelegate.color != color;
  }
}

class MessageBubble extends StatelessWidget {
>>>>>>> main
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
<<<<<<< feature/integrate-emoji
    final hasVisualMedia = widget.message.imagePath != null;
    final isAudio = widget.message.type.trim().toLowerCase() == 'audio';

=======
    final hasVisualMedia = switch (message) {
      ImageChatMessage(:final imagePath) => imagePath != null,
      VideoChatMessage(:final thumbnailPath) => thumbnailPath != null,
      StickerChatMessage(:final stickerPath) => stickerPath != null,
      _ => false,
    };
    
    final senderAvatarUrl = message.senderAvatarUrl?.trim();
    final effectiveAvatarUrl =
      senderAvatarUrl != null && senderAvatarUrl.isNotEmpty ? senderAvatarUrl : null;
    final senderDisplayName = message.senderDisplayName?.trim();
    final canShowSenderName =
      message.isGroupConversation &&
      !message.isSentByMe &&
      message.isFirstInGroup &&
      senderDisplayName != null &&
      senderDisplayName.isNotEmpty;
>>>>>>> main
    final bubble = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: hasVisualMedia ? EdgeInsets.zero : const EdgeInsets.all(12),
          width: isAudio ? MediaQuery.of(context).size.width * 0.7 : null,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: hasVisualMedia
                ? Colors.transparent
                : widget.message.isSentByMe
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(hasVisualMedia ? 8 : 16),
          ),
          child: _buildMessageContent(context),
        ),
        if (widget.showReactAction)
          Positioned(
            right: widget.message.isSentByMe ? null : -6,
            left: widget.message.isSentByMe ? -6 : null,
            bottom: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onReactPressed,
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
      alignment: widget.message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onLongPressStart: widget.onLongPressStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
          widget.message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!widget.message.isSentByMe)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: widget.message.isLastInGroup
                    ? CircleAvatar(
<<<<<<< feature/integrate-emoji
                  radius: 16,
                  backgroundImage: widget.message.conversationAvatarUrl != null &&
                      widget.message.conversationAvatarUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(widget.message.conversationAvatarUrl!)
                      : null,
                  child: widget.message.conversationAvatarUrl == null ||
                      widget.message.conversationAvatarUrl!.isEmpty
                      ? const Icon(Icons.person, size: 18)
                      : null,
                )
=======
                        radius: 16,
                  backgroundImage: effectiveAvatarUrl != null
                    ? CachedNetworkImageProvider(effectiveAvatarUrl)
                            : null,
                  child: effectiveAvatarUrl == null
                            ? const Icon(Icons.person, size: 18)
                            : null,
                      )
>>>>>>> main
                    : const SizedBox(width: 32),
              ),
            Column(
              crossAxisAlignment: widget.message.isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (canShowSenderName)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      senderDisplayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                bubble,
                MessageReactionsBar(
                  reactions: widget.message.reactions,
                  isSentByMe: widget.message.isSentByMe,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
<<<<<<< feature/integrate-emoji
    if (widget.message.imagePath != null) {
      final imagePath = widget.message.imagePath!;
      final isStickerMessage = widget.message.type.trim().toLowerCase() == 'sticker';
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
=======
    debugPrint('[MessageBubble] message type: ${message.runtimeType}, content: ${message.toString()}');
    return switch (message) {
      ImageChatMessage(:final imagePath, :final mediaId, :final isUploading, :final isResolvingImage) =>
        _buildImageContent(context, imagePath, mediaId, isUploading, isResolvingImage, false),
      VideoChatMessage(:final thumbnailPath, :final mediaId, :final durationMs, :final isUploading, :final isResolvingImage) =>
        _buildVideoContent(context, thumbnailPath, mediaId, durationMs, isUploading, isResolvingImage),
      StickerChatMessage(:final stickerPath) =>
        _buildStickerContent(context, stickerPath),
      AudioChatMessage(:final durationMs, :final waveform) =>
        _buildAudioContent(context, durationMs, waveform),
      FileChatMessage(:final fileName) =>
        _buildFileContent(context, fileName),
      TextChatMessage(:final text) =>
        _buildTextContent(context, text),
      _ => _buildTextContent(context, ''),
    };
  }

  Widget _buildImageContent(
    BuildContext context,
    String? imagePath,
    String? mediaId,
    bool isUploading,
    bool isResolvingImage,
    bool isSticker,
  ) {
    if (imagePath == null) {
      if (isResolvingImage) {
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
>>>>>>> main
      }
      return const SizedBox.shrink();
    }

    final isSpriteSticker = isSticker && _isSpriteSticker(imagePath);
    final uri = Uri.tryParse(imagePath);
    final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    final imageHeight = isSticker ? 120.0 : 200.0;
    final imageFit = isSticker ? BoxFit.contain : BoxFit.cover;

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
              cacheKey: mediaId,
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

    if (!isUploading) {
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

  Widget _buildVideoContent(
    BuildContext context,
    String? thumbnailPath,
    String? mediaId,
    int? durationMs,
    bool isUploading,
    bool isResolvingImage,
  ) {
    if (thumbnailPath == null) {
      if (isResolvingImage) {
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
      return const SizedBox.shrink();
    }

<<<<<<< feature/integrate-emoji
    if (widget.message.type.trim().toLowerCase() == 'audio') {
      final hasValidAudioUrl =
          widget.message.audioUrl != null && widget.message.audioUrl!.isNotEmpty;
      final primaryColor = Theme.of(context).colorScheme.primary;

      final playBtnColor = widget.message.isSentByMe ? Colors.white : primaryColor;
      final playIconColor = widget.message.isSentByMe ? primaryColor : Colors.white;
      final waveformColor = widget.message.isSentByMe ? Colors.white : primaryColor;

      final playButton = GestureDetector(
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

      final waveformAndDuration = Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          widget.message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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

      final audioRow = Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widget.message.isSentByMe
            ? [waveformAndDuration, const SizedBox(width: 12), playButton]
            : [playButton, const SizedBox(width: 12), waveformAndDuration],
      );

      return Column(
        crossAxisAlignment:
        widget.message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
      return const SizedBox(
        height: 160,
        width: 160,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.2),
=======
    final uri = Uri.tryParse(thumbnailPath);
    final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetworkImage
          ? CachedNetworkImage(
              imageUrl: thumbnailPath,
              cacheKey: mediaId,
              height: 200.0,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              cacheManager: chatImageCacheManager,
            )
          : Image.file(
              File(thumbnailPath),
              height: 200.0,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
            ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        imageWidget,
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
>>>>>>> main
          ),
        ),
        const Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
      ],
    );
  }

  Widget _buildStickerContent(BuildContext context, String? stickerPath) {
    if (stickerPath == null) return const SizedBox.shrink();
    return _buildImageContent(context, stickerPath, null, false, false, true);
  }

  Widget _buildAudioContent(BuildContext context, int? durationMs, List<double>? waveform) {
    final durationSeconds = (durationMs ?? 0) ~/ 1000;
    final durationText = '$durationSeconds s';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_filled, size: 32),
          const SizedBox(width: 8),
          if (waveform != null && waveform.isNotEmpty)
            SizedBox(
              width: 100,
              height: 30,
              child: CustomPaint(
                painter: WaveformPainter(waveform: waveform),
              ),
            )
          else
            Text(durationText),
        ],
      ),
    );
  }

  Widget _buildFileContent(BuildContext context, String? fileName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.file_present, size: 32),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName ?? 'File',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, String text) {
    return Column(
      crossAxisAlignment: widget.message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
<<<<<<< feature/integrate-emoji
          widget.message.text ?? '',
=======
          text,
>>>>>>> main
          style: TextStyle(
            color: widget.message.isDeleted
                ? (widget.message.isSentByMe ? Colors.white70 : Colors.black45)
                : widget.message.isSentByMe
                ? Colors.white
                : Colors.black,
            fontStyle: widget.message.isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        if (widget.message.isLastInGroup) ...[
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

<<<<<<< feature/integrate-emoji
  Widget _buildWaveform(Color barColor) {
    final bars = WaveformUtils.normalize(widget.message.audioWaveform, maxBars: 64);

    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
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

  bool _isSpriteSticker() {
    final stickerId = widget.message.stickerId?.toLowerCase() ?? '';
    final imagePath = widget.message.imagePath?.toLowerCase() ?? '';
    return stickerId.contains('sprite') || imagePath.contains('sprite');
=======
  bool _isSpriteSticker(String imagePath) {
    final lowerPath = imagePath.toLowerCase();
    return lowerPath.contains('sprite');
>>>>>>> main
  }
}
