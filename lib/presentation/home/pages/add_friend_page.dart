import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/features/auth/user_providers.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/domain/usecases/create_direct_conversation_usecase.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/home/blocs/add_friend_blocs/add_friend_bloc.dart';
import 'package:flutter_chat/presentation/home/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddFriendPage extends ConsumerStatefulWidget {
  const AddFriendPage({super.key});

  @override
  ConsumerState<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends ConsumerState<AddFriendPage> {
  late final AddFriendBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ref.read(addFriendBlocProvider);
    _bloc.add(const AddFriendResetRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider<AddFriendBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.add_friend),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: BlocBuilder<AddFriendBloc, AddFriendState>(
                builder: (context, state) {
                  return TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.add_friend_hint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _bloc.add(const AddFriendResetRequested());
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => _bloc.add(AddFriendQueryChanged(value)),
                    onSubmitted: (_) => _bloc.add(const AddFriendSearchRequested()),
                  );
                },
              ),
            ),
            BlocBuilder<AddFriendBloc, AddFriendState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state.query.trim().isEmpty || state is AddFriendLoading
                          ? null
                          : () => _bloc.add(const AddFriendSearchRequested()),
                      icon: state is AddFriendLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(l10n.search),
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<AddFriendBloc, AddFriendState>(
                builder: (context, state) {
                  if (state is AddFriendLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AddFriendFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!state.hasSearched) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.add_friend_guide,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    );
                  }

                  if (state.users.isEmpty) {
                    return Center(
                      child: Text(l10n.error_user_not_found),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      final isFriendOrPending =
                          state.friendAndPendingUserIds.contains(user.id);
                      return _UserSearchTile(
                        user: user,
                        isFriendOrPending: isFriendOrPending,
                        isBusy: state.busyUserId == user.id,
                        onAddFriend: () =>
                            _bloc.add(AddFriendRequestRequested(user.id)),
                        onViewProfile: () =>
                            _showUserProfileDialog(context, user),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserProfileDialog(BuildContext context, MyUser user) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _UserProfileDialog(
        user: user,
        addFriendBloc: _bloc,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// User search tile
// ─────────────────────────────────────────────────────────
class _UserSearchTile extends StatelessWidget {
  final MyUser user;
  final bool isFriendOrPending;
  final bool isBusy;
  final VoidCallback onAddFriend;
  final VoidCallback onViewProfile;

  const _UserSearchTile({
    required this.user,
    required this.isFriendOrPending,
    required this.isBusy,
    required this.onAddFriend,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        (user.firstName != null && user.lastName != null)
            ? '${user.firstName} ${user.lastName}'.trim()
            : user.username;
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          initials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(displayName),
      subtitle: Text(
        '@${user.username}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Eye icon — view profile
          IconButton(
            tooltip: 'View profile',
            onPressed: onViewProfile,
            icon: const Icon(Icons.visibility_outlined),
          ),
          // Add friend icon
          if (!isFriendOrPending)
            IconButton(
              tooltip: 'Add friend',
              onPressed: isBusy ? null : onAddFriend,
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_1_outlined),
            )
          else
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 22),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// User profile dialog
// ─────────────────────────────────────────────────────────
class _UserProfileDialog extends ConsumerStatefulWidget {
  final MyUser user;
  final AddFriendBloc addFriendBloc;

  const _UserProfileDialog({
    required this.user,
    required this.addFriendBloc,
  });

  @override
  ConsumerState<_UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends ConsumerState<_UserProfileDialog> {
  bool _creatingConversation = false;

  String get _displayName {
    if (widget.user.firstName != null || widget.user.lastName != null) {
      return '${widget.user.firstName ?? ''} ${widget.user.lastName ?? ''}'.trim();
    }
    return widget.user.username;
  }

  String get _initials {
    final name = _displayName;
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _sendMessage(BuildContext ctx) async {
    setState(() => _creatingConversation = true);
    try {
      final useCase = ref.read(createDirectConversationUseCaseProvider);
      final result = await useCase(widget.user.id);
      if (!ctx.mounted) return;
      result.fold(
        (failure) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Could not open conversation: ${failure.message}')),
          );
        },
        (conversation) {
          Navigator.of(ctx).pop(); // close dialog
          ctx.push('/chat/${conversation.id}/${Uri.encodeComponent(_displayName)}');
        },
      );
    } finally {
      if (mounted) setState(() => _creatingConversation = false);
    }
  }

  Future<void> _blockUser(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Block user'),
        content: Text('Block $_displayName? They will no longer be able to message you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirmed != true || !ctx.mounted) return;

    final result =
        await ref.read(blockUserUseCaseProvider)(widget.user.id);
    if (!ctx.mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(ctx)
          .showSnackBar(SnackBar(content: Text('Failed to block: ${f.message}'))),
      (_) {
        Navigator.of(ctx).pop();
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('$_displayName has been blocked.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final friendshipAsync =
        ref.watch(friendshipStatusProvider(widget.user.id));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 20),

            // Avatar + name + status
            Row(
              children: [
                _AvatarWidget(initials: _initials, colorScheme: colorScheme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${widget.user.username}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.user.isActive
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.user.isActive ? 'Online' : 'Offline',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Send message button
            FilledButton.icon(
              onPressed: _creatingConversation ? null : () => _sendMessage(context),
              icon: _creatingConversation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.chat_bubble_outline),
              label: const Text('Send Message'),
            ),
            const SizedBox(height: 8),

            // Add friend / status button
            friendshipAsync.when(
              loading: () => const SizedBox(
                height: 40,
                child: Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (status) {
                if (status == null || status.isNone) {
                  return _FriendActionButton(
                    label: 'Add Friend',
                    icon: Icons.person_add_alt_1_outlined,
                    onPressed: () {
                      widget.addFriendBloc
                          .add(AddFriendRequestRequested(widget.user.id));
                      // Refresh status
                      ref.invalidate(friendshipStatusProvider(widget.user.id));
                      Navigator.of(context).pop();
                    },
                  );
                } else if (status.isPendingOut) {
                  return _FriendActionButton(
                    label: 'Request Sent',
                    icon: Icons.hourglass_top_outlined,
                    enabled: false,
                  );
                } else if (status.isPendingIn) {
                  return _FriendActionButton(
                    label: 'Accept Request',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      ref
                          .read(acceptFriendRequestUseCaseProvider)
                          .call(widget.user.id)
                          .then((_) {
                        ref.invalidate(friendshipStatusProvider(widget.user.id));
                      });
                      Navigator.of(context).pop();
                    },
                  );
                } else if (status.isFriend) {
                  return _FriendActionButton(
                    label: 'Already Friends',
                    icon: Icons.people_outline,
                    enabled: false,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 4),

            // Block user
            Center(
              child: TextButton.icon(
                onPressed: () => _blockUser(context),
                icon: const Icon(Icons.block, size: 18),
                label: const Text('Block User'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final String initials;
  final ColorScheme colorScheme;

  const _AvatarWidget({required this.initials, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _FriendActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;

  const _FriendActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: const Size(double.infinity, 44),
      ),
    );
  }
}
