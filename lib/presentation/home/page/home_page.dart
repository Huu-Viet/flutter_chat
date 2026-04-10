import 'package:flutter/material.dart';
import 'package:flutter_chat/app/app_permission.dart';
import 'package:flutter_chat/app/e_app_route.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_chat/presentation/home/home_provider.dart';
import 'package:flutter_chat/presentation/home/widgets/friend_status_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/chat_list_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    AppPermission.requestNotificationPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.app_name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
          //Todo: Navigate to new chat or add functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New chat feature coming soon!')),
          );
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}

class HomePageContent extends ConsumerStatefulWidget {
  const HomePageContent({super.key});

  @override
  ConsumerState<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends ConsumerState<HomePageContent> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent - 160;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(homeBlocProvider).add(const LoadMoreHomeEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networkStatusAsync = ref.watch(networkStatusProvider);
    final l10n = AppLocalizations.of(context)!;

    final homeBloc = ref.watch(homeBlocProvider);

    // fake data for online friends (TODO: wire real friends later)
    final onlineFriends = [
      MyUser(
        id: 'user-001',
        email: 'john.doe@example.com',
        username: 'john_doe',
        firstName: 'John',
        lastName: 'Doe',
        phone: '0901234567',
        avatarUrl: null,
        orgId: 'org-default',
        orgRole: 'ORG_MEMBER',
        accountStatus: 'ACTIVE',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return Column(
      children: [
        // Network Status Info - only show for mobile data or no network
        networkStatusAsync.when(
          data: (networkStatus) {
            final shouldShowCard =
                !networkStatus.isConnected || networkStatus.connectionType == NetworkConnectionType.mobile;
            return shouldShowCard ? _NetworkStatusCard() : const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: FriendStatusBar(onlineFriends: onlineFriends),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.search,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceBright,
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              l10n.messages,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Chat List - backed by HomeBloc
        Expanded(
          child: StreamBuilder<HomeState>(
            stream: homeBloc.stream,
            initialData: homeBloc.state,
            builder: (context, snapshot) {
              final state = snapshot.data;

              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeFailure) {
                return Center(child: Text(state.failure.message));
              }

              if (state is HomeLoaded) {
                if (state.conversations.isEmpty) {
                  return Center(child: Text("There are no conversations yet!"));
                }

                return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.conversations.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                      if (index >= state.conversations.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                    final c = state.conversations[index];
                    return ChatListTile(
                      name: c.name,
                      lastMessage: '',
                      time: c.updatedAt,
                      unreadCount: 0,
                      avatarUrl: c.avatarUrl.isEmpty ? null : c.avatarUrl,
                    );
                  },
                );
              }

              return const SizedBox.shrink();
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