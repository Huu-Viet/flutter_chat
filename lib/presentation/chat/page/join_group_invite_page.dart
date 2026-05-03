import 'package:flutter/material.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/join_group_invite_result.dart';
import 'package:flutter_chat/features/group_manager/group_management_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JoinGroupInvitePage extends ConsumerStatefulWidget {
  final String token;

  const JoinGroupInvitePage({super.key, required this.token});

  @override
  ConsumerState<JoinGroupInvitePage> createState() =>
      _JoinGroupInvitePageState();
}

class _JoinGroupInvitePageState extends ConsumerState<JoinGroupInvitePage> {
  final TextEditingController _messageController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  JoinGroupInviteResult? _result;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitJoinRequest() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref.read(joinGroupViaInviteUseCaseProvider)(
      token: widget.token,
      requestMessage: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = failure.message;
        });
      },
      (value) {
        setState(() {
          _isSubmitting = false;
          _result = value;
        });
      },
    );
  }

  void _goHome() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AlertDialog(
              title: Text(_buildTitle()),
              content: _buildContent(theme),
              actions: _buildActions(theme),
            ),
          ),
        ),
      ),
    );
  }

  String _buildTitle() {
    if (_result?.requiresApproval == true) {
      return 'Request Sent';
    }

    if (_result != null) {
      return 'Joined Successfully';
    }

    return 'Join Group';
  }

  Widget _buildContent(ThemeData theme) {
    if (_result?.requiresApproval == true) {
      return const Text(
        'Your request to join the group has been sent. Please wait for the approval',
      );
    }

    if (_result != null) {
      return const Text(
        'You have successfully joined the group. You can now access the group chat and interact with other members.',
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send a message to the group admins (optional):',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          enabled: !_isSubmitting,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Type your message here...',
            border: OutlineInputBorder(),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions(ThemeData theme) {
    if (_result != null) {
      return [
        FilledButton(onPressed: _goHome, child: const Text('Go Home')),
      ];
    }

    return [
      TextButton(
        onPressed: _isSubmitting ? null : _goHome,
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _isSubmitting ? null : _submitJoinRequest,
        child: _isSubmitting
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Text('Join'),
      ),
    ];
  }
}
