import 'package:flutter/material.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkBanner extends ConsumerWidget {
  final Widget child;

  const NetworkBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatusAsync = ref.watch(networkStatusProvider);

    return Column(
      children: [
        // Network status banner
        networkStatusAsync.when(
          data: (networkStatus) {
            return _buildBanner(context, networkStatus);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // Main content
        Expanded(child: child),
      ],
    );
  }

  Widget _buildBanner(BuildContext context, NetworkStatus networkStatus) {
    if (!networkStatus.isConnected) {
      return _NetworkStatusBar(
        message: 'Không có kết nối mạng',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        icon: Icons.wifi_off,
      );
    }

    if (networkStatus.connectionType == NetworkConnectionType.mobile) {
      return _NetworkStatusBar(
        message: 'Bạn đang sử dụng dữ liệu di động',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        icon: Icons.signal_cellular_alt,
      );
    }

    // WiFi or Ethernet - no banner needed
    return const SizedBox.shrink();
  }
}

class _NetworkStatusBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const _NetworkStatusBar({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Utility widget for showing network-dependent content
class NetworkDependentWidget extends ConsumerWidget {
  final Widget onlineChild;
  final Widget? offlineChild;
  final Widget? mobileDataChild;

  const NetworkDependentWidget({
    super.key,
    required this.onlineChild,
    this.offlineChild,
    this.mobileDataChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatusAsync = ref.watch(networkStatusProvider);

    return networkStatusAsync.when(
      data: (networkStatus) {
        if (!networkStatus.isConnected) {
          return offlineChild ??
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No network connection',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
        }

        if (networkStatus.connectionType == NetworkConnectionType.mobile &&
            mobileDataChild != null) {
          return mobileDataChild!;
        }

        return onlineChild;
      },
      loading: () => onlineChild,
      error: (_, __) => onlineChild,
    );
  }
}