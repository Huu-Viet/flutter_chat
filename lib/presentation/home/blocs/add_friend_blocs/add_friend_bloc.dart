import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/friendship/export.dart';
import 'package:flutter_chat/features/friendship/friendship_providers.dart';

part 'add_friend_event.dart';
part 'add_friend_state.dart';

class AddFriendBloc extends Bloc<AddFriendEvent, AddFriendState> {
  final SearchUsersByUsernameUseCase searchUsersByUsernameUseCase;
  final SendFriendRequestUseCase sendFriendRequestUseCase;

  AddFriendBloc({
    required this.searchUsersByUsernameUseCase,
    required this.sendFriendRequestUseCase,
  }) : super(const AddFriendInitial()) {
    on<AddFriendQueryChanged>(_onQueryChanged);
    on<AddFriendResetRequested>(_onResetRequested);
    on<AddFriendSearchRequested>(_onSearchRequested);
    on<AddFriendRequestRequested>(_onRequestRequested);
  }

  void _onQueryChanged(AddFriendQueryChanged event, Emitter<AddFriendState> emit) {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(const AddFriendInitial());
      return;
    }

    emit(AddFriendLoaded(query: query, users: const <MyUser>[], hasSearched: false, busyUserId: ''));
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

    emit(AddFriendLoading(
      query: normalizedQuery,
      users: state.users,
      hasSearched: true,
      busyUserId: state.busyUserId,
    ));
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
          busyUserId: null,
        ),
      ),
      (users) => emit(AddFriendLoaded(
        query: normalizedQuery,
        users: users,
        hasSearched: true,
        busyUserId: null,
      )),
    );
  }

  Future<void> _onRequestRequested(
    AddFriendRequestRequested event,
    Emitter<AddFriendState> emit,
  ) async {
    final targetUserId = event.userId.trim();
    if (targetUserId.isEmpty || isClosed) {
      return;
    }

    emit(AddFriendLoaded(
      query: state.query,
      users: state.users,
      hasSearched: state.hasSearched,
      busyUserId: targetUserId,
    ));

    final result = await sendFriendRequestUseCase(targetUserId);
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) => emit(AddFriendFailure(
        message: failure.message,
        query: state.query,
        users: state.users,
        hasSearched: state.hasSearched,
        busyUserId: null,
      )),
      (_) {
        final remainingUsers = state.users.where((user) => user.id != targetUserId).toList(growable: false);
        emit(AddFriendLoaded(
          query: state.query,
          users: remainingUsers,
          hasSearched: state.hasSearched,
          busyUserId: null,
        ));
      },
    );
  }

  void _onResetRequested(AddFriendResetRequested event, Emitter<AddFriendState> emit) {
    emit(const AddFriendInitial());
  }
}
