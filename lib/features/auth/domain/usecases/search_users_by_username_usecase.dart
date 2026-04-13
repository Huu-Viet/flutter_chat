import 'package:dartz/dartz.dart';
import 'package:flutter_chat/core/errors/failure.dart';
import 'package:flutter_chat/features/auth/domain/entities/user.dart';
import 'package:flutter_chat/features/auth/domain/repositories/auth_repository.dart';

class SearchUsersByUsernameUseCase {
  final AuthRemoteRepository _authRepo;

  SearchUsersByUsernameUseCase(this._authRepo);

  Future<Either<Failure, List<MyUser>>> call(
    String query, {
    int page = 1,
    int limit = 10,
  }) {
    return _authRepo.searchUsersByUsername(
      query,
      page: page,
      limit: limit,
    );
  }
}