import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat/features/chat/chat_providers.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
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
  bool _isCheckingMembership = true;
  String? _errorMessage;
  JoinGroupInviteResult? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingMembership();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingMembership() async {
    final hint = _parseInviteToken(widget.token);
    final conversationsResult = await ref.read(
      getConversationUseCaseProvider,
    )();

    if (!mounted) {
      return;
    }

    Conversation? existingConversation;
    conversationsResult.fold((_) {}, (conversations) {
      existingConversation = _findExistingConversation(conversations, hint);
    });
    existingConversation ??= await _searchExistingConversation(hint);

    if (existingConversation != null) {
      await ref.read(joinConversationUseCaseProvider)(existingConversation!.id);
      if (!mounted) {
        return;
      }
      _openChat(existingConversation!);
      return;
    }

    setState(() {
      _isCheckingMembership = false;
    });
  }

  Future<Conversation?> _searchExistingConversation(
    ({String? conversationId, String? groupName}) hint,
  ) async {
    final query = hint.groupName?.trim();
    if (query == null || query.isEmpty) {
      return null;
    }

    final result = await ref.read(searchConversationsUseCaseProvider)(
      query: query,
      page: 1,
      limit: 20,
    );

    if (!mounted) {
      return null;
    }

    Conversation? conversation;
    result.fold((_) {}, (conversations) {
      conversation = _findExistingConversation(conversations, hint);
    });
    return conversation;
  }

  ({String? conversationId, String? groupName}) _parseInviteToken(
    String token,
  ) {
    final payload = _decodeJwtPayload(token.trim());
    if (payload == null) {
      return (conversationId: null, groupName: null);
    }

    final conversationId =
        _firstString(payload, const [
          'conversationId',
          'conversation_id',
          'groupId',
          'group_id',
          'roomId',
          'room_id',
          'cid',
        ]) ??
        _nestedString(payload, const ['conversation', 'id']) ??
        _nestedString(payload, const ['group', 'id']);
    final groupName =
        _firstString(payload, const [
          'groupName',
          'group_name',
          'conversationName',
          'conversation_name',
          'name',
        ]) ??
        _nestedString(payload, const ['conversation', 'name']) ??
        _nestedString(payload, const ['group', 'name']);

    return (conversationId: conversationId, groupName: groupName);
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final segments = token.split('.');
    if (segments.length < 2) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(segments[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      if (payload is Map) {
        return payload.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return null;
  }

  String? _firstString(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      final stringValue = value?.toString().trim();
      if (stringValue != null && stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    return null;
  }

  String? _nestedString(Map<String, dynamic> payload, List<String> path) {
    dynamic current = payload;
    for (final segment in path) {
      if (current is Map<String, dynamic>) {
        current = current[segment];
      } else if (current is Map) {
        current = current[segment];
      } else {
        return null;
      }
    }
    final stringValue = current?.toString().trim();
    return stringValue == null || stringValue.isEmpty ? null : stringValue;
  }

  Conversation? _findExistingConversation(
    List<Conversation> conversations,
    ({String? conversationId, String? groupName}) hint,
  ) {
    final token = widget.token.trim();
    final possibleIds = <String>{
      if ((hint.conversationId ?? '').trim().isNotEmpty)
        hint.conversationId!.trim(),
      if (token.isNotEmpty) token,
    };

    for (final conversation in conversations) {
      if (possibleIds.contains(conversation.id.trim())) {
        return conversation;
      }
    }

    final groupName = hint.groupName?.trim().toLowerCase();
    if (groupName == null || groupName.isEmpty) {
      return null;
    }

    final matches = conversations
        .where(
          (conversation) =>
              conversation.type.trim().toLowerCase() == 'group' &&
              conversation.name.trim().toLowerCase() == groupName,
        )
        .toList(growable: false);
    return matches.length == 1 ? matches.single : null;
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

  void _openChat(Conversation conversation) {
    final conversationId = conversation.id.trim();
    final displayName = conversation.name.trim().isEmpty
        ? 'Group'
        : conversation.name.trim();
    context.go(
      '/chat/${Uri.encodeComponent(conversationId)}/${Uri.encodeComponent(displayName)}',
      extra: {'conversationId': conversationId, 'friendName': displayName},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isCheckingMembership) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
      return [FilledButton(onPressed: _goHome, child: const Text('Go Home'))];
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
