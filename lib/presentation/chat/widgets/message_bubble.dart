import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_chat/core/utils/animated_sticker_sprite.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friendship_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_chat/core/utils/date_utils.dart';
import 'package:flutter_chat/core/utils/waveform_utils.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/forward_info.dart';
import 'package:flutter_chat/presentation/chat/chat_image_cache_manager.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_reactions_bar.dart';
import 'package:video_player/video_player.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;
  final ValueChanged<LongPressStartDetails>? onLongPressStart;
  final VoidCallback? onReactPressed;
  final VoidCallback? onOpenFile;
  final ValueChanged<String>? onReplyPreviewTap;
  final bool showReactAction;

  const MessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
    this.onLongPressStart,
    this.onReactPressed,
    this.showReactAction = false,
    this.onOpenFile,
    this.onReplyPreviewTap,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _stateSub;
  bool _isPlaying = false;
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  bool _isVideoInitializing = false;

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
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldVideo = oldWidget.message is VideoChatMessage
        ? oldWidget.message as VideoChatMessage
        : null;
    final newVideo = widget.message is VideoChatMessage
        ? widget.message as VideoChatMessage
        : null;

    final oldKey = '${oldVideo?.mediaId ?? ''}|${oldVideo?.videoUrl ?? ''}';
    final newKey = '${newVideo?.mediaId ?? ''}|${newVideo?.videoUrl ?? ''}';
    if (oldKey != newKey) {
      _disposeVideoController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    if (message is SystemChatMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              message.text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    final hasVisualMedia = switch (message) {
      ImageChatMessage(:final imagePath) => imagePath != null,
      VideoChatMessage(:final thumbnailPath, :final videoUrl) =>
        thumbnailPath != null ||
            (videoUrl != null && videoUrl.trim().isNotEmpty),
      StickerChatMessage(:final stickerPath) => stickerPath != null,
      ContactCardChatMessage() => true,
      _ => false,
    };

    final senderAvatarUrl = message.senderAvatarUrl?.trim();
    final effectiveAvatarUrl =
        senderAvatarUrl != null && senderAvatarUrl.isNotEmpty
        ? senderAvatarUrl
        : null;
    final senderDisplayName = message.senderDisplayName?.trim();
    final canShowSenderName =
        message.isGroupConversation &&
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
          child: _buildMessageContent(context, widget.onOpenFile),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceBright.withAlpha(20),
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
      alignment: message.isSentByMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onLongPressStart: widget.onLongPressStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: message.isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.75),
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

  Widget _buildMessageContent(BuildContext context, VoidCallback? onOpenFile) {
    final message = widget.message;

    return switch (message) {
      ImageChatMessage(
        :final imagePath,
        :final mediaId,
        :final isUploading,
        :final isResolvingImage,
        :final forwardInfo,
      ) =>
        _buildImageContent(
          context,
          imagePath,
          mediaId,
          isUploading,
          isResolvingImage,
          false,
          false,
          forwardInfo,
        ),

      StickerChatMessage(:final stickerPath, :final stickerId) =>
        _buildImageContent(
          context,
          stickerPath,
          null,
          false,
          false,
          _isSpriteSticker(stickerPath, stickerId),
          true,
          message.forwardInfo,
        ),

      VideoChatMessage(
        :final thumbnailPath,
        :final videoUrl,
        :final mediaId,
        :final durationMs,
        :final isResolvingImage,
        :final isResolvingVideo,
        :final forwardInfo,
      ) =>
        _buildVideoContent(
          context,
          thumbnailPath,
          videoUrl,
          mediaId,
          durationMs,
          isResolvingImage,
          isResolvingVideo,
          forwardInfo,
        ),

      AudioChatMessage(
        :final audioUrl,
        :final durationMs,
        :final waveform,
        :final forwardInfo,
      ) =>
        _buildAudioContent(
          context,
          audioUrl,
          durationMs,
          waveform,
          forwardInfo,
        ),

      FileChatMessage(:final isDownloading, :final forwardInfo) =>
        _buildFileContent(
          forwardInfo,
          message,
          isDownloading: isDownloading,
          onOpen: onOpenFile ?? () {},
        ),

      ContactCardChatMessage() => _ContactCardBubble(message: message),

      SystemChatMessage() => const SizedBox.shrink(),

      TextChatMessage(:final text, :final forwardInfo, :final replyPreview) =>
        _buildTextContent(text, forwardInfo, replyPreview: replyPreview),
      UnknownChatMessage(:final content, :final forwardInfo) =>
        _buildTextContent(content ?? '', forwardInfo),
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
    ForwardInfo? forwardInfo,
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
    final isNetworkImage =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
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
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
              cacheManager: chatImageCacheManager,
            )
          : Image.file(
              File(imagePath),
              height: imageHeight,
              fit: imageFit,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
    );

    Widget content;

    if (!isUploading) {
      content = imageWidget;
    } else {
      content = Stack(
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

    if (forwardInfo == null) return content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildForwardInfo(context, forwardInfo),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildVideoContent(
    BuildContext context,
    String? thumbnailPath,
    String? videoUrl,
    String? mediaId,
    int? durationMs,
    bool isResolvingImage,
    bool isResolvingVideo,
    ForwardInfo? forwardInfo,
  ) {
    final hasVideo = videoUrl != null && videoUrl.trim().isNotEmpty;

    if (_isVideoReady && _videoController != null) {
      final controller = _videoController!;
      final isPlaying = controller.value.isPlaying;
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio > 0
                  ? controller.value.aspectRatio
                  : 16 / 9,
              child: VideoPlayer(controller),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleVideoPlayback,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isPlaying ? 0.0 : 1.0,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.22),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatDuration(durationMs),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (thumbnailPath == null) {
      if (hasVideo) {
        return GestureDetector(
          onTap: () => _initializeAndPlayVideo(videoUrl),
          child: Container(
            height: 200,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isVideoInitializing)
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                else
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 52,
                  ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatDuration(durationMs),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (!(isResolvingImage || isResolvingVideo || _isVideoInitializing)) {
        return const SizedBox.shrink();
      }
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
    final isNetworkImage =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetworkImage
          ? CachedNetworkImage(
              imageUrl: thumbnailPath,
              cacheKey: mediaId,
              height: 200,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
              cacheManager: chatImageCacheManager,
            )
          : Image.file(
              File(thumbnailPath),
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
    );

    Widget content;

    content = GestureDetector(
      onTap: hasVideo ? () => _initializeAndPlayVideo(videoUrl) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          imageWidget,
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (_isVideoInitializing)
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          else
            Icon(
              hasVideo
                  ? Icons.play_circle_filled
                  : Icons.hourglass_empty_rounded,
              color: Colors.white,
              size: 48,
            ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formatDuration(durationMs),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (forwardInfo == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildForwardInfo(context, forwardInfo),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildAudioContent(
    BuildContext context,
    String? audioUrl,
    int? durationMs,
    List<double>? waveform,
    ForwardInfo? forwardInfo,
  ) {
    final hasAudio = audioUrl != null && audioUrl.trim().isNotEmpty;
    final bars = WaveformUtils.normalize(
      waveform ?? const <double>[],
      maxBars: 48,
    );
    final isMine = widget.message.isSentByMe;
    final primary = Theme.of(context).colorScheme.primary;

    final playBtnColor = isMine ? Colors.white : primary;
    final playIconColor = isMine ? primary : Colors.white;
    final waveformColor = isMine ? Colors.white : primary;

    Widget content;

    content = Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
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
                                height: WaveformUtils.barHeight(
                                  value,
                                ).clamp(4, 20).toDouble(),
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

    if (forwardInfo == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildForwardInfo(context, forwardInfo),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildFileContent(
    ForwardInfo? forwardInfo,
    FileChatMessage fileMessage, {
    required bool isDownloading,
    required VoidCallback onOpen,
  }) {
    final fileName = fileMessage.fileName?.trim() ?? 'File';
    final fileSize = fileMessage.fileSize;

    Widget content;
    content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getFileIcon(fileMessage.fileName), size: 20),
        ),

        const SizedBox(width: 8),

        /// Name + size
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (fileSize != null)
                Text(
                  _formatSize(fileSize),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        /// Action
        isDownloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: onOpen,
              ),
      ],
    );

    if (forwardInfo == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildForwardInfo(context, forwardInfo),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildTextContent(
    String text,
    ForwardInfo? forwardInfo, {
    ReplyPreview? replyPreview,
  }) {
    final message = widget.message;
    final baseTextStyle = TextStyle(
      color: message.isDeleted
          ? (message.isSentByMe ? Colors.white70 : Colors.black45)
          : message.isSentByMe
          ? Colors.white
          : Colors.black,
      fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
    );
    final mentionTextStyle = baseTextStyle.copyWith(
      color: message.isSentByMe ? Colors.yellow[200] : Colors.blue[700],
      fontWeight: FontWeight.w700,
      fontStyle: baseTextStyle.fontStyle,
    );

    Widget content;
    content = Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (replyPreview != null) ...[
          _buildReplyPreview(replyPreview),
          const SizedBox(height: 6),
        ],
        message.isDeleted
            ? Text(text, style: baseTextStyle)
            : RichText(
                text: TextSpan(
                  style: baseTextStyle,
                  children: _buildRichTextSpans(
                    text,
                    baseStyle: baseTextStyle,
                    mentionStyle: mentionTextStyle,
                  ),
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

    if (forwardInfo == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildForwardInfo(context, forwardInfo),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildReplyPreview(ReplyPreview preview) {
    final isMine = widget.message.isSentByMe;
    return GestureDetector(
      onTap:
          widget.onReplyPreviewTap == null || preview.messageId.trim().isEmpty
          ? null
          : () => widget.onReplyPreviewTap!(preview.messageId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isMine ? Colors.white24 : Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preview.senderDisplay,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isMine ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              preview.snippet,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isMine ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _buildRichTextSpans(
    String text, {
    required TextStyle baseStyle,
    required TextStyle mentionStyle,
  }) {
    final spans = <InlineSpan>[];
    // Regex for detecting mentions and URLs
    final mentionRegex = RegExp(r'(@all|@[A-Za-z0-9._-]+)');
    final urlRegex = RegExp(
      r'https?://[^\s]+|www\.[^\s]+|(?:^|\s)([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\.)+[a-zA-Z]{2,}(?:\s|$)',
      multiLine: true,
    );

    var lastIndex = 0;
    final List<({int start, int end, String text, String type})> tokens = [];

    // Collect all mentions and URLs with their positions
    for (final match in mentionRegex.allMatches(text)) {
      tokens.add((
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        type: 'mention',
      ));
    }
    for (final match in urlRegex.allMatches(text)) {
      tokens.add((
        start: match.start,
        end: match.end,
        text: match.group(0)!.trim(),
        type: 'url',
      ));
    }

    // Sort tokens by start position
    tokens.sort((a, b) => a.start.compareTo(b.start));

    // Filter overlapping tokens (keep mentions over URLs if they overlap)
    final List<({int start, int end, String text, String type})> filtered = [];
    for (final token in tokens) {
      bool overlaps = false;
      for (final existing in filtered) {
        if ((token.start >= existing.start && token.start < existing.end) ||
            (token.end > existing.start && token.end <= existing.end) ||
            (token.start <= existing.start && token.end >= existing.end)) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) {
        filtered.add(token);
      }
    }
    filtered.sort((a, b) => a.start.compareTo(b.start));

    // Build spans from tokens
    lastIndex = 0;
    for (final token in filtered) {
      if (token.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, token.start),
            style: baseStyle,
          ),
        );
      }

      if (token.type == 'mention') {
        spans.add(TextSpan(text: token.text, style: mentionStyle));
      } else if (token.type == 'url') {
        final linkColor = widget.message.isSentByMe
            ? Colors.white
            : Colors.blue.shade700;
        final linkStyle = baseStyle.copyWith(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        );
        final urlText = token.text;
        spans.add(
          TextSpan(
            text: urlText,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _launchUrl(urlText),
          ),
        );
      }
      lastIndex = token.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }

    return spans;
  }

  Future<void> _launchUrl(String urlText) async {
    var urlStr = urlText.trim();
    if (!urlStr.startsWith('http://') && !urlStr.startsWith('https://')) {
      urlStr = 'https://$urlStr';
    }

    final uri = Uri.tryParse(urlStr);
    if (uri == null) {
      debugPrint('[MessageBubble] Invalid URL: $urlText');
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[MessageBubble] Error launching URL: $e');
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (e2) {
        debugPrint('[MessageBubble] Fallback browser also failed: $e2');
      }
    }
  }

  Widget _buildForwardInfo(BuildContext context, ForwardInfo info) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.forward,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Forwarded from ${info.senderId}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String? mime) {
    if (mime == null) return Icons.insert_drive_file;

    if (mime.contains('pdf')) return Icons.picture_as_pdf;
    if (mime.contains('word')) return Icons.description;
    if (mime.contains('sheet') || mime.contains('excel')) {
      return Icons.table_chart;
    }
    if (mime.contains('zip') || mime.contains('rar')) {
      return Icons.archive;
    }
    if (mime.startsWith('text/')) return Icons.text_snippet;

    return Icons.insert_drive_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  Future<void> _togglePlayAudio(String audioUrl) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      final normalized = audioUrl.trim();
      final uri = Uri.tryParse(normalized);
      final isRemote =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      if (isRemote) {
        await _audioPlayer.play(UrlSource(normalized));
      } else {
        await _audioPlayer.play(DeviceFileSource(normalized));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _initializeAndPlayVideo(String? videoUrl) async {
    final normalized = videoUrl?.trim();
    if (normalized == null || normalized.isEmpty || _isVideoInitializing) {
      return;
    }

    if (_videoController != null && _isVideoReady) {
      await _toggleVideoPlayback();
      return;
    }

    setState(() {
      _isVideoInitializing = true;
    });

    try {
      _disposeVideoController();
      final uri = Uri.tryParse(normalized);
      final isRemote =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      final controller = isRemote
          ? VideoPlayerController.networkUrl(Uri.parse(normalized))
          : VideoPlayerController.file(File(normalized));

      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _isVideoReady = true;
        _isVideoInitializing = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isVideoInitializing = false;
        _isVideoReady = false;
      });
    }
  }

  Future<void> _toggleVideoPlayback() async {
    final controller = _videoController;
    if (controller == null || !_isVideoReady) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _disposeVideoController() {
    final previous = _videoController;
    _videoController = null;
    _isVideoReady = false;
    if (previous != null) {
      unawaited(previous.dispose());
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

class _ContactCardBubble extends ConsumerWidget {
  final ContactCardChatMessage message;

  const _ContactCardBubble({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(message.contactUserId));
    final statusAsync = ref.watch(
      friendshipStatusProvider(message.contactUserId),
    );

    // Don't show action buttons if this is our own card
    final isSelf =
        message.isSentByMe &&
        (statusAsync.valueOrNull?.userId == message.contactUserId);

    Widget content = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: message.isSentByMe
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[400],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          userAsync.when(
            loading: () => _buildCardRow(context, null, isLoading: true),
            error: (_, __) => _buildCardRow(context, null),
            data: (user) => _buildCardRow(context, user),
          ),
          if (!isSelf) ...[
            const SizedBox(height: 10),
            _buildActionRow(context, ref, statusAsync),
          ],
        ],
      ),
    );

    final forwardInfo = message.forwardInfo;
    if (forwardInfo == null) return content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildForwardInfoBanner(context, forwardInfo),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<FriendshipStatus?> statusAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _onMessageTap(context),
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Message'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.6),
              ),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: statusAsync.when(
            loading: () => OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
              child: const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (status) => _buildFriendshipButton(context, ref, status),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendshipButton(
    BuildContext context,
    WidgetRef ref,
    FriendshipStatus? status,
  ) {
    final targetId = message.contactUserId;

    if (status == null || status.isNone) {
      return OutlinedButton.icon(
        onPressed: () => _sendRequest(context, ref, targetId),
        icon: const Icon(Icons.person_add_outlined, size: 16),
        label: const Text('Add friend'),
        style: _friendBtnStyle(context),
      );
    }

    if (status.isPendingOut) {
      return OutlinedButton.icon(
        onPressed: () => _cancelRequest(context, ref, targetId),
        icon: const Icon(Icons.cancel_outlined, size: 16),
        label: const Text('Pending...'),
        style: _friendBtnStyle(context),
      );
    }

    if (status.isPendingIn) {
      return OutlinedButton.icon(
        onPressed: () => _acceptRequest(context, ref, targetId),
        icon: const Icon(Icons.check_circle_outline, size: 16),
        label: const Text('Accept'),
        style: _friendBtnStyle(context),
      );
    }

    if (status.isFriend) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.people_outline, size: 16),
        label: const Text('Friends'),
        style: _friendBtnStyle(context),
      );
    }

    if (status.isBlocked) {
      return OutlinedButton.icon(
        onPressed: () => _unblock(context, ref, targetId),
        icon: const Icon(Icons.block_outlined, size: 16),
        label: const Text('Unblock'),
        style: _friendBtnStyle(context),
      );
    }

    return const SizedBox.shrink();
  }

  ButtonStyle _friendBtnStyle(BuildContext context) => OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 4),
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    side: BorderSide(
      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6),
    ),
    textStyle: const TextStyle(fontSize: 13),
  );

  void _onMessageTap(BuildContext context) {
    // Navigate to home — user can find or start a conversation from there.
    context.go('/');
  }

  Future<void> _sendRequest(
    BuildContext context,
    WidgetRef ref,
    String targetId,
  ) async {
    await ref.read(sendFriendRequestUseCaseProvider)(targetId);
    ref.invalidate(friendshipStatusProvider(targetId));
  }

  Future<void> _cancelRequest(
    BuildContext context,
    WidgetRef ref,
    String targetId,
  ) async {
    await ref.read(rejectFriendRequestUseCaseProvider)(targetId);
    ref.invalidate(friendshipStatusProvider(targetId));
  }

  Future<void> _acceptRequest(
    BuildContext context,
    WidgetRef ref,
    String targetId,
  ) async {
    await ref.read(acceptFriendRequestUseCaseProvider)(targetId);
    ref.invalidate(friendshipStatusProvider(targetId));
  }

  Future<void> _unblock(
    BuildContext context,
    WidgetRef ref,
    String targetId,
  ) async {
    await ref.read(unblockUserUseCaseProvider)(targetId);
    ref.invalidate(friendshipStatusProvider(targetId));
  }

  Widget _buildCardRow(
    BuildContext context,
    MyUser? user, {
    bool isLoading = false,
  }) {
    final displayName = _displayName(user);
    final subText = user?.email ?? user?.phone ?? message.contactUserId;
    final avatarUrl = user?.avatarUrl;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(avatarUrl, isLoading: isLoading),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLoading ? '...' : displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isLoading) ...[
                const SizedBox(height: 2),
                Text(
                  subText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? avatarUrl, {bool isLoading = false}) {
    if (isLoading) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.blueGrey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, __) => _defaultAvatarIcon(),
          errorWidget: (_, __, ___) => _defaultAvatarIcon(),
        ),
      );
    }

    return _defaultAvatarIcon();
  }

  Widget _defaultAvatarIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.person_outline, size: 24, color: Colors.blueGrey),
    );
  }

  String _displayName(MyUser? user) {
    if (user == null) return message.contactUserId;
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    if (user.username.trim().isNotEmpty) return user.username.trim();
    return user.email;
  }

  Widget _buildForwardInfoBanner(BuildContext context, forwardInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.forward,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            'Forwarded',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
