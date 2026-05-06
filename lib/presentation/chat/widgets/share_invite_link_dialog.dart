import 'package:flutter/material.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/chat/domain/entities/messages/message/message.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_chat/presentation/home/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Dialog that lets the user select conversations to share an invite link into.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ShareInviteLinkDialog(
///     inviteUrl: _inviteUrl!,
///     groupName: widget.conversation.name,
///   ),
/// );
/// ```
class ShareInviteLinkDialog extends ConsumerStatefulWidget {
  final String inviteUrl;
  final String groupName;

  const ShareInviteLinkDialog({
    super.key,
    required this.inviteUrl,
    required this.groupName,
  });

  @override
  ConsumerState<ShareInviteLinkDialog> createState() =>
      _ShareInviteLinkDialogState();
}

class _ShareInviteLinkDialogState extends ConsumerState<ShareInviteLinkDialog> {
  final Set<String> _selected = {};
  bool _sending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final result = await ref.read(getCurrentUserIdUseCaseProvider)();
    result.fold((_) {}, (id) {
      if (mounted) setState(() => _currentUserId = id.trim());
    });
  }

  List<Conversation> _getConversations() {
    final homeState = ref.read(homeBlocProvider).state;
    if (homeState is HomeLoaded) return homeState.conversations;
    return const [];
  }

  String get _shareText =>
      'Join "${widget.groupName}" on Zolo:\n${widget.inviteUrl}';

  Future<void> _sendToSelected() async {
    if (_selected.isEmpty || _sending) return;
    setState(() => _sending = true);

    final sendUseCase = ref.read(sendMessageUseCaseProvider);
    final senderId = _currentUserId ?? '';
    final now = DateTime.now();
    final uuid = const Uuid();

    for (final conversationId in _selected) {
      final messageId = uuid.v4();
      final msg = TextMessage(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        offset: null,
        isDeleted: false,
        serverId: messageId,
        createdAt: now,
        editedAt: null,
        text: _shareText,
      );
      await sendUseCase(message: msg);
    }

    if (mounted) {
      setState(() => _sending = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invite link sent to ${_selected.length} conversation(s)',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _getConversations();

    return AlertDialog(
      title: const Text('Share Invite Link'),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: conversations.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No conversations available.')),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final isChecked = _selected.contains(conv.id);
                  return CheckboxListTile(
                    value: isChecked,
                    onChanged: _sending
                        ? null
                        : (val) {
                            setState(() {
                              if (val == true) {
                                _selected.add(conv.id);
                              } else {
                                _selected.remove(conv.id);
                              }
                            });
                          },
                    title: Text(
                      conv.name.isNotEmpty ? conv.name : '(Unnamed)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      conv.type == 'group' ? 'Group' : 'Direct',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    secondary: CircleAvatar(
                      backgroundImage: conv.avatarUrl.isNotEmpty
                          ? NetworkImage(conv.avatarUrl)
                          : null,
                      child: conv.avatarUrl.isEmpty
                          ? Text(
                              conv.name.isNotEmpty
                                  ? conv.name[0].toUpperCase()
                                  : '?',
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected.isEmpty || _sending ? null : _sendToSelected,
          child: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Send (${_selected.length})'),
        ),
      ],
    );
  }
}
