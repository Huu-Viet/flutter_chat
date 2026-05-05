import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/core/errors/failures.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  bool _busyDanger = false;
  String _muteDuration = 'off';
  bool? _blockedByMeLocalHint;

  Dio get _dio => ref.read(authDioProvider);
  static String get _baseUrl => dotenv.get('NEST_API_BASE_URL');

  String _url(String path) {
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$base$normalizedPath';
  }

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

    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        final nestedMessage = responseData['message']?.toString().trim();
        if (nestedMessage != null && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }

      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }

  Future<void> _applyMute() async {
    setState(() => _busyNotify = true);
    try {
      await _dio.put(
        _url('/notifications/conversations/${widget.conversation.id}/mute'),
        data: {'duration': _muteDuration},
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
    setState(() => _busyDanger = true);
    try {
      final result = isBlocked
          ? await ref.read(unblockUserUseCaseProvider)(widget.targetUserId)
          : await ref.read(blockUserUseCaseProvider)(widget.targetUserId);

      result.fold(
        (failure) => throw failure,
        (_) {
          _blockedByMeLocalHint = isBlocked ? false : true;
          ref.invalidate(friendshipStatusProvider(widget.targetUserId));
        },
      );

      _toast('User ${isBlocked ? 'unblocked' : 'blocked'}');
    } catch (error) {
      _toast(
        _errorMessageFor(
          error,
          fallback: 'Failed to ${isBlocked ? 'unblock' : 'block'} this user.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyDanger = false);
      }
    }
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

    setState(() => _busyDanger = true);
    try {
      await _dio.delete(_url('/conversations/${widget.conversation.id}/for-me'));
      final deleteLocalResult = await ref.read(deleteLocalConversationUseCaseProvider)(
        widget.conversation.id,
      );
      deleteLocalResult.fold((failure) => throw failure, (_) {});
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
    } finally {
      if (mounted) {
        setState(() => _busyDanger = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendshipStatusAsync = ref.watch(
      friendshipStatusProvider(widget.targetUserId),
    );
    final theme = Theme.of(context);

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
                  busy: _busyDanger,
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
                      busy: _busyDanger,
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
                    busy: _busyDanger,
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
    final effectiveEnabled = enabled && !busy;
    final labelColor = effectiveEnabled
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: effectiveEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: labelColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    effectiveEnabled ? Icons.chevron_right : Icons.block,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ],
        ),
      ),
    );
  }
}