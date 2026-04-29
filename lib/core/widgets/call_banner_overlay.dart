import 'package:flutter/material.dart';
import 'package:flutter_chat/core/widgets/app_call_banner.dart';

class CallBannerOverlay {
  OverlayEntry? _entry;

  void show({
    required OverlayState overlayState,
    required String callerName,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    hide(); // tránh duplicate

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: TopCallBanner(
          callerName: callerName,
          onAccept: onAccept,
          onDecline: onDecline,
        ),
      ),
    );

    overlayState.insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}