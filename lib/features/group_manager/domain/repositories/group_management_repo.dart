import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';

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
}