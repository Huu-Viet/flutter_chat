import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/join_group_invite_result.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/group_invite_link.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/group_join_request.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/add_group_members_result.dart';
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

  Future<Either<Failure, GroupInviteLink?>> getInviteLink({
    required String conversationId,
  });

  Future<Either<Failure, GroupInviteLink>> createInviteLink({
    required String conversationId,
  });

  Future<Either<Failure, void>> revokeInviteLink({
    required String conversationId,
  });

  Future<Either<Failure, AddGroupMembersResult>> addMembers({
    required String conversationId,
    required List<String> userIds,
  });

  Future<Either<Failure, List<GroupJoinRequest>>> listJoinRequests({
    required String conversationId,
  });

  Future<Either<Failure, void>> reviewJoinRequest({
    required String conversationId,
    required String requestId,
    required bool approve,
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
