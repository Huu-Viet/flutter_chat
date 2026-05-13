import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/data/datasources/api/group_management_service.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/join_group_invite_result.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/poll_entity.dart';
import 'package:flutter_chat/features/group_manager/domain/repositories/group_management_repo.dart';

class GroupManagementRepoImpl extends GroupManagementRepo {
  final GroupManagementService _service;

  GroupManagementRepoImpl(this._service);

  @override
  Future<Either<Failure, void>> createGroup({
    required String type,
    required String groupName,
    required List<String> memberIds,
    String? description,
    String? avatarMediaId,
  }) async {
    try {
      await _service.createGroup(
        type,
        memberIds,
        groupName,
        description,
        avatarMediaId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateGroupSettings({
    required String groupId,
    required String allowMemberMessage,
    required bool isPublic,
    required bool joinApprovalRequired,
  }) async {
    try {
      await _service.updateSetting(
        groupId,
        allowMemberMessage,
        isPublic,
        joinApprovalRequired,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, JoinGroupInviteResult>> joinGroupViaInvite({
    required String token,
    String? requestMessage,
  }) async {
    try {
      final result = await _service.joinGroupViaInvite(
        token: token,
        requestMessage: requestMessage,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<PollEntity>>> listConversationPolls({
    required String conversationId,
    bool includeClosed = false,
  }) async {
    try {
      final raw = await _service.listConversationPolls(
        conversationId: conversationId,
        includeClosed: includeClosed,
      );
      final polls = raw.map(_toPollEntity).toList(growable: false);
      return Right(polls);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> votePoll({
    required String conversationId,
    required String pollId,
    required List<String> optionIds,
  }) async {
    try {
      await _service.votePoll(
        conversationId: conversationId,
        pollId: pollId,
        optionIds: optionIds,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> closePoll({
    required String conversationId,
    required String pollId,
  }) async {
    try {
      await _service.closePoll(
        conversationId: conversationId,
        pollId: pollId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  PollEntity _toPollEntity(Map<String, dynamic> raw) {
    int _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime _parseDateTime(dynamic value) {
      if (value == null) return DateTime.now().toUtc();
      return DateTime.tryParse(value.toString()) ?? DateTime.now().toUtc();
    }

    DateTime? _parseOptionalDateTime(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    Set<String> _parseVoterIds(dynamic value) {
      if (value is! List) return const <String>{};
      return value
          .map((item) => item.toString().trim())
          .where((id) => id.isNotEmpty)
          .toSet();
    }

    final optionNodes = raw['options'];
    final options = optionNodes is List
        ? optionNodes
              .whereType<Map>()
              .map((rawOpt) {
                final opt = rawOpt.map(
                  (k, v) => MapEntry(k.toString(), v),
                );
                final voterIds = _parseVoterIds(opt['voterIds']);
                final explicitCount = opt['voteCount'] ?? opt['vote_count'];
                final voteCount =
                    explicitCount != null
                    ? _parseInt(explicitCount)
                    : voterIds.length;
                return PollOptionEntity(
                  id: (opt['id'] ?? '').toString(),
                  text: (opt['text'] ?? 'Option').toString(),
                  voteCount: voteCount,
                  voterIds: voterIds,
                );
              })
              .toList(growable: false)
        : const <PollOptionEntity>[];

    return PollEntity(
      id: (raw['id'] ?? '').toString(),
      conversationId: (raw['conversationId'] ?? '').toString(),
      creatorId: (raw['creatorId'] ?? '').toString().trim(),
      question: (raw['question'] ?? '').toString(),
      options: options,
      multipleChoice: raw['multipleChoice'] == true,
      isClosed: raw['isClosed'] == true,
      createdAt: _parseDateTime(raw['createdAt']),
      updatedAt: _parseOptionalDateTime(raw['updatedAt']),
      deadline: _parseOptionalDateTime(raw['deadline']),
    );
  }
}
