import 'package:flutter/material.dart';
import 'package:flutter_chat/app/e_app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/network_service.dart';
import 'widgets/chat_list_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
        actions: [
          IconButton(
            onPressed: () {
              context.push(AppRoute.profile.path);
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: const HomePageContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new chat or add functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New chat feature coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomePageContent extends ConsumerWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatusAsync = ref.watch(networkStatusProvider);
    
    return Column(
      children: [
        // Network Status Info - only show for mobile data or no network
        networkStatusAsync.when(
          data: (networkStatus) {
            final shouldShowCard = !networkStatus.isConnected || 
                networkStatus.connectionType == NetworkConnectionType.mobile;
            return shouldShowCard ? _NetworkStatusCard() : const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search chats...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceBright,
            ),
          ),
        ),
      
        // Chat List - always show even when offline
        Expanded(
          child: ListView.builder(
            itemCount: 10, // Mock data
            itemBuilder: (context, index) {
              return ChatListTile(
                name: 'User ${index + 1}',
                lastMessage: 'This is the last message from user ${index + 1}',
                time: '${10 + index}:${30 + index}',
                unreadCount: index % 3 == 0 ? index + 1 : 0,
                avatarUrl: null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Demo widget to show current network status
class _NetworkStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatusAsync = ref.watch(networkStatusProvider);

    return networkStatusAsync.when(
      data: (networkStatus) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(
              _getNetworkIcon(networkStatus.connectionType),
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getNetworkMessage(networkStatus),
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  IconData _getNetworkIcon(NetworkConnectionType type) {
    switch (type) {
      case NetworkConnectionType.wifi:
        return Icons.wifi;
      case NetworkConnectionType.mobile:
        return Icons.signal_cellular_alt;
      case NetworkConnectionType.ethernet:
        return Icons.wifi;
      case NetworkConnectionType.none:
        return Icons.wifi_off;
    }
  }

  String _getNetworkMessage(NetworkStatus status) {
    if (!status.isConnected) {
      return 'Không có kết nối mạng';
    }
    
    switch (status.connectionType) {
      case NetworkConnectionType.wifi:
        return 'Đã kết nối WiFi';
      case NetworkConnectionType.mobile:
        return 'Đang sử dụng dữ liệu di động';
      case NetworkConnectionType.ethernet:
        return 'Đã kết nối Ethernet';
      case NetworkConnectionType.none:
        return 'Không có kết nối';
    }
  }
}