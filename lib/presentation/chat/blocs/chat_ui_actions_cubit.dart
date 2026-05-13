import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/features/chat/domain/entities/conversation.dart';
import 'package:flutter_chat/features/group_manager/domain/entities/join_group_invite_result.dart';
import 'package:flutter_chat/features/upload_media/data/dtos/media_info.dart';

class ChatUiActionsCubit extends Cubit<int> {
  final Future<Either<Failure, dynamic>> Function(String conversationId)?
  joinConversationAction;
  final Future<Either<Failure, List<Conversation>>> Function({
    String? query,
    int page,
    int limit,
  })?
  searchConversationsAction;
  final Future<Either<Failure, JoinGroupInviteResult>> Function({
    required String token,
    String? requestMessage,
  })?
  joinGroupViaInviteAction;
  final Future<Either<Failure, String>> Function(
    String mediaId, {
    String? prefer,
    String? conversationId,
  })?
  getMediaUrlAction;
  final Future<Either<Failure, MediaInfo>> Function(
    String path,
    String mediaType,
    int size,
    String? fileName,
  )?
  uploadMediaAction;
  final Future<Either<Failure, List<MyUser>>> Function(
    String query, {
    int page,
    int limit,
  })?
  searchUsersByUsernameAction;
  final Future<Either<Failure, dynamic>> Function(String userId)? blockUserAction;
  final Future<Either<Failure, dynamic>> Function(String userId)?
  unblockUserAction;
  final Future<Either<Failure, dynamic>> Function(String conversationId)?
  deleteLocalConversationAction;

  ChatUiActionsCubit({
    this.joinConversationAction,
    this.searchConversationsAction,
    this.joinGroupViaInviteAction,
    this.getMediaUrlAction,
    this.uploadMediaAction,
    this.searchUsersByUsernameAction,
    this.blockUserAction,
    this.unblockUserAction,
    this.deleteLocalConversationAction,
  }) : super(0);

  Future<Either<Failure, dynamic>> joinConversation(String conversationId) {
    final action = joinConversationAction;
    if (action == null) {
      throw StateError('joinConversationAction is not configured');
    }
    return action(conversationId);
  }

  Future<Either<Failure, List<Conversation>>> searchConversations({
    String? query,
    int page = 1,
    int limit = 20,
  }) {
    final action = searchConversationsAction;
    if (action == null) {
      throw StateError('searchConversationsAction is not configured');
    }
    return action(query: query, page: page, limit: limit);
  }

  Future<Either<Failure, JoinGroupInviteResult>> joinGroupViaInvite({
    required String token,
    String? requestMessage,
  }) {
    final action = joinGroupViaInviteAction;
    if (action == null) {
      throw StateError('joinGroupViaInviteAction is not configured');
    }
    return action(token: token, requestMessage: requestMessage);
  }

  Future<Either<Failure, String>> getOriginalMediaUrl(
    String mediaId, {
    String? conversationId,
  }) {
    final action = getMediaUrlAction;
    if (action == null) {
      throw StateError('getMediaUrlAction is not configured');
    }
    return action(
      mediaId,
      prefer: 'ORIGINAL',
      conversationId: conversationId,
    );
  }

  Future<Either<Failure, MediaInfo>> uploadImageAvatar(String path, int size) {
    final action = uploadMediaAction;
    if (action == null) {
      throw StateError('uploadMediaAction is not configured');
    }
    return action(path, 'image', size, null);
  }

  Future<Either<Failure, List<MyUser>>> searchUsersByUsername(
    String query, {
    int page = 1,
    int limit = 20,
  }) {
    final action = searchUsersByUsernameAction;
    if (action == null) {
      throw StateError('searchUsersByUsernameAction is not configured');
    }
    return action(query, page: page, limit: limit);
  }

  Future<Either<Failure, dynamic>> blockUser(String userId) {
    final action = blockUserAction;
    if (action == null) {
      throw StateError('blockUserAction is not configured');
    }
    return action(userId);
  }

  Future<Either<Failure, dynamic>> unblockUser(String userId) {
    final action = unblockUserAction;
    if (action == null) {
      throw StateError('unblockUserAction is not configured');
    }
    return action(userId);
  }

  Future<Either<Failure, dynamic>> deleteLocalConversation(
    String conversationId,
  ) {
    final action = deleteLocalConversationAction;
    if (action == null) {
      throw StateError('deleteLocalConversationAction is not configured');
    }
    return action(conversationId);
  }
}
