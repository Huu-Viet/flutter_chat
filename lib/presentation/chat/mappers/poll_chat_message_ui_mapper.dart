import 'package:flutter_chat/core/mappers/ui_mapper.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation_participant.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/poll_entity.dart';
import 'package:flutter_chat/presentation/chat/models/chat_message.dart';

class PollMappingContext {
  final PollEntity poll;
  final List<ConversationParticipant> participants;
  final String? currentUserId;
  final String? conversationAvatarUrl;
  final bool isGroupConversation;

  const PollMappingContext({
    required this.poll,
    required this.participants,
    required this.currentUserId,
    required this.conversationAvatarUrl,
    required this.isGroupConversation,
  });
}

class PollChatMessageUIMapper extends UIMapper<PollMappingContext, PollChatMessage> {
  @override
  PollChatMessage toUI(PollMappingContext input) {
    final poll = input.poll;
    final participants = input.participants;
    final normalizedCurrentUserId = input.currentUserId?.trim() ?? '';

    String? senderDisplayNameById(String userId) {
      for (final participant in participants) {
        if (participant.userId.trim() != userId) continue;
        final displayName = participant.displayName.trim();
        if (displayName.isNotEmpty) return displayName;
        return participant.username;
      }
      return null;
    }

    String? senderAvatarUrlById(String userId) {
      for (final participant in participants) {
        if (participant.userId.trim() == userId) {
          return participant.avatarUrl;
        }
      }
      return null;
    }

    final options = poll.options
        .map(
          (opt) => PollChatOption(
            id: opt.id,
            text: opt.text,
            voteCount: opt.voteCount,
            isSelectedByMe:
                normalizedCurrentUserId.isNotEmpty &&
                opt.voterIds.contains(normalizedCurrentUserId),
          ),
        )
        .toList(growable: false);

    return PollChatMessage(
      pollId: poll.id,
      question: poll.question,
      options: options,
      multipleChoice: poll.multipleChoice,
      deadline: poll.deadline,
      isClosed: poll.isClosed,
      isSentByMe:
          poll.creatorId.isNotEmpty &&
          poll.creatorId == normalizedCurrentUserId,
      senderId: poll.creatorId,
      timestamp: poll.updatedAt ?? poll.createdAt,
      localId: poll.id,
      serverId: poll.id,
      senderDisplayName: senderDisplayNameById(poll.creatorId),
      senderAvatarUrl: senderAvatarUrlById(poll.creatorId),
      conversationAvatarUrl: input.conversationAvatarUrl,
      isGroupConversation: input.isGroupConversation,
    );
  }

  List<PollChatMessage> mapPolls({
    required List<PollEntity> polls,
    required List<ConversationParticipant> participants,
    required String? currentUserId,
    required String? conversationAvatarUrl,
    required bool isGroupConversation,
  }) {
    return polls
        .map(
          (poll) => toUI(
            PollMappingContext(
              poll: poll,
              participants: participants,
              currentUserId: currentUserId,
              conversationAvatarUrl: conversationAvatarUrl,
              isGroupConversation: isGroupConversation,
            ),
          ),
        )
        .toList(growable: false);
  }
}
