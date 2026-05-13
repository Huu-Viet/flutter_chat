import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/features/auth/auth_providers.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/presentation/chat/blocs/share_invite_cubit.dart';
import 'package:flutter_chat/presentation/home/blocs/home_bloc.dart';
import 'package:flutter_chat/presentation/home/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late final ShareInviteCubit _shareInviteCubit;

  @override
  void initState() {
    super.initState();
    _shareInviteCubit = ShareInviteCubit(
      getCurrentUserIdUseCase: ref.read(getCurrentUserIdUseCaseProvider),
      sendMessageUseCase: ref.read(sendMessageUseCaseProvider),
    );
    _shareInviteCubit.loadCurrentUser();
  }

  List<Conversation> _getConversations() {
    final homeState = ref.read(homeBlocProvider).state;
    if (homeState is HomeLoaded) return homeState.conversations;
    return const [];
  }

  String get _shareText =>
      'Join "${widget.groupName}" on Zolo:\n${widget.inviteUrl}';

  Future<void> _sendToSelected() async {
    await _shareInviteCubit.sendInvite(
      targetConversationIds: _selected,
      shareText: _shareText,
    );
  }

  @override
  void dispose() {
    _shareInviteCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _getConversations();

    return BlocConsumer<ShareInviteCubit, ShareInviteState>(
      bloc: _shareInviteCubit,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.trim().isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          _shareInviteCubit.clearFeedback();
        }

        if (state.sentCount != null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invite link sent to ${state.sentCount} conversation(s)',
              ),
            ),
          );
          _shareInviteCubit.clearFeedback();
        }
      },
      builder: (context, state) {
        final sending = state.isSending;
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
                        onChanged: sending
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
              onPressed: sending ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _selected.isEmpty || sending ? null : _sendToSelected,
              child: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Send (${_selected.length})'),
            ),
          ],
        );
      },
    );
  }
}
