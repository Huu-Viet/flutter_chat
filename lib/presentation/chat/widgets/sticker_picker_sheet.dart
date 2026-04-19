import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/animated_sticker_sprite.dart';
import '../../../features/chat/domain/entities/sticker_item.dart';
import '../../../features/chat/domain/entities/sticker_package.dart';

class StickerPickerSheet extends ConsumerStatefulWidget {
  const StickerPickerSheet({
    super.key,
    required this.onStickerTap,
  });

  final ValueChanged<StickerItem> onStickerTap;

  @override
  ConsumerState<StickerPickerSheet> createState() => _StickerPickerSheetState();
}

class _StickerPickerSheetState extends ConsumerState<StickerPickerSheet> {
  bool _loadingPackages = true;
  String? _packagesError;
  List<StickerPackage> _packages = [];
  int _selectedPackageIndex = 0;

  bool _loadingStickers = false;
  String? _stickersError;
  List<StickerItem> _stickers = [];

  // Recent stickers (session-level)
  final List<StickerItem> _recent = [];

  // Cache a package cover from its first loaded sticker when thumbnail is missing.
  final Map<String, StickerItem> _packageCoverById = {};

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _loadingPackages = true;
      _packagesError = null;
    });

    try {
      final getPackages = ref.read(getStickerPackagesUseCaseProvider);
      final result = await getPackages();

      result.fold(
        (l) => throw Exception(l.message),
        (r) {
          setState(() {
            _packages = r;
          });
        },
      );

      setState(() {
        _loadingPackages = false;
      });

      if (_packages.isNotEmpty) {
        await _loadStickers(_packages.first.id);

        // Fetch covers for other packages in background
        for (var i = 1; i < _packages.length; i++) {
          final p = _packages[i];
          if (_normalizeUrl(p.thumbnailUrl).isEmpty) {
            _loadStickers(p.id, isBackground: true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingPackages = false;
          _packagesError = e.toString();
        });
      }
    }
  }

  // Cache stickers for each package id
  final Map<String, List<StickerItem>> _stickersCache = {};

  Future<void> _loadStickers(String packageId, {bool isBackground = false}) async {
    if (_stickersCache.containsKey(packageId)) {
      if (!isBackground && mounted) {
        setState(() {
          _stickers = _stickersCache[packageId]!;
          _stickersError = null;
          _loadingStickers = false;
        });
      }
      return;
    }

    if (!isBackground && mounted) {
      setState(() {
        _loadingStickers = true;
        _stickersError = null;
        _stickers = [];
      });
    }

    try {
      final getStickers = ref.read(getStickersInPackageUseCaseProvider);
      final result = await getStickers(packageId);

      result.fold(
        (l) {
          if (!isBackground) throw Exception(l.message);
        },
        (r) {
          _stickersCache[packageId] = r;
          if (r.isNotEmpty) {
            _packageCoverById[packageId] = r.first;
          }
          if (mounted) {
            if (_packages.isNotEmpty && _packages[_selectedPackageIndex].id == packageId) {
              setState(() {
                _stickers = r;
                if (!isBackground) _loadingStickers = false;
              });
            } else if (r.isNotEmpty) {
              // Trigger rebuild to show the new cover
              setState(() {});
            }
          }
        },
      );

      if (!isBackground && mounted) {
        setState(() {
          _loadingStickers = false;
        });
      }
    } catch (e) {
      if (!isBackground && mounted) {
        setState(() {
          _loadingStickers = false;
          _stickersError = e.toString();
        });
      }
    }
  }

  void _onTapSticker(StickerItem sticker) {
    _recent.removeWhere((e) => e.id == sticker.id);
    _recent.insert(0, sticker);
    if (_recent.length > 20) {
      _recent.removeLast();
    }

    widget.onStickerTap(sticker);
  }

  String _normalizeUrl(String url) => url.trim();

  Widget _buildNetworkImage({
    required String url,
    required BoxFit fit,
    required Widget errorIcon,
  }) {
    final normalized = _normalizeUrl(url);
    if (normalized.isEmpty) return Center(child: errorIcon);

    // On web, some .webp variants fail in CanvasKit/HTML image decode paths.
    // HtmlElementView via Image.network(webHtmlElementStrategy) is a practical fallback.
    return Image.network(
      normalized,
      fit: fit,
      filterQuality: FilterQuality.medium,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, error) {
        debugPrint('Image render error: $normalized | $error');
        // Last fallback to bypass Flutter image codecs on web.
        if (kIsWeb) {
          return Image.network(
            normalized,
            fit: fit,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (_, __, ___) => Center(child: errorIcon),
          );
        }
        return Center(child: errorIcon);
      },
    );
  }

  bool _isSpriteSticker(StickerItem sticker) {
    final text = '${sticker.id} ${sticker.url}'.toLowerCase();
    return text.contains('sprite');
  }

  Widget _buildStickerTile(StickerItem sticker) {
    if (_isSpriteSticker(sticker)) {
      final normalized = _normalizeUrl(sticker.url);
      if (normalized.isEmpty) {
        return const Center(child: Icon(Icons.broken_image_outlined));
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AnimatedStickerSprite(
          imageProvider: NetworkImage(normalized),
          width: double.infinity,
          height: double.infinity,
          fps: 12,
          fit: BoxFit.contain,
        ),
      );
    }

    return _buildNetworkImage(
      url: sticker.url,
      fit: BoxFit.contain,
      errorIcon: const Icon(Icons.broken_image_outlined),
    );
  }

  Widget _buildPackageCover(StickerPackage package) {
    final thumbnail = _normalizeUrl(package.thumbnailUrl);
    if (thumbnail.isNotEmpty) {
      return _buildNetworkImage(
        url: thumbnail,
        fit: BoxFit.cover,
        errorIcon: const Icon(Icons.image_not_supported_outlined),
      );
    }

    final fallbackSticker = _packageCoverById[package.id];
    if (fallbackSticker == null) {
      return const Icon(Icons.image_not_supported_outlined);
    }

    if (_isSpriteSticker(fallbackSticker)) {
      final normalized = _normalizeUrl(fallbackSticker.url);
      if (normalized.isEmpty) {
        return const Icon(Icons.image_not_supported_outlined);
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AnimatedStickerSprite(
          imageProvider: NetworkImage(normalized),
          width: double.infinity,
          height: double.infinity,
          fps: 1, // Stop animation to show only first frame, minimum is 1 to avoid assertion error
          repeat: false,
          fit: BoxFit.cover,
        ),
      );
    }

    return _buildNetworkImage(
      url: fallbackSticker.url,
      fit: BoxFit.cover,
      errorIcon: const Icon(Icons.image_not_supported_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loadingPackages) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_packagesError != null) {
      return Center(
        child: TextButton(
          onPressed: _loadPackages,
          child: const Text('Khong tai duoc sticker. Thu lai'),
        ),
      );
    }
    if (_packages.isEmpty) {
      return const Center(child: Text('Server chua tra package nao'));
    }

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _packages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = _packages[index];
              final selected = index == _selectedPackageIndex;
              return InkWell(
                onTap: () async {
                  setState(() => _selectedPackageIndex = index);
                  await _loadStickers(item.id);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                  ),
                  child: _buildPackageCover(item),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildStickerGrid()),
      ],
    );
  }

  Widget _buildStickerGrid() {
    if (_loadingStickers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_stickersError != null) {
      return Center(
        child: TextButton(
          onPressed: () => _loadStickers(_packages[_selectedPackageIndex].id),
          child: const Text('Khong tai duoc sticker. Thu lai'),
        ),
      );
    }
    if (_stickers.isEmpty) {
      return const Center(child: Text('Khong co sticker cho package nay'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _stickers.length,
      itemBuilder: (context, index) {
        final sticker = _stickers[index];
        return InkWell(
          onTap: () => _onTapSticker(sticker),
          child: _buildStickerTile(sticker),
        );
      },
    );
  }
}
