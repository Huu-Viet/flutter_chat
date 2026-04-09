import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class ChatRepoImpl implements ChatRepository {
  final ChatService _chatService;

  ChatRepoImpl(this._chatService);

  @override
  Future<Either<Failure, List<Conversation>>> fetchConversations(int page, int limit) async {
    try {
      final response = await _chatService.fetchConversations(page, limit);
      final conversations = response.conversations
          .map((dto) => ApiConversationMapper().toDomain(dto))
          .toList(growable: false);
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}