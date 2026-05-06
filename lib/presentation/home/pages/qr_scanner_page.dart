import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

const _inviteDeepLinkHost = 'zolo-smoky.vercel.app';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _handled = true;
    await _controller.stop();

    final uri = Uri.tryParse(rawValue);
    if (!mounted) return;

    if (uri != null && _isInviteLink(uri)) {
      final token = uri.pathSegments[1].trim();
      context.go('/join/${Uri.encodeComponent(token)}');
    } else if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      context.pop();
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        try {
          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        } catch (_) {}
      }
    } else {
      // Not a URL — show raw text and allow re-scan
      if (!mounted) return;
      final again = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('QR Code'),
          content: SelectableText(rawValue),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Scan again'),
            ),
          ],
        ),
      );
      if (again == true && mounted) {
        _handled = false;
        await _controller.start();
      } else if (mounted) {
        context.pop();
      }
    }
  }

  bool _isInviteLink(Uri uri) {
    return uri.host == _inviteDeepLinkHost &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'join';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
            tooltip: 'Toggle flash',
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.flip_camera_ios),
            tooltip: 'Switch camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Scan window overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Point your camera at a QR code',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
