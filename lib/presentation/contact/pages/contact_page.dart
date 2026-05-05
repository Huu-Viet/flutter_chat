import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friend_user.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/contact/blocs/contact_bloc.dart';
import 'package:flutter_chat/presentation/contact/contact_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactPage extends ConsumerStatefulWidget {
  final Function(int amount) onPendingRequestCountChanged;

  const ContactPage({super.key, required this.onPendingRequestCountChanged});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  Future<void> _refreshContactData() async {
    final bloc = ref.read(contactBlocProvider);
    bloc.add(const LoadContactData(showLoading: false));
    await bloc.stream.firstWhere((state) => state is! ContactLoading);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(contactBlocProvider).add(const LoadContactData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = ref.watch(contactBlocProvider);

    return BlocProvider<ContactBloc>.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.contacts,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocListener<ContactBloc, ContactState>(
              listenWhen: (previous, current) => current is ContactLoaded,
              listener: (context, state) {
                if (state is ContactLoaded) {
                  widget.onPendingRequestCountChanged(state.incomingRequests.length);
                }
              },
              child: BlocBuilder<ContactBloc, ContactState>(
                builder: (context, state) {
                  if (state is ContactLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ContactError) {
                    return RefreshIndicator(
                      onRefresh: _refreshContactData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(child: Text(state.message)),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ContactLoaded) {
                    final hasAnyData = state.incomingRequests.isNotEmpty ||
                        state.outgoingRequests.isNotEmpty ||
                        state.friends.isNotEmpty;

                    if (!hasAnyData) {
                      return RefreshIndicator(
                        onRefresh: _refreshContactData,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(child: Text(l10n.empty_data)),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshContactData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _SectionHeader(
                            title: 'Lời mời kết bạn',
                            count: state.incomingRequests.length,
                          ),
                          _IncomingRequestsSection(
                            users: state.incomingRequests,
                            busyUserIds: state.busyUserIds,
                            onAccept: (id) => context
                                .read<ContactBloc>()
                                .add(AcceptIncomingRequest(id)),
                            onDecline: (id) => context
                                .read<ContactBloc>()
                                .add(DeclineIncomingRequest(id)),
                          ),
                          const SizedBox(height: 18),
                          _SectionHeader(
                            title: 'Đã gửi',
                            count: state.outgoingRequests.length,
                          ),
                          _OutgoingRequestsSection(
                            users: state.outgoingRequests,
                            busyUserIds: state.busyUserIds,
                            onCancel: (id) => context
                                .read<ContactBloc>()
                                .add(CancelOutgoingRequest(id)),
                          ),
                          const SizedBox(height: 18),
                          const _SectionHeader(title: 'Bạn bè hiện tại'),
                          _FriendListSection(
                            friends: state.friends,
                            busyUserIds: state.busyUserIds,
                            onRemove: (id) => context
                                .read<ContactBloc>()
                                .add(RemoveFriend(id)),
                          ),
                          if (state.isRefreshing)
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshContactData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(child: Text('No incoming requests yet')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;

  const _SectionHeader({required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    final suffix = count != null ? ' ($count)' : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$title$suffix',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _IncomingRequestsSection extends StatelessWidget {
  final List<MyUser> users;
  final Set<String> busyUserIds;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onDecline;

  const _IncomingRequestsSection({
    required this.users,
    required this.busyUserIds,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const _EmptySection(message: 'Chưa có lời mời đến');
    }

    return Column(
      children: users
          .map(
            (user) => _ContactCard(
              user: user,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Chấp nhận',
                    onPressed:
                        busyUserIds.contains(user.id) ? null : () => onAccept(user.id),
                    icon: busyUserIds.contains(user.id)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'Từ chối',
                    onPressed:
                        busyUserIds.contains(user.id) ? null : () => onDecline(user.id),
                    icon: const Icon(Icons.cancel_outlined),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _OutgoingRequestsSection extends StatelessWidget {
  final List<MyUser> users;
  final Set<String> busyUserIds;
  final ValueChanged<String> onCancel;

  const _OutgoingRequestsSection({
    required this.users,
    required this.busyUserIds,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const _EmptySection(message: 'Không có lời mời đang chờ');
    }

    return Column(
      children: users
          .map(
            (user) => _ContactCard(
              user: user,
              trailing: OutlinedButton(
                onPressed:
                    busyUserIds.contains(user.id) ? null : () => onCancel(user.id),
                child: busyUserIds.contains(user.id)
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Huỷ yêu cầu'),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _FriendListSection extends StatelessWidget {
  final List<FriendUser> friends;
  final Set<String> busyUserIds;
  final ValueChanged<String> onRemove;

  const _FriendListSection({
    required this.friends,
    required this.busyUserIds,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const _EmptySection(message: 'Chưa có bạn bè');
    }

    final grouped = <String, List<FriendUser>>{};
    for (final friend in friends) {
      final key = _firstLetter(friend.user.displayName);
      grouped.putIfAbsent(key, () => <FriendUser>[]).add(friend);
    }

    final keys = grouped.keys.toList(growable: false)..sort((a, b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keys.map((key) {
        final items = grouped[key]!
          ..sort(
            (a, b) =>
                a.user.displayName.toLowerCase().compareTo(b.user.displayName.toLowerCase()),
          );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                key,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            ...items.map(
              (friend) => _ContactCard(
                user: friend.user,
                trailing: TextButton.icon(
                  onPressed: busyUserIds.contains(friend.user.id)
                      ? null
                      : () => onRemove(friend.user.id),
                  icon: busyUserIds.contains(friend.user.id)
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_remove_alt_1_outlined, size: 18),
                  label: const Text('Huỷ kết bạn'),
                ),
              ),
            ),
          ],
        );
      }).toList(growable: false),
    );
  }

  String _firstLetter(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return '#';
    }
    return text.substring(0, 1).toUpperCase();
  }
}

class _ContactCard extends StatelessWidget {
  final MyUser user;
  final Widget trailing;

  const _ContactCard({required this.user, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName.trim().isNotEmpty ? user.displayName : user.username;
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: CircleAvatar(
          backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
          child: hasAvatar ? null : Text(displayName.substring(0, 1).toUpperCase()),
        ),
        title: Text(displayName, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text('@${user.username}', style: Theme.of(context).textTheme.bodySmall),
        trailing: trailing,
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}