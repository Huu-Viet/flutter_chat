import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/group_manager/data/datasources/api/group_management_service.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/join_group_invite_result.dart';
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
}
