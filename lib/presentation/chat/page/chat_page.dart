import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/app/app_providers.dart';
import 'package:flutter_chat/core/platform_services/export.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/features/chat/export.dart';
import 'package:flutter_chat/features/friendship/domain/entities/friendship_status.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';
import 'package:flutter_chat/features/call/call_providers.dart';
import 'package:flutter_chat/l10n/app_localizations.dart';
import 'package:flutter_chat/presentation/call/blocs/in_call_bloc.dart';
import 'package:flutter_chat/presentation/call/blocs/outgoing_call_bloc.dart';
import 'package:flutter_chat/presentation/call/providers/call_bloc_provider.dart';
import 'package:flutter_chat/presentation/chat/blocs/chat_bloc.dart';
import 'package:flutter_chat/presentation/chat/chat_providers.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';
import 'package:flutter_chat/presentation/chat/widgets/active_group_call_panel.dart';
import 'package:flutter_chat/presentation/chat/widgets/blocked_composer_panel.dart';
import 'package:flutter_chat/presentation/chat/widgets/chat_messages_pane.dart';
import 'package:flutter_chat/presentation/chat/widgets/composer_context_bar.dart';
import 'package:flutter_chat/presentation/chat/widgets/group_posting_restricted_panel.dart';
import 'package:flutter_chat/presentation/chat/widgets/open_poll_panel.dart';
import 'package:flutter_chat/presentation/chat/widgets/pending_in_panel.dart';
import 'package:flutter_chat/presentation/chat/widgets/pending_out_panel.dart';
import 'package:flutter_chat/presentation/chat/widgets/stranger_panel.dart';
import 'package:flutter_chat/presentation/chat/page/direct_chat_info_page.dart';
import 'package:flutter_chat/presentation/chat/widgets/file_send_confirmation_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/forward_message_dialog.dart';
import 'package:flutter_chat/presentation/chat/page/group_management_page.dart';
import 'package:flutter_chat/presentation/chat/widgets/image_send_confirmation_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_action_dialog.dart';
import 'package:flutter_chat/presentation/chat/widgets/message_input.dart';
import 'package:flutter_chat/presentation/chat/widgets/pin_message_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String friendName;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.friendName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  static const List<String> _reactionEmojis = <String>[
    '❤️',
    '👍',
    '🤣',
    '😮',
    '😭',
    '😡',
  ];
  static const double _messageActionDialogWidth = 280;
  static const double _messageActionDialogMargin = 16;
  static const Duration _messageEditWindow = Duration(hours: 1);
  static const Duration _messageDeleteWindow = Duration(hours: 24);

  final TextEditingController _messageController = TextEditingController();
  final MediaService _mediaService = MediaService();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<RealtimeGatewayEvent>? _realtimeSubscription;
  bool? _groupAllowMemberMessageRealtime;
  DirectBlockRelation? _directBlockRelationOverride;
  ChatMessage? _replyToMessage;
  final Set<String> _explicitMentionUserIds = <String>{};
  String? _activeMentionQuery;
  final Set<String> _verifiedActiveGroupCallIds = <String>{};
  final Set<String> _verifyingActiveGroupCallIds = <String>{};
  final Set<String> _activeGroupCallCheckedConversationIds = <String>{};

  @override
  void initState() {
    super.initState();
    ref.read(chatBlocProvider).add(ChatInitialLoadEvent(widget.conversationId));
    ref.read(chatBlocProvider).add(LoadPollsEvent(widget.conversationId));
    _subscribeChatRealtimeEvents();
    _messageController.addListener(_onComposerTextChanged);
    _scrollController.addListener(() {
      _onScroll(ref.read(chatBlocProvider));
    });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _messageController.removeListener(_onComposerTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeChatRealtimeEvents() {
    final realtimeGateway = ref.read(realtimeGatewayServiceProvider);
    _realtimeSubscription = realtimeGateway.events.listen((event) {
      if (event.namespace != '/chat') {
        return;
      }

      final payload = event.payload;

      if (_isFriendshipStateEvent(event.event)) {
        debugPrint(
          '[ChatPage][FriendshipRealtime] Received ${event.event} payload=$payload',
        );
        final chatState = ref.read(chatBlocProvider).state;
        if (chatState is! ChatLoaded) {
          debugPrint(
            '[ChatPage][FriendshipRealtime] Ignored ${event.event}: chat state is not ChatLoaded',
          );
          return;
        }

        final targetUserId = _resolveDirectTargetUserId(chatState);
        if (targetUserId == null || targetUserId.isEmpty) {
          debugPrint(
            '[ChatPage][FriendshipRealtime] Ignored ${event.event}: direct target user is empty',
          );
          return;
        }

        final containsTarget = _payloadContainsUserId(payload, targetUserId);
        // For request_canceled the server may only include the canceledBy field
        // (the sender's ID), which may not match targetUserId when received on
        // the receiver's side. Since in a direct chat any cancel event is
        // relevant to exactly our two parties, we always invalidate here.
        final isCancelEvent =
            event.event == 'friendship:request_canceled' ||
            event.event == 'friendship.request_canceled';
        debugPrint(
          '[ChatPage][FriendshipRealtime] Event=${event.event} targetUserId=$targetUserId containsTarget=$containsTarget isCancelEvent=$isCancelEvent',
        );

        if (containsTarget || isCancelEvent) {
          debugPrint(
            '[ChatPage][FriendshipRealtime] Invalidating friendshipStatusProvider for $targetUserId',
          );
          final currentUserId = chatState.currentUserId?.trim() ?? '';
          final relationFromEvent = _resolveBlockRelationFromRealtimeEvent(
            eventName: event.event,
            payload: payload,
            currentUserId: currentUserId,
            targetUserId: targetUserId,
          );
          if (relationFromEvent != null && mounted) {
            setState(() {
              _directBlockRelationOverride = relationFromEvent;
            });
          }
          ref.invalidate(friendshipStatusProvider(targetUserId));
        }
        return;
      }

      if (event.event == 'group:settings_updated' ||
          event.event == 'group.settings_updated') {
        final conversationId = _extractConversationIdFromPayload(payload);
        if (conversationId != widget.conversationId) {
          return;
        }
        final allowMemberMessage = _extractAllowMemberMessageFromPayload(
          payload,
        );
        if (mounted) {
          if (allowMemberMessage != null) {
            setState(() {
              _groupAllowMemberMessageRealtime = allowMemberMessage;
            });
          }
          ref
              .read(chatBlocProvider)
              .add(ChatInitialLoadEvent(widget.conversationId));
        }
        return;
      }

      final conversationId = _extractConversationIdFromPayload(payload);
      if (conversationId != widget.conversationId) {
        return;
      }

      if (event.event == 'message:pinned' ||
          event.event == 'message:unpinned') {
        ref
            .read(chatBlocProvider)
            .add(RefreshPinnedMessagesEvent(widget.conversationId));
        return;
      }

      if (event.event != 'group:poll_created' &&
          event.event != 'group:poll_voted' &&
          event.event != 'group:poll_closed') {
        return;
      }

      ref.read(chatBlocProvider).add(LoadPollsEvent(widget.conversationId));
    });
  }

  bool _isFriendshipStateEvent(String eventName) {
    return eventName == 'friendship:request_sent' ||
        eventName == 'friendship:request_received' ||
        eventName == 'friendship:request_accepted' ||
        eventName == 'friendship:request_rejected' ||
        eventName == 'friendship:removed' ||
        eventName == 'friendship:blocked' ||
        eventName == 'friendship:unblocked' ||
        eventName == 'friendship.request_sent' ||
        eventName == 'friendship.request_received' ||
        eventName == 'friendship.request_accepted' ||
        eventName == 'friendship.request_rejected' ||
        eventName == 'friendship.removed' ||
        eventName == 'friendship.blocked' ||
        eventName == 'friendship.unblocked' ||
        eventName == 'friendship:request_canceled' ||
        eventName == 'friendship.request_canceled';
  }

  bool _payloadContainsUserId(dynamic payload, String userId) {
    if (userId.trim().isEmpty) {
      return false;
    }
    if (payload is! Map) {
      debugPrint(
        '[ChatPage][FriendshipRealtime] Payload is not a map: ${payload.runtimeType}',
      );
      return false;
    }

    final normalizedRoot = payload.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    bool containsInMap(Map<String, dynamic> normalized) {
      final userIds = normalized['userIds'];
      if (userIds is List) {
        for (final item in userIds) {
          if (item?.toString().trim() == userId) {
            return true;
          }
        }
      }

      const candidateKeys = <String>[
        'requesterId',
        'targetUserId',
        'fromUserId',
        'toUserId',
        'acceptedBy',
        'rejectedBy',
        'removedBy',
        'blocker',
        'blocked',
        'unblocker',
        'unblocked',
        'userId',
        'canceledBy',
      ];

      for (final key in candidateKeys) {
        final value = normalized[key];
        if (value != null && value.toString().trim() == userId) {
          return true;
        }
      }

      return false;
    }

    if (containsInMap(normalizedRoot)) {
      return true;
    }

    final nestedData = normalizedRoot['data'];
    if (nestedData is Map) {
      final normalizedData = nestedData.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      if (containsInMap(normalizedData)) {
        return true;
      }
    }

    debugPrint(
      '[ChatPage][FriendshipRealtime] Payload does not include target userId=$userId; root=$normalizedRoot',
    );

    return false;
  }

  DirectBlockRelation _deriveBlockRelationFromStatus(
    FriendshipStatus? status,
  ) {
    if (status == null || !status.isBlocked) {
      return DirectBlockRelation.none;
    }

    if (status.isBlockedByMe) {
      return DirectBlockRelation.blockedByMe;
    }

    if (status.isBlockedByTarget) {
      return DirectBlockRelation.blockedByPeer;
    }

    return DirectBlockRelation.blockedUnknown;
  }

  Map<String, dynamic>? _toNormalizedMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  String? _extractIdFromPayload(dynamic payload, List<String> keys) {
    final root = _toNormalizedMap(payload);
    if (root == null) {
      return null;
    }

    final nested = _toNormalizedMap(root['data']);
    final candidates = <Map<String, dynamic>>[root, if (nested != null) nested];

    for (final map in candidates) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) {
          continue;
        }
        final normalized = value.toString().trim();
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    }

    return null;
  }

  DirectBlockRelation? _resolveBlockRelationFromRealtimeEvent({
    required String eventName,
    required dynamic payload,
    required String currentUserId,
    required String targetUserId,
  }) {
    if (currentUserId.isEmpty || targetUserId.isEmpty) {
      return null;
    }

    bool matchPair(String? first, String? second) {
      if (first == null || second == null) {
        return false;
      }
      return (first == currentUserId && second == targetUserId) ||
          (first == targetUserId && second == currentUserId);
    }

    if (eventName == 'friendship:unblocked' ||
        eventName == 'friendship.unblocked') {
      final unblocker = _extractIdFromPayload(payload, const [
        'unblocker',
        'unblockerId',
      ]);
      final unblocked = _extractIdFromPayload(payload, const [
        'unblocked',
        'unblockedId',
      ]);
      if (matchPair(unblocker, unblocked)) {
        return DirectBlockRelation.none;
      }
      return null;
    }

    if (eventName == 'friendship:blocked' ||
        eventName == 'friendship.blocked') {
      final blocker = _extractIdFromPayload(payload, const [
        'blocker',
        'blockerId',
      ]);
      final blocked = _extractIdFromPayload(payload, const [
        'blocked',
        'blockedId',
      ]);
      if (blocker == currentUserId && blocked == targetUserId) {
        return DirectBlockRelation.blockedByMe;
      }
      if (blocker == targetUserId && blocked == currentUserId) {
        return DirectBlockRelation.blockedByPeer;
      }
      if (matchPair(blocker, blocked)) {
        return DirectBlockRelation.blockedUnknown;
      }
    }

    return null;
  }

  bool? _extractAllowMemberMessageFromPayload(dynamic payload) {
    Map<String, dynamic>? normalize(dynamic value) {
      if (value is! Map) {
        return null;
      }
      return value.map((key, val) => MapEntry(key.toString(), val));
    }

    final payloadMap = normalize(payload);
    if (payloadMap == null) {
      return null;
    }

    final current = normalize(payloadMap['data']) ?? payloadMap;

    final changes = normalize(current['changes']);
    final changedValue = changes?['allowMemberMessage'];
    if (changedValue is bool) {
      return changedValue;
    }

    final directValue = current['allowMemberMessage'];
    if (directValue is bool) {
      return directValue;
    }

    return null;
  }

  String? _extractConversationIdFromPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final direct = payload['conversationId']?.toString().trim();
      if (direct != null && direct.isNotEmpty) {
        return direct;
      }

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final nested = data['conversationId']?.toString().trim();
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    if (payload is Map) {
      final normalized = payload.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final direct = normalized['conversationId']?.toString().trim();
      if (direct != null && direct.isNotEmpty) {
        return direct;
      }

      final data = normalized['data'];
      if (data is Map) {
        final nested = data.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        final nestedConversationId = nested['conversationId']
            ?.toString()
            .trim();
        if (nestedConversationId != null && nestedConversationId.isNotEmpty) {
          return nestedConversationId;
        }
      }
    }

    return null;
  }

  void _onComposerTextChanged() {
    final nextQuery = _extractActiveMentionQuery();
    if (nextQuery == _activeMentionQuery) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _activeMentionQuery = nextQuery;
    });
  }

  bool _canEditMessage(ChatMessage message) {
    if (message.isDeleted ||
        !message.isSentByMe ||
        message is! TextChatMessage) {
      return false;
    }

    if (message.text.trim().isEmpty) {
      return false;
    }

    return DateTime.now().difference(message.timestamp) <= _messageEditWindow;
  }

  bool _canDeleteMessage(ChatMessage message) {
    if (message.isDeleted || !message.isSentByMe) {
      return false;
    }
    return DateTime.now().difference(message.timestamp) <= _messageDeleteWindow;
  }

  bool _canReactToMessage(ChatMessage message) {
    if (message is SystemChatMessage || message is CallHistoryChatMessage) {
      return false;
    }

    if (message.isDeleted) {
      return false;
    }

    final isUploading = switch (message) {
      ImageChatMessage(:final isUploading) => isUploading,
      VideoChatMessage(:final isUploading) => isUploading,
      AudioChatMessage(:final isUploading) => isUploading,
      FileChatMessage(:final isUploading) => isUploading,
      _ => false,
    };

    final isResolvingImage = switch (message) {
      ImageChatMessage(:final isResolvingImage) => isResolvingImage,
      VideoChatMessage(:final isResolvingImage) => isResolvingImage,
      _ => false,
    };

    if (isUploading || isResolvingImage) {
      return false;
    }

    final messageId = _resolveMessageIdForAction(message);
    return messageId != null && messageId.isNotEmpty;
  }

  String? _resolveMessageIdForAction(ChatMessage message) {
    final serverId = message.serverId?.trim();
    if (serverId != null && serverId.isNotEmpty) {
      return serverId;
    }

    final localId = message.localId?.trim();
    if (localId != null && localId.isNotEmpty) {
      return localId;
    }

    return null;
  }

  String? _mapChatErrorMessage(String message, AppLocalizations l10n) {
    if (message.contains('STRANGER_NOT_ALLOWED')) {
      return 'This user does not allow messages from people they don\'t know.';
    }
    if (message.contains('FORBIDDEN_EDIT_WINDOW_EXPIRED')) {
      return l10n.error_edit_time_limited;
    }
    if (message.contains('FORBIDDEN_NOT_OWNER')) {
      return l10n.error_cannot_edit_message;
    }
    if (message.contains('MESSAGE_NOT_FOUND')) {
      return l10n.error_message_not_found;
    }
    return null;
  }

  String _friendshipSuccessMessage(
    FriendshipActionType actionType,
    AppLocalizations l10n,
  ) {
    switch (actionType) {
      case FriendshipActionType.sendRequest:
        return l10n.success_friend_request_sent;
      case FriendshipActionType.acceptRequest:
        return l10n.success_friend_request_accepted;
      case FriendshipActionType.cancelRequest:
        return l10n.warning_friend_request_cancelled;
      case FriendshipActionType.block:
        return 'Blocked successfully';
      case FriendshipActionType.unblock:
        return 'Unblocked successfully';
    }
  }

  String? _resolveDirectTargetUserId(ChatLoaded state) {
    final currentUserId = state.currentUserId?.trim() ?? '';
    final participants =
        state.conversation?.participants ?? const <ConversationParticipant>[];
    for (final participant in participants) {
      final userId = participant.userId.trim();
      if (userId.isNotEmpty && userId != currentUserId) {
        return userId;
      }
    }
    return null;
  }

  ConversationParticipant? _resolveDirectTargetParticipant(ChatLoaded state) {
    final targetUserId = _resolveDirectTargetUserId(state);
    if (targetUserId == null) {
      return null;
    }

    final participants =
        state.conversation?.participants ?? const <ConversationParticipant>[];
    for (final participant in participants) {
      if (participant.userId.trim() == targetUserId) {
        return participant;
      }
    }
    return null;
  }

  String _resolveCurrentUserRole(ChatLoaded state) {
    final currentUserId = state.currentUserId?.trim() ?? '';
    if (currentUserId.isEmpty) {
      return 'member';
    }

    final participants =
        state.conversation?.participants ?? const <ConversationParticipant>[];
    for (final participant in participants) {
      if (participant.userId.trim() == currentUserId) {
        final role = participant.role.trim().toLowerCase();
        if (role.isNotEmpty) {
          return role;
        }
        break;
      }
    }

    return 'member';
  }

  bool _isGroupMemberPostingRestricted(ChatLoaded state) {
    final conversation = state.conversation;
    if (conversation == null ||
        conversation.type.trim().toLowerCase() != 'group') {
      return false;
    }

    // Use realtime override if available, else fall back to conversation data.
    final realtimeVal = _groupAllowMemberMessageRealtime;
    final conversationVal = conversation.allowMemberMessage;
    final allowMemberMessage = realtimeVal ?? conversationVal;

    if (allowMemberMessage) {
      return false;
    }

    final myRole = _resolveCurrentUserRole(state);
    return myRole == 'member';
  }

  bool _isAdminOrOwnerRole(String role) {
    final normalized = role.trim().toLowerCase();
    return normalized == 'owner' || normalized == 'admin';
  }

  Future<void> _openConversationOptions(ChatLoaded state) async {
    final conversation = state.conversation;
    if (conversation == null) {
      return;
    }

    final normalizedType = conversation.type.trim().toLowerCase();
    if (normalizedType == 'group') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GroupManagementPage(
            conversation: conversation,
            currentUserId: state.currentUserId ?? '',
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      ref
          .read(chatBlocProvider)
          .add(ChatInitialLoadEvent(widget.conversationId));
      ref.read(chatBlocProvider).add(LoadPollsEvent(widget.conversationId));
      return;
    }

    if (normalizedType != 'direct') {
      return;
    }

    final targetParticipant = _resolveDirectTargetParticipant(state);
    final targetUserId = targetParticipant?.userId.trim() ?? '';
    if (targetUserId.isEmpty) {
      return;
    }

    final title =
        targetParticipant != null &&
            targetParticipant.displayName.trim().isNotEmpty
        ? targetParticipant.displayName
        : (targetParticipant?.username.trim().isNotEmpty == true
              ? targetParticipant!.username
              : widget.friendName);

    final status = ref.read(friendshipStatusProvider(targetUserId)).valueOrNull;
    final blockRelation =
        _directBlockRelationOverride ?? _deriveBlockRelationFromStatus(status);

    final deletedConversation = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DirectChatInfoPage(
          conversation: conversation,
          targetUserId: targetUserId,
          title: title,
          avatarUrl: targetParticipant?.avatarUrl,
          initialBlockedByTarget:
              blockRelation == DirectBlockRelation.blockedByPeer,
          initialBlockedByMe: blockRelation == DirectBlockRelation.blockedByMe,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (deletedConversation == true) {
      context.pop();
      return;
    }

    ref.read(chatBlocProvider).add(ChatInitialLoadEvent(widget.conversationId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatBloc = ref.read(chatBlocProvider);
    final outgoingCallBloc = ref.watch(outgoingCallBlocProvider);

    return SafeArea(
      top: false,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ChatBloc>.value(value: chatBloc),
          BlocProvider<OutgoingCallBloc>.value(value: outgoingCallBloc),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<OutgoingCallBloc, OutgoingCallState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                final messenger = ScaffoldMessenger.of(context);

                //failure
                if (state.status == OutgoingCallStatus.failure) {
                  final rawMessage = state.errorMessage ?? '';
                  final message = rawMessage.contains('STRANGER_NOT_ALLOWED')
                      ? 'This user does not allow calls from people they don\'t know.'
                      : rawMessage.trim().isNotEmpty
                      ? rawMessage
                      : null;

                  if (message != null) {
                    messenger.showSnackBar(SnackBar(content: Text(message)));
                  }
                  context.read<OutgoingCallBloc>().add(
                    const OutgoingCallStatusConsumed(),
                  );
                }

                /// SUCCESS (EMIT SIGNAL,)
                if (state.status == OutgoingCallStatus.success &&
                    state.call != null) {
                  ref
                      .read(inCallBlocProvider)
                      .add(
                        InCallOutgoingStarted(
                          state.call!,
                          isGroupCall: state.isGroupCall,
                        ),
                      );
                  context.push(
                    '/in-call?conversationId=${widget.conversationId}&roomName=${widget.friendName}',
                  );

                  context.read<OutgoingCallBloc>().add(
                    const OutgoingCallStatusConsumed(),
                  );
                }
              },
            ),
          ],
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatError) {
                final mappedMessage = _mapChatErrorMessage(state.message, l10n);
                final fallbackMessage = state.message.trim().isNotEmpty
                    ? state.message
                    : 'Chat load failed';
                final message = mappedMessage?.trim().isNotEmpty == true
                    ? mappedMessage!
                    : fallbackMessage;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }

              // Clear jump highlight after 2 seconds
              if (state is ChatLoaded && state.jumpHighlightMessageId != null) {
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    ref
                        .read(chatBlocProvider)
                        .add(const ClearJumpHighlightEvent());
                  }
                });
              }

              if (state is ChatLoaded &&
                  state.conversation?.type.trim().toLowerCase() == 'group') {
                _checkActiveGroupCallForConversation(state.conversation!);
              }

              if (state is ChatLoaded && state.friendshipActionFeedback != null) {
                final feedback = state.friendshipActionFeedback!;
                final message = feedback.isSuccess
                    ? _friendshipSuccessMessage(feedback.actionType, l10n)
                    : _mapChatErrorMessage(feedback.failureMessage ?? '', l10n) ??
                          feedback.failureMessage ??
                          'Action failed';

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));

                if (feedback.isSuccess) {
                  ref.invalidate(friendshipStatusProvider(feedback.targetUserId));
                }

                ref
                    .read(chatBlocProvider)
                    .add(const ConsumeFriendshipActionFeedbackEvent());
              }
            },
            builder: (context, state) {
              final isGroupConversation =
                  state is ChatLoaded &&
                  state.conversation != null &&
                  state.conversation?.type.trim().toLowerCase() == 'group';
              final directTargetUserId = state is ChatLoaded
                  ? _resolveDirectTargetUserId(state)
                  : null;
              final directFriendshipStatus = directTargetUserId != null
                  ? ref.watch(friendshipStatusProvider(directTargetUserId))
                  : null;
              final isFriendshipActionLoading =
                  state is ChatLoaded &&
                  directTargetUserId != null &&
                  state.friendshipActionInProgressUserIds.contains(
                    directTargetUserId,
                  );
              final directBlockRelation =
                  state is ChatLoaded &&
                      state.conversation?.type.trim().toLowerCase() == 'direct'
                  ? (_directBlockRelationOverride ??
                        _deriveBlockRelationFromStatus(
                          directFriendshipStatus?.valueOrNull,
                        ))
                  : DirectBlockRelation.none;
              final isDirectChatBlocked =
                  directBlockRelation != DirectBlockRelation.none;
              final isGroupPostingRestricted =
                  state is ChatLoaded && _isGroupMemberPostingRestricted(state);
              final hideComposer =
                  isDirectChatBlocked || isGroupPostingRestricted;
              final appBarTitle = isGroupConversation
                  ? (() {
                      final name = state.conversation?.name.trim() ?? '';
                      return name.isNotEmpty ? name : widget.friendName;
                    })()
                  : widget.friendName;
              final activeGroupCall = isGroupConversation
                  ? ref.watch(
                      activeGroupCallsProvider.select(
                        (calls) => calls[widget.conversationId],
                      ),
                    )
                  : null;

              if (isGroupConversation && activeGroupCall != null) {
                _verifyActiveGroupCallState(activeGroupCall);
              }

              return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appBarTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                        state is ChatLoaded &&
                                state.conversation != null &&
                                state.conversation?.type == 'group'
                            ? Text(
                                '${state.conversation?.memberCount ?? 0} members',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surfaceBright,
                  actions: [
                    BlocBuilder<OutgoingCallBloc, OutgoingCallState>(
                      builder: (context, callState) {
                        return Row(
                          children: [
                            IconButton(
                              tooltip: 'Call',
                              onPressed:
                                  callState.isStarting ||
                                      (isGroupConversation &&
                                          activeGroupCall != null)
                                  ? null
                                  : () => _startOutgoingCall(context, state),
                              icon: callState.isStarting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.call_outlined),
                            ),

                            IconButton(
                              tooltip: 'Options',
                              onPressed: () async {
                                if (state is! ChatLoaded ||
                                    state.conversation == null) {
                                  return;
                                }
                                await _openConversationOptions(state);
                              },
                              icon: const Icon(Icons.list_outlined),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    if (state is ChatLoaded && state.pinnedMessages.isNotEmpty)
                      PinMessagePanel(
                        pinnedMessages: state.pinnedMessages,
                        onTapItem: (pinMessage) {
                          ref
                              .read(chatBlocProvider)
                              .add(
                                JumpToMessageEvent(
                                  conversationId: widget.conversationId,
                                  messageId: pinMessage.messageId,
                                ),
                              );
                        },
                        onUnpin: (pinMessage) {
                          ref
                              .read(chatBlocProvider)
                              .add(
                                UnpinMessageEvent(
                                  messageId: pinMessage.messageId,
                                  conversationId: widget.conversationId,
                                ),
                              );
                        },
                      ),

                    if (state is ChatLoaded &&
                        state.conversation?.type.trim().toLowerCase() ==
                            'direct' &&
                        directTargetUserId != null) ...[
                      if (directFriendshipStatus?.valueOrNull?.isNone == true)
                        StrangerPanel(
                          targetUserId: directTargetUserId,
                          isSubmitting: isFriendshipActionLoading,
                          onAddFriend: () => chatBloc.add(
                            SendFriendRequestEvent(directTargetUserId),
                          ),
                        ),
                      if (directFriendshipStatus?.valueOrNull?.isPendingIn ==
                          true)
                        PendingInPanel(
                          targetUserId: directTargetUserId,
                          isSubmitting: isFriendshipActionLoading,
                          onAcceptRequest: () => chatBloc.add(
                            AcceptFriendRequestEvent(directTargetUserId),
                          ),
                        ),
                      if (directFriendshipStatus?.valueOrNull?.isPendingOut ==
                          true)
                        PendingOutPanel(
                          targetUserId: directTargetUserId,
                          isSubmitting: isFriendshipActionLoading,
                          onCancelRequest: () => chatBloc.add(
                            CancelFriendRequestEvent(directTargetUserId),
                          ),
                        ),
                    ],

                    if (state is ChatLoaded)
                      OpenPollPanel(pollMessages: state.pollMessages),
                    if (isGroupConversation &&
                        activeGroupCall != null &&
                        _verifiedActiveGroupCallIds.contains(
                          activeGroupCall.call.id.trim(),
                        ))
                      ActiveGroupCallPanel(
                        activeCall: activeGroupCall,
                        conversationId: widget.conversationId,
                        roomName: appBarTitle,
                        onRejoin: () {
                          final call = activeGroupCall.call;
                          context.read<InCallBloc>().add(
                            InCallRejoinRequested(call, roomName: appBarTitle),
                          );
                          final route = Uri(
                            path: '/in-call',
                            queryParameters: {
                              'conversationId': widget.conversationId,
                              'roomName': appBarTitle,
                            },
                          ).toString();
                          context.push(route);
                        },
                      ),

                    Expanded(
                      child: Stack(
                        children: [
                          if (state is ChatInitial || state is ChatLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (state is ChatError)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline, size: 28),
                                    const SizedBox(height: 8),
                                    Text(
                                      state.message.trim().isNotEmpty
                                          ? state.message
                                          : 'Failed to load chat',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton.icon(
                                      onPressed: () => chatBloc.add(
                                        ChatInitialLoadEvent(
                                          widget.conversationId,
                                        ),
                                      ),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (state is ChatLoaded)
                            ChatMessagesPane(
                              state: state,
                              conversationId: widget.conversationId,
                              deletedMessageText: l10n.chat_deleted_message,
                              scrollController: _scrollController,
                              canManagePoll: _isAdminOrOwnerRole(
                                _resolveCurrentUserRole(state),
                              ),
                              canReactToMessage: _canReactToMessage,
                              onReactPressed: (msg, emoji) =>
                                  _handleReactionSelection(msg, emoji),
                              onReactionTapToRemove: (msg, emoji) =>
                                  _handleReactionTapToRemove(msg, emoji),
                              onMessageLongPress: (msg, offset) =>
                                  _showMessageActions(
                                    context,
                                    msg,
                                    l10n,
                                    anchor: offset,
                                  ),
                              onOpenFile: (mediaId, fileName) =>
                                  chatBloc.add(
                                    GetFileDownloadUrlEvent(
                                      mediaId: mediaId,
                                      fileName: fileName,
                                    ),
                                  ),
                              onReplyPreviewTap: (
                                replyMessageId,
                                messages,
                              ) =>
                                  _scrollToRepliedMessage(
                                    replyMessageId: replyMessageId,
                                    displayMessages: messages,
                                  ),
                            )
                          else
                            const SizedBox.shrink(),
                          // "↓ N new messages" badge when jumped
                          if (state is ChatLoaded &&
                              state.isJumped &&
                              state.pendingCount > 0)
                            Positioned(
                              bottom: 12,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => chatBloc.add(
                                  ReturnToLiveEvent(widget.conversationId),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${state.pendingCount} new',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // is typing badge
                    if (state is ChatLoaded &&
                        state.typingUserIds.isNotEmpty &&
                        _messageController.text.trim().isEmpty) ...[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          l10n.typing_indicator,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                    if (state is ChatLoaded && !hideComposer)
                      ComposerContextBar(
                        replyToMessage: _replyToMessage,
                        mentionSuggestions: _buildMentionSuggestions(
                          participants:
                              state.conversation?.participants ?? const [],
                          currentUserId: state.currentUserId,
                        ),
                        onClearReply: () =>
                            setState(() => _replyToMessage = null),
                      ),
                    if (isDirectChatBlocked)
                      BlockedComposerPanel(relation: directBlockRelation)
                    else if (isGroupPostingRestricted)
                      const GroupPostingRestrictedPanel()
                    else
                      MessageInput(
                        controller: _messageController,
                        onSendMessage: () => _sendMessage(state),
                        onPickImage: _pickImage,
                        onPickVideo: _pickVideo,
                        onPickMultipleImages: _pickMultipleImages,
                        onPickFile: _pickFile,
                        onEmojiSelected: (emoji) {
                          _messageController.text += emoji;
                        },
                        onStickerSelected: _sendSticker,
                        onTypingStatusChanged: (isTyping) {
                          chatBloc.add(
                            EmitTypingEvent(widget.conversationId, isTyping),
                          );
                        },
                        onSendRecord: _sendAudio,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _startOutgoingCall(BuildContext context, ChatState state) {
    if (state is! ChatLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation is still loading.')),
      );
      return;
    }

    final callerId = state.currentUserId?.trim();
    if (callerId == null || callerId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Missing current user')));
      return;
    }

    final calleeIds = _resolveOutgoingCallCalleeIds(state, callerId);

    if (calleeIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Missing callee')));
      return;
    }

    context.read<OutgoingCallBloc>().add(
      OutgoingCallRequested(
        conversationId: widget.conversationId,
        callerId: callerId,
        calleeIds: calleeIds,
      ),
    );
  }

  void _verifyActiveGroupCallState(ActiveGroupCallState activeCall) {
    final callId = activeCall.call.id.trim();
    if (callId.isEmpty ||
        _verifiedActiveGroupCallIds.contains(callId) ||
        _verifyingActiveGroupCallIds.contains(callId)) {
      return;
    }

    _verifyingActiveGroupCallIds.add(callId);
    Future<void>(() async {
      final result = await ref
          .read(callRepositoryProvider)
          .fetchSingleCallRecord(callId);
      if (!mounted) return;

      _verifyingActiveGroupCallIds.remove(callId);
      result.fold((_) => _removeActiveGroupCall(callId), (call) {
        final status = call.status.trim().toUpperCase();
        final participantCount = call.participants.isNotEmpty
            ? call.participants.length
            : activeCall.participantCount;
        if (status != 'ACTIVE') {
          _removeActiveGroupCall(callId);
          return;
        }

        final conversationId = call.conversationId.trim().isNotEmpty
            ? call.conversationId.trim()
            : widget.conversationId.trim();
        if (conversationId.isNotEmpty) {
          final previous = ref.read(activeGroupCallsProvider);
          ref.read(activeGroupCallsProvider.notifier).state = {
            ...previous,
            conversationId: ActiveGroupCallState(
              call: call,
              participantCount: participantCount,
            ),
          };
        }

        if (mounted) {
          setState(() {
            _verifiedActiveGroupCallIds.add(callId);
          });
        }
      });
    });
  }

  void _checkActiveGroupCallForConversation(Conversation conversation) {
    final conversationId = conversation.id.trim().isNotEmpty
        ? conversation.id.trim()
        : widget.conversationId.trim();
    if (conversationId.isEmpty ||
        _activeGroupCallCheckedConversationIds.contains(conversationId)) {
      return;
    }

    _activeGroupCallCheckedConversationIds.add(conversationId);
    Future<void>(() async {
      final result = await ref
          .read(callRepositoryProvider)
          .fetchCallRecords(conversationId, 1, 10);
      if (!mounted) return;

      result.fold(
        (failure) {
          debugPrint(
            '[ChatPage] active group call check failed: ${failure.message}',
          );
          _activeGroupCallCheckedConversationIds.remove(conversationId);
        },
        (calls) {
          final activeCalls = calls.where(
            (call) => call.status.trim().toUpperCase() == 'ACTIVE',
          );
          if (activeCalls.isEmpty) {
            return;
          }

          final call = activeCalls.reduce((a, b) {
            final aTime = a.startedAt.isAfter(a.createdAt)
                ? a.startedAt
                : a.createdAt;
            final bTime = b.startedAt.isAfter(b.createdAt)
                ? b.startedAt
                : b.createdAt;
            return aTime.isAfter(bTime) ? a : b;
          });
          final participantCount = call.participants.isNotEmpty
              ? call.participants.length
              : conversation.memberCount;
          final callId = call.id.trim();
          if (callId.isEmpty) {
            return;
          }

          final activeConversationId = call.conversationId.trim().isNotEmpty
              ? call.conversationId.trim()
              : conversationId;
          final previous = ref.read(activeGroupCallsProvider);
          ref.read(activeGroupCallsProvider.notifier).state = {
            ...previous,
            activeConversationId: ActiveGroupCallState(
              call: call,
              participantCount: participantCount,
            ),
          };

          setState(() {
            _verifiedActiveGroupCallIds.add(callId);
          });
        },
      );
    });
  }

  void _removeActiveGroupCall(String callId) {
    final normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) return;
    final previous = ref.read(activeGroupCallsProvider);
    final next = Map<String, ActiveGroupCallState>.from(previous)
      ..removeWhere(
        (_, activeCall) => activeCall.call.id.trim() == normalizedCallId,
      );
    if (next.length != previous.length) {
      ref.read(activeGroupCallsProvider.notifier).state = next;
    }
    if (mounted) {
      setState(() {
        _verifiedActiveGroupCallIds.remove(normalizedCallId);
      });
    }
  }

  List<String> _resolveOutgoingCallCalleeIds(
    ChatLoaded state,
    String callerId,
  ) {
    final participants =
        state.conversation?.participants ?? const <ConversationParticipant>[];
    final isGroupConversation =
        state.conversation?.type.trim().toLowerCase() == 'group';
    if (isGroupConversation) {
      final activeCalleeIds = participants
          .map((participant) => participant.userId.trim())
          .where((userId) => userId.isNotEmpty && userId != callerId)
          .toSet()
          .toList();
      return activeCalleeIds;
    }

    for (final participant in participants) {
      final userId = participant.userId.trim();
      if (userId.isNotEmpty && userId != callerId && participant.isActive) {
        return [userId];
      }
    }

    for (final participant in participants) {
      final userId = participant.userId.trim();
      if (userId.isNotEmpty && userId != callerId) {
        return [userId];
      }
    }

    return const [];
  }

  void _sendMessage(ChatState state) {
    if (state is ChatLoaded && _isGroupMemberPostingRestricted(state)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Only admins can send messages in this group right now.',
          ),
        ),
      );
      return;
    }

    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final replyToMessageId = _replyToMessage == null
        ? null
        : _resolveMessageIdForAction(_replyToMessage!);
    final mentions = state is ChatLoaded
        ? _resolveMentionIds(state, content)
        : const <String>[];

    ref
        .read(chatBlocProvider)
        .add(
          SendTextEvent(
            conversationId: widget.conversationId,
            content: content,
            replyToMessageId: replyToMessageId,
            mentions: mentions,
          ),
        );
    _messageController.clear();
    setState(() {
      _replyToMessage = null;
      _explicitMentionUserIds.clear();
      _activeMentionQuery = null;
    });
  }

  void _insertMentionToken(String token) {
    final current = _messageController.text;
    final next = current.isEmpty ? token : '$current$token';
    _messageController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  String? _extractActiveMentionQuery() {
    final value = _messageController.value;
    final text = value.text;
    final cursor = value.selection.baseOffset;
    if (cursor < 0 || cursor > text.length) {
      return null;
    }

    final prefix = text.substring(0, cursor);
    final match = RegExp(r'(^|\s)@([^\s@]*)$').firstMatch(prefix);
    if (match == null) {
      return null;
    }

    final query = (match.group(2) ?? '').trim();
    return query;
  }

  List<Widget> _buildMentionSuggestions({
    required List<ConversationParticipant> participants,
    required String? currentUserId,
  }) {
    final query = _activeMentionQuery;
    if (query == null) {
      return const <Widget>[];
    }

    final q = query.toLowerCase();
    final widgets = <Widget>[];

    // Show @all option when query is empty or partially matches 'all'
    if ('all'.startsWith(q)) {
      widgets.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.groups, size: 18),
          title: const Text('@All', maxLines: 1),
          subtitle: const Text('Mention everyone', maxLines: 1),
          onTap: () => _applyAllMention(),
        ),
      );
    }

    final memberSuggestions = participants
        .where(
          (participant) =>
              participant.userId.trim() != (currentUserId?.trim() ?? ''),
        )
        .where((participant) {
          final username = participant.username.trim().toLowerCase();
          final displayName = participant.displayName.trim().toLowerCase();
          if (q.isEmpty) return true;
          return username.contains(q) || displayName.contains(q);
        })
        .toList(growable: false);

    for (final participant in memberSuggestions) {
      final displayName = participant.displayName.trim().isNotEmpty
          ? participant.displayName.trim()
          : participant.username.trim();
      widgets.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.alternate_email, size: 18),
          title: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '@${participant.username}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _applyMentionSuggestion(participant),
        ),
      );
    }

    return widgets;
  }

  void _applyAllMention() {
    final value = _messageController.value;
    final text = value.text;
    final cursor = value.selection.baseOffset;
    final safeCursor = (cursor < 0 || cursor > text.length)
        ? text.length
        : cursor;

    final prefix = text.substring(0, safeCursor);
    final suffix = text.substring(safeCursor);
    final match = RegExp(r'(^|\s)@([^\s@]*)$').firstMatch(prefix);

    final String rebuiltPrefix;
    if (match != null) {
      final separator = match.group(1) ?? '';
      final start = match.start + separator.length;
      rebuiltPrefix = '${prefix.substring(0, start)}@All ';
    } else {
      rebuiltPrefix = '$prefix@All ';
    }

    final rebuiltText = '$rebuiltPrefix$suffix';
    _messageController.value = TextEditingValue(
      text: rebuiltText,
      selection: TextSelection.collapsed(offset: rebuiltPrefix.length),
    );

    setState(() => _activeMentionQuery = null);
  }

  void _applyMentionSuggestion(ConversationParticipant participant) {
    final value = _messageController.value;
    final text = value.text;
    final cursor = value.selection.baseOffset;
    final safeCursor = (cursor < 0 || cursor > text.length)
        ? text.length
        : cursor;

    final prefix = text.substring(0, safeCursor);
    final suffix = text.substring(safeCursor);
    final match = RegExp(r'(^|\s)@([^\s@]*)$').firstMatch(prefix);
    if (match == null) {
      _insertMentionToken('@${participant.username} ');
      setState(() {
        _explicitMentionUserIds.add(participant.userId.trim());
        _activeMentionQuery = null;
      });
      return;
    }

    final separator = match.group(1) ?? '';
    final start = match.start + separator.length;
    final rebuiltPrefix =
        '${prefix.substring(0, start)}@${participant.username} ';
    final rebuiltText = '$rebuiltPrefix$suffix';

    _messageController.value = TextEditingValue(
      text: rebuiltText,
      selection: TextSelection.collapsed(offset: rebuiltPrefix.length),
    );

    setState(() {
      _explicitMentionUserIds.add(participant.userId.trim());
      _activeMentionQuery = null;
    });
  }

  List<String> _resolveMentionIds(ChatLoaded state, String content) {
    final participants =
        state.conversation?.participants ?? const <ConversationParticipant>[];
    if (participants.isEmpty) return const <String>[];

    final currentUserId = state.currentUserId?.trim();
    final ids = <String>{..._explicitMentionUserIds};
    final normalizedContent = content.toLowerCase();

    for (final participant in participants) {
      final userId = participant.userId.trim();
      if (userId.isEmpty || userId == currentUserId) {
        continue;
      }

      final username = participant.username.trim().toLowerCase();
      if (username.isNotEmpty && normalizedContent.contains('@$username')) {
        ids.add(userId);
      }
    }

    final hasAllTag = RegExp(
      r'(^|\s)@all(\s|$)',
      caseSensitive: false,
    ).hasMatch(content);
    if (hasAllTag) {
      for (final participant in participants) {
        final userId = participant.userId.trim();
        if (userId.isEmpty || userId == currentUserId) {
          continue;
        }
        if (participant.isActive) {
          ids.add(userId);
        }
      }
    }

    return ids.toList(growable: false);
  }

  void _scrollToRepliedMessage({
    required String replyMessageId,
    required List<ChatMessage> displayMessages,
  }) {
    final normalizedReplyId = replyMessageId.trim();
    if (normalizedReplyId.isEmpty) {
      return;
    }

    final target = displayMessages
        .where((message) {
          final serverId = message.serverId?.trim();
          final localId = message.localId?.trim();
          return serverId == normalizedReplyId || localId == normalizedReplyId;
        })
        .toList(growable: false);

    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Original message is not in current viewport'),
        ),
      );
      return;
    }

    final targetIndex = displayMessages.indexOf(target.first);
    if (targetIndex < 0) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    final max = _scrollController.position.maxScrollExtent;
    final ratio = displayMessages.length <= 1
        ? 0.0
        : targetIndex / (displayMessages.length - 1);
    final targetOffset = max * (1 - ratio);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, max),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _sendSticker(StickerItem sticker) {
    final stickerUrl = sticker.url.trim();
    if (stickerUrl.isEmpty) {
      return;
    }

    ref
        .read(chatBlocProvider)
        .add(
          SendStickerEvent(
            conversationId: widget.conversationId,
            stickerId: sticker.id,
            stickerUrl: stickerUrl,
          ),
        );
  }

  void _sendAudio(String filePath, int durationSeconds, List<double> waveform) {
    if (filePath.trim().isEmpty) {
      return;
    }

    ref
        .read(chatBlocProvider)
        .add(
          SendAudioEvent(
            conversationId: widget.conversationId,
            audioPath: filePath,
            durationMs: durationSeconds * 1000,
            waveform: waveform,
          ),
        );
  }

  Future<void> _pickImage() async {
    try {
      final File? image = await _mediaService.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        if (!mounted) return;
        final isConfirmed = await showImageSendConfirmationDialog(
          context,
          image,
        );
        if (!isConfirmed || !mounted) {
          return;
        }

        final imageSize = await image.length();
        if (!mounted) {
          return;
        }

        ref
            .read(chatBlocProvider)
            .add(
              SendImageEvent(
                conversationId: widget.conversationId,
                imagePath: image.path,
                imageSize: imageSize,
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _pickFile() async {
    final PlatformFile? file = await _mediaService.pickFile();
    if (file == null) {
      return;
    }

    if (!mounted) return;
    final isConfirmed = await showFileSendConfirmationDialog(context, file);
    if (!isConfirmed || !mounted) {
      return;
    }

    final fileSize = file.size;
    if (!mounted) {
      return;
    }

    ref
        .read(chatBlocProvider)
        .add(
          SendFileEvent(
            conversationId: widget.conversationId,
            filePath: file.path!,
            fileName: file.name,
            fileSize: fileSize,
          ),
        );
  }

  Future<void> _pickVideo() async {
    try {
      final File? video = await _mediaService.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        if (!mounted) return;

        ref
            .read(chatBlocProvider)
            .add(
              SendVideoEvent(
                conversationId: widget.conversationId,
                file: video,
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick video: $e')));
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    final List<File> images = await _mediaService.pickMultipleImages(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (images.isNotEmpty) {
      final imagePaths = images
          .map((image) => image.path)
          .toList(growable: false);
      final imageSizes = <int>[];
      for (final image in images) {
        imageSizes.add(await image.length());
      }

      if (!mounted) {
        return;
      }

      ref
          .read(chatBlocProvider)
          .add(
            SendMultipleImagesEvent(
              conversationId: widget.conversationId,
              imagePaths: imagePaths,
              imageSizes: imageSizes,
            ),
          );
    }
  }

  Future<void> _showMessageActions(
    BuildContext context,
    ChatMessage message,
    AppLocalizations l10n, {
    Offset? anchor,
  }) async {
    if (message is SystemChatMessage ||
        message is PollChatMessage ||
        message is CallHistoryChatMessage) {
      return;
    }

    final canEdit = _canEditMessage(message);
    final canDelete = _canDeleteMessage(message);
    final canReact = _canReactToMessage(message);
    final canReply = !message.isDeleted;
    final pinMessageId = _resolveMessageIdForAction(message)?.trim();
    final chatState = ref.read(chatBlocProvider).state;
    final canPin =
        !message.isDeleted && pinMessageId != null && pinMessageId.isNotEmpty;
    final isPinned =
        chatState is ChatLoaded &&
        pinMessageId != null &&
        pinMessageId.isNotEmpty &&
        chatState.pinnedMessages.any((pin) => pin.messageId == pinMessageId);
    final hasText =
        !message.isDeleted &&
        message is TextChatMessage &&
        message.text.trim().isNotEmpty;

    if (!hasText &&
        !canEdit &&
        !canDelete &&
        !canReact &&
        !canReply &&
        !canPin) {
      return;
    }

    final mediaSize = MediaQuery.of(context).size;
    final dialogWidth = _messageActionDialogWidth
        .clamp(0, mediaSize.width - (_messageActionDialogMargin * 2))
        .toDouble();
    final anchorPoint =
        anchor ?? Offset(mediaSize.width / 2, mediaSize.height / 2);
    final dialogLeft =
        (message.isSentByMe
                ? (anchorPoint.dx - dialogWidth + 40).clamp(
                    _messageActionDialogMargin,
                    mediaSize.width - dialogWidth - _messageActionDialogMargin,
                  )
                : (anchorPoint.dx - 24).clamp(
                    _messageActionDialogMargin,
                    mediaSize.width - dialogWidth - _messageActionDialogMargin,
                  ))
            .toDouble();
    final dialogTop = (anchorPoint.dy - 120)
        .clamp(_messageActionDialogMargin, mediaSize.height - 220)
        .toDouble();

    final result = await showGeneralDialog<MessageActionResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'message-actions',
      barrierColor: Colors.black26,
      pageBuilder: (dialogContext, _, __) => Stack(
        children: [
          Positioned(
            left: dialogLeft,
            top: dialogTop,
            width: dialogWidth,
            child: MessageActionDialog(
              canCopy: hasText,
              canReply: canReply,
              canEdit: canEdit,
              canForward: true,
              canRevoke: true,
              canDelete: canDelete,
              canPin: canPin,
              isPinned: isPinned,
              reactions: canReact ? _reactionEmojis : const <String>[],
            ),
          ),
        ],
      ),
    );

    if (!mounted || !context.mounted || result == null) return;

    if (result.emoji != null) {
      _handleReactionSelection(message, result.emoji!);
      return;
    }

    final action = result.action;
    if (action == null) return;

    switch (action) {
      case MessageAction.copy:
        if (message is TextChatMessage) {
          await Clipboard.setData(ClipboardData(text: message.text));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.success_copied),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      case MessageAction.reply:
        setState(() {
          _replyToMessage = message;
        });

      case MessageAction.edit:
        if (context.mounted) _showEditDialog(context, message, l10n);

      case MessageAction.forward:
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (_) => ForwardMessageDialog(
            messageId: message.localId!,
            sourceConversationId: widget.conversationId,
            onSend: (List<String> targetConversationIds) {
              ref
                  .read(chatBlocProvider)
                  .add(
                    ForwardMessageEvent(
                      messageId: message.serverId ?? message.localId ?? '',
                      srcConversationId: widget.conversationId,
                      targetConversationIds: targetConversationIds,
                    ),
                  );
            },
          ),
        );

      case MessageAction.revoke:
        final localId = message.localId;
        final messageId = _resolveMessageIdForAction(message);
        if (localId == null || localId.trim().isEmpty) return;
        if (messageId == null || messageId.isEmpty) return;

        ref
            .read(chatBlocProvider)
            .add(
              RevokeMessageEvent(
                localId: localId,
                messageId: messageId,
                conversationId: widget.conversationId,
              ),
            );
      case MessageAction.delete:
        final localId = message.localId;
        final messageId = _resolveMessageIdForAction(message);
        if (localId == null || localId.trim().isEmpty) return;
        if (messageId == null || messageId.isEmpty) return;

        ref
            .read(chatBlocProvider)
            .add(
              HiddenMessageEvent(
                localId: localId,
                messageId: messageId,
                conversationId: widget.conversationId,
              ),
            );
      case MessageAction.pin:
        final messageId = _resolveMessageIdForAction(message)?.trim();
        if (messageId == null || messageId.isEmpty) return;
        ref
            .read(chatBlocProvider)
            .add(
              PinMessageEvent(
                messageId: messageId,
                conversationId: widget.conversationId,
              ),
            );
      case MessageAction.unpin:
        final messageId = _resolveMessageIdForAction(message)?.trim();
        if (messageId == null || messageId.isEmpty) return;
        ref
            .read(chatBlocProvider)
            .add(
              UnpinMessageEvent(
                messageId: messageId,
                conversationId: widget.conversationId,
              ),
            );
    }
  }

  void _handleReactionSelection(ChatMessage message, String emoji) {
    final normalizedEmoji = emoji.trim();
    if (normalizedEmoji.isEmpty) {
      return;
    }

    final hasSameMyReaction = message.reactions.any(
      (reaction) =>
          reaction.myReaction && reaction.emoji.trim() == normalizedEmoji,
    );

    // Same emoji that user already reacted with -> no-op to avoid duplicate server requests.
    if (hasSameMyReaction) {
      return;
    }

    final messageId = _resolveMessageIdForAction(message);
    if (messageId == null || messageId.isEmpty) {
      return;
    }

    ref
        .read(chatBlocProvider)
        .add(
          UpdateMessageReactionEvent(
            messageId: messageId,
            conversationId: widget.conversationId,
            emoji: normalizedEmoji,
            action: 'add',
          ),
        );
  }

  void _handleReactionTapToRemove(ChatMessage message, String emoji) {
    final normalizedEmoji = emoji.trim();
    if (normalizedEmoji.isEmpty) {
      return;
    }

    final hasMyReaction = message.reactions.any(
      (reaction) =>
          reaction.myReaction && reaction.emoji.trim() == normalizedEmoji,
    );

    // Only remove reactions that belong to current user.
    if (!hasMyReaction) {
      return;
    }

    final messageId = _resolveMessageIdForAction(message);
    if (messageId == null || messageId.isEmpty) {
      return;
    }

    ref
        .read(chatBlocProvider)
        .add(
          UpdateMessageReactionEvent(
            messageId: messageId,
            conversationId: widget.conversationId,
            emoji: normalizedEmoji,
            action: 'remove',
          ),
        );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    ChatMessage message,
    AppLocalizations l10n,
  ) async {
    if (message is! TextChatMessage) return;

    final controller = TextEditingController(text: message.text);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.action_edit),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: null,
            decoration: InputDecoration(hintText: l10n.input_new_content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.close),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.accept),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    final newContent = controller.text.trim();
    if (newContent.isEmpty || newContent == message.text) return;

    final localId = message.localId;
    if (localId == null || localId.trim().isEmpty) return;

    ref
        .read(chatBlocProvider)
        .add(
          EditMessageEvent(
            localId: localId,
            messageId: _resolveMessageIdForAction(message) ?? localId,
            content: newContent,
          ),
        );
  }

  void _onScroll(ChatBloc chatBloc) {
    if (!_scrollController.hasClients) return;

    final threshold = 100; // px

    // ⚠️ reverse: true → maxScrollExtent is "top", position.pixels near 0 is bottom
    final pos = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;
    final state = chatBloc.state;

    if (state is! ChatLoaded) return;

    // Scrolling toward top (older messages)
    if (pos >= max - threshold) {
      if (state.hasMoreOld && !state.isLoadingMore) {
        chatBloc.add(LoadMoreMessagesEvent(widget.conversationId));
      }
    }

    // Scrolling toward bottom (newer messages) in jumped mode
    if (pos <= threshold && state.isJumped) {
      if (state.hasMoreAfter && !state.isLoadingMore) {
        chatBloc.add(LoadMoreAfterEvent(widget.conversationId));
      } else if (!state.hasMoreAfter) {
        // Already at newest — return to live
        chatBloc.add(ReturnToLiveEvent(widget.conversationId));
      }
    }
  }
}
