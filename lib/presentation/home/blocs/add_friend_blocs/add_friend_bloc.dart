import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'add_friend_event.dart';
part 'add_friend_state.dart';

class AddFriendBloc extends Bloc<AddFriendEvent, AddFriendState> {
  final SearchUsersByUsernameUseCase searchUsersByUsernameUseCase;

  AddFriendBloc({
    required this.searchUsersByUsernameUseCase,
  }) : super(const AddFriendInitial()) {
    on<AddFriendQueryChanged>(_onQueryChanged);
    on<AddFriendResetRequested>(_onResetRequested);
    on<AddFriendSearchRequested>(_onSearchRequested);
  }

  void _onQueryChanged(AddFriendQueryChanged event, Emitter<AddFriendState> emit) {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(const AddFriendInitial());
      return;
    }

    emit(AddFriendLoaded(query: query, users: const <MyUser>[], hasSearched: false));
  }

  Future<void> _onSearchRequested(AddFriendSearchRequested event, Emitter<AddFriendState> emit) async {
    final query = state.query.trim();
    await _searchUsers(query, emit);
  }

  Future<void> _searchUsers(String query, Emitter<AddFriendState> emit) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty || isClosed) {
      return;
    }

    emit(AddFriendLoading(query: normalizedQuery, users: state.users, hasSearched: true));
    final requestQuery = normalizedQuery;

    final result = await searchUsersByUsernameUseCase(
      normalizedQuery,
      page: 1,
      limit: 20,
    );

    if (isClosed || state.query.trim() != requestQuery) {
      return;
    }

    result.fold(
      (failure) => emit(
        AddFriendFailure(
          message: failure.message,
          query: normalizedQuery,
          users: state.users,
          hasSearched: true,
        ),
      ),
      (users) => emit(AddFriendLoaded(query: normalizedQuery, users: users, hasSearched: true)),
    );
  }

  void _onResetRequested(AddFriendResetRequested event, Emitter<AddFriendState> emit) {
    emit(const AddFriendInitial());
  }
}
