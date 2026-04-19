import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum StickerPlayDirection { leftToRight, rightToLeft }

/// Render animated sticker from a horizontal sprite sheet:
/// one image that contains [frameCount] frames in a single row.
class AnimatedStickerSprite extends StatefulWidget {
  const AnimatedStickerSprite({
    super.key,
    required this.imageProvider,
    this.frameCount,
    this.width = 120,
    this.height = 120,
    this.fps = 12,
    this.direction = StickerPlayDirection.leftToRight,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.medium,
  }) : assert(fps > 0);

  final ImageProvider imageProvider;
  final int? frameCount;
  final double width;
  final double height;
  final int fps;
  final StickerPlayDirection direction;
  final bool repeat;
  final BoxFit fit;
  final FilterQuality filterQuality;

  @override
  State<AnimatedStickerSprite> createState() => _AnimatedStickerSpriteState();
}

class _AnimatedStickerSpriteState extends State<AnimatedStickerSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ImageInfo? _imageInfo;
  int _effectiveFrameCount = 1;

  Duration get _duration => Duration(
    milliseconds: (1000 / widget.fps * _effectiveFrameCount).round(),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _startController();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant AnimatedStickerSprite oldWidget) {
    super.didUpdateWidget(oldWidget);

    final needResetController = oldWidget.fps != widget.fps ||
        oldWidget.frameCount != widget.frameCount ||
        oldWidget.repeat != widget.repeat;

    if (needResetController) {
      _controller.duration = _duration;
      _startController(reset: true);
    }

    if (oldWidget.imageProvider != widget.imageProvider) {
      _resolveImage();
    }
  }

  void _startController({bool reset = false}) {
    if (reset) {
      _controller.reset();
    }
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward(from: 0);
    }
  }

  int _detectFrameCount(ui.Image image) {
    if (widget.frameCount != null && widget.frameCount! > 0) {
      return widget.frameCount!;
    }

    final h = image.height;
    if (h <= 0) return 1;
    final estimated = (image.width / h).round();
    return estimated.clamp(1, 200);
  }

  void _resolveImage() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    final stream = widget.imageProvider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!mounted) return;
      setState(() {
        _imageInfo = info;
        _effectiveFrameCount = _detectFrameCount(info.image);
        _controller.duration = _duration;
        _startController(reset: true);
      });
    });
    stream.addListener(_listener!);
    _stream = stream;
  }

  @override
  void dispose() {
    if (_listener != null) {
      _stream?.removeListener(_listener!);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final frameIndex = _currentFrame();
          return CustomPaint(
            painter: _StickerSpritePainter(
              image: _imageInfo!.image,
              frameCount: _effectiveFrameCount,
              frameIndex: frameIndex,
              fit: widget.fit,
              filterQuality: widget.filterQuality,
            ),
          );
        },
      ),
    );
  }

  int _currentFrame() {
    final progress = _controller.value.clamp(0.0, 0.999999);
    final forwardIndex = (progress * _effectiveFrameCount).floor();

    if (widget.direction == StickerPlayDirection.leftToRight) {
      return forwardIndex;
    }
    return (_effectiveFrameCount - 1) - forwardIndex;
  }
}

class _StickerSpritePainter extends CustomPainter {
  const _StickerSpritePainter({
    required this.image,
    required this.frameCount,
    required this.frameIndex,
    required this.fit,
    required this.filterQuality,
  });

  final ui.Image image;
  final int frameCount;
  final int frameIndex;
  final BoxFit fit;
  final FilterQuality filterQuality;

  @override
  void paint(Canvas canvas, Size size) {
    final srcFrameWidth = image.width / frameCount;
    final srcFrameHeight = image.height.toDouble();

    final srcRect = Rect.fromLTWH(
      srcFrameWidth * frameIndex,
      0,
      srcFrameWidth,
      srcFrameHeight,
    );

    final inputSize = Size(srcRect.width, srcRect.height);
    final fitted = applyBoxFit(fit, inputSize, size);
    final dstRect = Alignment.center.inscribe(fitted.destination, Offset.zero & size);

    final paint = Paint()..filterQuality = filterQuality;
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(covariant _StickerSpritePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.frameCount != frameCount ||
        oldDelegate.frameIndex != frameIndex ||
        oldDelegate.fit != fit ||
        oldDelegate.filterQuality != filterQuality;
  }
}