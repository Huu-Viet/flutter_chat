import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/features/upload_media/upload_media_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageViewerPage extends ConsumerStatefulWidget {
  final List<String> previewImagePaths;
  final List<String> mediaIds;
  final int initialIndex;
  final String? conversationId;

  const ImageViewerPage({
    super.key,
    required this.previewImagePaths,
    required this.mediaIds,
    required this.initialIndex,
    this.conversationId,
  });

  @override
  ConsumerState<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;
  final Map<int, String> _originalUrlsByIndex = <int, String>{};
  final Set<int> _loadingIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.previewImagePaths.length - 1,
    );
    _pageController = PageController(initialPage: _currentIndex);
    _fetchOriginalForIndex(_currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchOriginalForIndex(int index) async {
    if (_loadingIndexes.contains(index) ||
        _originalUrlsByIndex.containsKey(index)) {
      return;
    }

    final mediaId = _mediaIdAt(index);
    if (mediaId == null || mediaId.isEmpty) {
      return;
    }

    _loadingIndexes.add(index);
    if (mounted) {
      setState(() {});
    }

    final result = await ref.read(getMediaUrlByMediaIdUseCaseProvider)(
      mediaId,
      prefer: 'ORIGINAL',
      conversationId: widget.conversationId,
    );

    result.fold((_) {}, (url) {
      if (url.trim().isNotEmpty) {
        _originalUrlsByIndex[index] = url.trim();
      }
    });

    _loadingIndexes.remove(index);
    if (mounted) {
      setState(() {});
    }
  }

  String? _mediaIdAt(int index) {
    if (index < 0 || index >= widget.mediaIds.length) {
      return null;
    }

    final mediaId = widget.mediaIds[index].trim();
    return mediaId.isEmpty ? null : mediaId;
  }

  bool _isNetworkPath(String path) {
    final uri = Uri.tryParse(path);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.previewImagePaths.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            _fetchOriginalForIndex(index);
          },
          itemBuilder: (context, index) {
            final previewPath = widget.previewImagePaths[index];
            final displayPath = _originalUrlsByIndex[index] ?? previewPath;
            final isLoadingOriginal = _loadingIndexes.contains(index);
      
            return Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: _isNetworkPath(displayPath)
                          ? CachedNetworkImage(
                              imageUrl: displayPath,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                color: Colors.white70,
                                size: 48,
                              ),
                            )
                          : Image.file(
                              File(displayPath),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.white70,
                                    size: 48,
                                  ),
                            ),
                    ),
                  ),
                ),
                if (isLoadingOriginal)
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${index + 1}/${widget.previewImagePaths.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
