import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/join_group_invite_result.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/poll_entity.dart';

abstract class GroupManagementRepo {
  Future<Either<Failure, void>> createGroup({
    required String type,
    required String groupName,
    required List<String> memberIds,
    String? description,
    String? avatarMediaId,
  });

  Future<Either<Failure, void>> updateGroupSettings({
    required String groupId,
    required String allowMemberMessage,
    required bool isPublic,
    required bool joinApprovalRequired,
  });

  Future<Either<Failure, JoinGroupInviteResult>> joinGroupViaInvite({
    required String token,
    String? requestMessage,
  });

  Future<Either<Failure, List<PollEntity>>> listConversationPolls({
    required String conversationId,
    bool includeClosed = false,
  });

  Future<Either<Failure, void>> votePoll({
    required String conversationId,
    required String pollId,
    required List<String> optionIds,
  });

  Future<Either<Failure, void>> closePoll({
    required String conversationId,
    required String pollId,
  });
}
