import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _stateSub;
  bool _isPlaying = false;

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
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final hasVisualMedia = switch (message) {
      ImageChatMessage(:final imagePath) => imagePath != null,
      VideoChatMessage(:final thumbnailPath) => thumbnailPath != null,
      StickerChatMessage(:final stickerPath) => stickerPath != null,
      _ => false,
    };

    final senderAvatarUrl = message.senderAvatarUrl?.trim();
    final effectiveAvatarUrl = senderAvatarUrl != null && senderAvatarUrl.isNotEmpty
        ? senderAvatarUrl
        : null;
    final senderDisplayName = message.senderDisplayName?.trim();
    final canShowSenderName = message.isGroupConversation &&
        !message.isSentByMe &&
        message.isFirstInGroup &&
        senderDisplayName != null &&
        senderDisplayName.isNotEmpty;

    final bubble = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: hasVisualMedia ? EdgeInsets.zero : const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
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
        if (widget.showReactAction)
          Positioned(
            right: message.isSentByMe ? null : -6,
            left: message.isSentByMe ? -6 : null,
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
      alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onLongPressStart: widget.onLongPressStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!message.isSentByMe)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: message.isLastInGroup
                    ? CircleAvatar(
                        radius: 16,
                        backgroundImage: effectiveAvatarUrl != null
                            ? CachedNetworkImageProvider(effectiveAvatarUrl)
                            : null,
                        child: effectiveAvatarUrl == null
                            ? const Icon(Icons.person, size: 18)
                            : null,
                      )
                    : const SizedBox(width: 32),
              ),
            Column(
              crossAxisAlignment: message.isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (canShowSenderName)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      senderDisplayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                bubble,
                MessageReactionsBar(
                  reactions: message.reactions,
                  isSentByMe: message.isSentByMe,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final message = widget.message;

    return switch (message) {
      ImageChatMessage(:final imagePath, :final mediaId, :final isUploading, :final isResolvingImage) =>
        _buildImageContent(context, imagePath, mediaId, isUploading, isResolvingImage, false, false),
      StickerChatMessage(:final stickerPath, :final stickerId) =>
        _buildImageContent(context, stickerPath, null, false, false, _isSpriteSticker(stickerPath, stickerId), true),
      VideoChatMessage(:final thumbnailPath, :final mediaId, :final isResolvingImage) =>
        _buildVideoContent(context, thumbnailPath, mediaId, isResolvingImage),
      AudioChatMessage(:final audioUrl, :final durationMs, :final waveform) =>
        _buildAudioContent(context, audioUrl, durationMs, waveform),
      FileChatMessage(:final fileName) => _buildFileContent(fileName),
      TextChatMessage(:final text) => _buildTextContent(text),
      UnknownChatMessage(:final content) => _buildTextContent(content ?? ''),
    };
  }

  Widget _buildImageContent(
    BuildContext context,
    String? imagePath,
    String? mediaId,
    bool isUploading,
    bool isResolvingImage,
    bool isSpriteSticker,
    bool isSticker,
  ) {
    if (imagePath == null) {
      if (!isResolvingImage) return const SizedBox.shrink();
      return const SizedBox(
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
    bool isResolvingImage,
  ) {
    if (thumbnailPath == null) {
      if (!isResolvingImage) return const SizedBox.shrink();
      return const SizedBox(
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

    final uri = Uri.tryParse(thumbnailPath);
    final isNetworkImage = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetworkImage
          ? CachedNetworkImage(
              imageUrl: thumbnailPath,
              cacheKey: mediaId,
              height: 200,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              cacheManager: chatImageCacheManager,
            )
          : Image.file(
              File(thumbnailPath),
              height: 200,
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
          ),
        ),
        const Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
      ],
    );
  }

  Widget _buildAudioContent(
    BuildContext context,
    String? audioUrl,
    int? durationMs,
    List<double>? waveform,
  ) {
    final hasAudio = audioUrl != null && audioUrl.trim().isNotEmpty;
    final bars = WaveformUtils.normalize(waveform ?? const <double>[], maxBars: 48);
    final isMine = widget.message.isSentByMe;
    final primary = Theme.of(context).colorScheme.primary;

    final playBtnColor = isMine ? Colors.white : primary;
    final playIconColor = isMine ? primary : Colors.white;
    final waveformColor = isMine ? Colors.white : primary;

    return Column(
      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: hasAudio ? () => _togglePlayAudio(audioUrl) : null,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasAudio ? playBtnColor : Colors.grey[400],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: hasAudio ? playIconColor : Colors.grey[600],
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              child: bars.isEmpty
                  ? Text(
                      _formatDuration(durationMs),
                      style: TextStyle(
                        color: isMine ? Colors.white70 : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : SizedBox(
                      height: 22,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: bars
                            .map(
                              (value) => Container(
                                width: 2,
                                height: WaveformUtils.barHeight(value).clamp(4, 20).toDouble(),
                                decoration: BoxDecoration(
                                  color: waveformColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _formatDuration(durationMs),
          style: TextStyle(
            color: isMine ? Colors.white70 : Colors.grey[600],
            fontSize: 11,
          ),
          textAlign: isMine ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildFileContent(String? fileName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.file_present, size: 24),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            fileName ?? 'File',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(String text) {
    final message = widget.message;
    return Column(
      crossAxisAlignment: message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: message.isDeleted
                ? (message.isSentByMe ? Colors.white70 : Colors.black45)
                : message.isSentByMe
                    ? Colors.white
                    : Colors.black,
            fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        if (message.isLastInGroup) ...[
          const SizedBox(height: 4),
          Text(
            AppDateUtils.formatTime(message.timestamp),
            style: TextStyle(
              color: message.isSentByMe ? Colors.grey[300] : Colors.grey[600],
              fontSize: 10,
            ),
            textAlign: message.isSentByMe ? TextAlign.right : TextAlign.left,
          ),
        ],
      ],
    );
  }

  Future<void> _togglePlayAudio(String audioUrl) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      final normalized = audioUrl.trim();
      final uri = Uri.tryParse(normalized);
      final isRemote = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      if (isRemote) {
        await _audioPlayer.play(UrlSource(normalized));
      } else {
        await _audioPlayer.play(DeviceFileSource(normalized));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  bool _isSpriteSticker(String? imagePath, String? stickerId) {
    final image = imagePath?.toLowerCase() ?? '';
    final id = stickerId?.toLowerCase() ?? '';
    return image.contains('sprite') || id.contains('sprite');
  }

  String _formatDuration(int? durationMs) {
    if (durationMs == null || durationMs < 0) return '00:00';
    final totalSeconds = durationMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
