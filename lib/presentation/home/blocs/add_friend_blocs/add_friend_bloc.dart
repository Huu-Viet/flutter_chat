import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/friendship/export.dart';

part 'add_friend_event.dart';
part 'add_friend_state.dart';

class AddFriendBloc extends Bloc<AddFriendEvent, AddFriendState> {
  final SearchUsersByUsernameUseCase searchUsersByUsernameUseCase;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final GetFriendsListUseCase getFriendsListUseCase;
  final GetPendingRequestsUseCase getPendingRequestsUseCase;

  AddFriendBloc({
    required this.searchUsersByUsernameUseCase,
    required this.sendFriendRequestUseCase,
    required this.getFriendsListUseCase,
    required this.getPendingRequestsUseCase,
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

    emit(AddFriendLoaded(
        query: query,
        users: const <MyUser>[],
        hasSearched: false, 
        busyUserId: '',
        friendAndPendingUserIds: const [],));
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
      friendAndPendingUserIds: state.friendAndPendingUserIds,
    ));
    final requestQuery = normalizedQuery;

    final result = await searchUsersByUsernameUseCase(
      normalizedQuery,
      page: 1,
      limit: 20,
    );

    final pendingResult = await getPendingRequestsUseCase();
    final friendsResult = await getFriendsListUseCase();
    
    //map to ids list which combine both pending and friends
    //pending structure is type of request (incoming or outgoing) and the user data, we need only the user data
    final friendAndPendingUserIds = <String>{};
    pendingResult.fold(
      (failure) => debugPrint('[AddFriendBloc] Failed to get pending requests: ${failure.message}'),
      (pending) {
        debugPrint('[AddFriendBloc] Pending requests: $pending');
        friendAndPendingUserIds.addAll(pending.values.expand((list) => list));
      },
    );
    friendsResult.fold(
      (failure) => debugPrint('[AddFriendBloc] Failed to get pending requests: ${failure.message}'),
      (friends) {
        debugPrint('[AddFriendBloc] Pending requests: $friends');
        friendAndPendingUserIds.addAll(friends.map((friend) => friend.user.id));
      },
    );

    if (isClosed || state.query.trim() != requestQuery) {
      return;
    }

    debugPrint('[AddFriendBloc] Friend and pending user ids: $friendAndPendingUserIds');
    result.fold(
      (failure) => emit(
        AddFriendFailure(
          message: failure.message,
          query: normalizedQuery,
          users: state.users,
          hasSearched: true,
          busyUserId: null,
          friendAndPendingUserIds: [],
        ),
      ),
      (users) => emit(AddFriendLoaded(
        query: normalizedQuery,
        users: users,
        hasSearched: true,
        busyUserId: null,
        friendAndPendingUserIds: friendAndPendingUserIds.toList(growable: false),
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
      friendAndPendingUserIds: state.friendAndPendingUserIds,
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
        friendAndPendingUserIds: state.friendAndPendingUserIds,
      )),
      (_) {
        final remainingUsers = state.users.where((user) => user.id != targetUserId).toList(growable: false);
        emit(AddFriendLoaded(
          query: state.query,
          users: remainingUsers,
          hasSearched: state.hasSearched,
          busyUserId: null,
          friendAndPendingUserIds: [...state.friendAndPendingUserIds, targetUserId],
        ));
      },
    );
  }

  void _onResetRequested(AddFriendResetRequested event, Emitter<AddFriendState> emit) {
    emit(const AddFriendInitial());
  }
}
