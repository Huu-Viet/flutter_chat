import 'package:flutter/material.dart';
import 'package:flutter_chat/core/errors/failures.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:flutter_chat/presentation/chat/chat_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectChatInfoPage extends ConsumerStatefulWidget {
  final Conversation conversation;
  final String targetUserId;
  final String title;
  final String? avatarUrl;
  final bool initialBlockedByTarget;
  final bool initialBlockedByMe;

  const DirectChatInfoPage({
    super.key,
    required this.conversation,
    required this.targetUserId,
    required this.title,
    this.avatarUrl,
    this.initialBlockedByTarget = false,
    this.initialBlockedByMe = false,
  });

  @override
  ConsumerState<DirectChatInfoPage> createState() =>
      _DirectChatInfoPageState();
}

class _DirectChatInfoPageState extends ConsumerState<DirectChatInfoPage> {
  bool _busyNotify = false;
  String _muteDuration = 'off';
  bool? _blockedByMeLocalHint;

  void _toast(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessageFor(Object error, {required String fallback}) {
    if (error is Failure) {
      return switch (error) {
        ServerFailure(:final message) => message,
        CacheFailure(:final message) => message,
        NetworkFailure(:final message) => message,
        ValidationFailure(:final message) => message,
        _ => fallback,
      };
    }

    return fallback;
  }

  Future<void> _applyMute() async {
    setState(() => _busyNotify = true);
    try {
      await ref.read(updateConversationMuteUseCaseProvider)(
        conversationId: widget.conversation.id,
        muteDuration: _muteDuration,
      );
      _toast('Notification mute updated');
    } catch (error) {
      _toast(
        _errorMessageFor(
          error,
          fallback: 'Failed to update notification mute.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyNotify = false);
      }
    }
  }

  Future<void> _toggleBlock({required bool isBlocked}) async {
    final event = isBlocked
        ? UnblockUserEvent(widget.targetUserId)
        : BlockUserEvent(widget.targetUserId);

    ref.read(chatBlocProvider).add(event);

    // Listen for feedback from BLoC
    if (!mounted) return;

    ref.listen<ChatState>(
      chatBlocProvider.select((bloc) => bloc.state),
      (previous, current) {
        if (current is ChatLoaded) {
          final feedback = current.conversationState.friendshipActionFeedback;
          if (feedback != null &&
              feedback.targetUserId == widget.targetUserId) {
            _blockedByMeLocalHint = isBlocked ? false : true;
            _toast('User ${isBlocked ? 'unblocked' : 'blocked'}');
            ref.invalidate(friendshipStatusProvider(widget.targetUserId));
          }
        }
      },
    );
  }

  Future<void> _deleteConversation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete conversation'),
          content: const Text(
            'This will remove the conversation from your chat list until a new message arrives.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(deleteConversationForMeUseCaseProvider)(
        widget.conversation.id,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      _toast(
        _errorMessageFor(
          error,
          fallback: 'Failed to delete the conversation.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendshipStatusAsync = ref.watch(
      friendshipStatusProvider(widget.targetUserId),
    );
    final chatState = ref.watch(chatBlocProvider).state;
    final theme = Theme.of(context);

    // Track if a friendship action is in progress for this user
    final isBusyDanger = chatState is ChatLoaded
        ? chatState.conversationState.friendshipActionInProgressUserIds
            .contains(widget.targetUserId)
        : false;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(title: widget.title, avatarUrl: widget.avatarUrl),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Notifications',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mute this conversation',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _muteDuration,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'off', child: Text('Off')),
                    DropdownMenuItem(value: '1h', child: Text('1 hour')),
                    DropdownMenuItem(value: '4h', child: Text('4 hours')),
                    DropdownMenuItem(value: '8h', child: Text('8 hours')),
                    DropdownMenuItem(value: '24h', child: Text('24 hours')),
                    DropdownMenuItem(value: 'forever', child: Text('Forever')),
                  ],
                  onChanged: _busyNotify
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _muteDuration = value);
                        },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _busyNotify ? null : _applyMute,
                    child: _busyNotify
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Danger Zone',
            titleColor: theme.colorScheme.error,
            child: Column(
              children: [
                _DangerActionTile(
                  icon: Icons.delete_outline,
                  label: 'Delete conversation',
                  description:
                      'Remove this chat from your list on this account until a newer message appears.',
                  busy: false,
                  onTap: _deleteConversation,
                ),
                const Divider(height: 24),
                friendshipStatusAsync.when(
                  data: (status) {
                    final isBlocked = status?.isBlocked == true;
                    final hasDirection = status?.hasBlockDirection == true;

                    final localHintBlockedByMe = _blockedByMeLocalHint;
                    final fallbackBlockedByMe =
                        localHintBlockedByMe ?? widget.initialBlockedByMe;
                    final fallbackBlockedByTarget =
                        localHintBlockedByMe == null
                        ? widget.initialBlockedByTarget
                        : !localHintBlockedByMe;

                    final blockedByMe =
                        status?.isBlockedByMe == true ||
                        (!hasDirection && isBlocked && fallbackBlockedByMe);
                    final blockedByTarget =
                        status?.isBlockedByTarget == true ||
                        (!hasDirection && isBlocked && fallbackBlockedByTarget);

                    if (blockedByTarget && !blockedByMe) {
                      return const _DangerActionTile(
                        icon: Icons.block_outlined,
                        label: 'You are blocked',
                        description:
                            'This user blocked you. You cannot unblock from your side.',
                        busy: false,
                        enabled: false,
                      );
                    }

                    final canUnblock = isBlocked && blockedByMe;
                    return _DangerActionTile(
                      icon: Icons.block_outlined,
                      label: canUnblock ? 'Unblock user' : 'Block user',
                      description: canUnblock
                          ? 'Allow this user to message you again in direct chat.'
                          : 'Prevent this user from messaging you in direct chat.',
                      busy: isBusyDanger,
                      onTap: () => _toggleBlock(isBlocked: canUnblock),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => _DangerActionTile(
                    icon: Icons.block_outlined,
                    label: 'Block user',
                    description: 'Unable to load block status right now.',
                    busy: isBusyDanger,
                    onTap: () => _toggleBlock(isBlocked: false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String? avatarUrl;

  const _HeaderCard({required this.title, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedTitle = title.trim().isNotEmpty ? title.trim() : 'Direct Chat';
    final initial = normalizedTitle.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage:
                avatarUrl != null && avatarUrl!.trim().isNotEmpty
                ? NetworkImage(avatarUrl!.trim())
                : null,
            child: avatarUrl == null || avatarUrl!.trim().isEmpty
                ? Text(initial, style: theme.textTheme.titleMedium)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(normalizedTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Direct conversation settings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? titleColor;

  const _SectionCard({
    required this.title,
    required this.child,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(color: titleColor),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DangerActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool busy;
  final bool enabled;
  final VoidCallback? onTap;

  const _DangerActionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.busy,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = enabled && !busy;

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isEnabled
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (busy) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}