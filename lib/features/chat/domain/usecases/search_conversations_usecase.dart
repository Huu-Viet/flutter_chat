import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/chat/export.dart';

class SearchConversationsUseCase {
  final ChatRepository _repository;

  SearchConversationsUseCase(this._repository);

  Future<Either<Failure, List<Conversation>>> call({
    String? query,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.searchConversations(
      query: query,
      page: page,
      limit: limit,
    );
  }
}
