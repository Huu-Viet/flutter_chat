import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/core/network/realtime_gateway.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/friendship/export.dart';
import 'dart:async';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final GetPendingRequestsUseCase getPendingRequestsUseCase;
  final GetFriendsListUseCase getFriendsListUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final AcceptFriendRequestUseCase acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase rejectFriendRequestUseCase;
  final RemoveFriendshipUseCase removeFriendshipUseCase;
  final RealtimeGateway realtimeGateway;

  StreamSubscription<RealtimeGatewayEvent>? _realtimeSubscription;

  ContactBloc({
    required this.getPendingRequestsUseCase,
    required this.getFriendsListUseCase,
    required this.getUserByIdUseCase,
    required this.acceptFriendRequestUseCase,
    required this.rejectFriendRequestUseCase,
    required this.removeFriendshipUseCase,
    required this.realtimeGateway,
  }) : super(ContactInitial()) {
    on<LoadContactData>(_onLoadContactData);
    on<AcceptIncomingRequest>(_onAcceptRequest);
    on<DeclineIncomingRequest>(_onDeclineRequest);
    on<CancelOutgoingRequest>(_onCancelOutgoingRequest);
    on<RemoveFriend>(_onRemoveFriend);

    _realtimeSubscription = realtimeGateway.events.listen(_onRealtimeEvent);
  }

  void _onRealtimeEvent(RealtimeGatewayEvent event) {
    if (event.namespace != '/chat') {
      return;
    }
    if (!_isFriendshipEvent(event.event)) {
      return;
    }

    debugPrint('[ContactBloc] Realtime friendship event: ${event.event} -> ${event.payload}');
    add(const LoadContactData(showLoading: false));
  }

  bool _isFriendshipEvent(String eventName) {
    return eventName == 'friendship:request_sent' ||
        eventName == 'friendship:request_received' ||
        eventName == 'friendship:request_accepted' ||
        eventName == 'friendship:request_rejected' ||
        eventName == 'friendship:removed' ||
        eventName == 'friendship:blocked' ||
        eventName == 'friendship:unblocked' ||
        eventName == 'friendship.request_sent' ||
        eventName == 'friendship.request_received' ||
        eventName == 'friendship.request_accepted' ||
        eventName == 'friendship.request_rejected' ||
        eventName == 'friendship.removed' ||
        eventName == 'friendship.blocked' ||
        eventName == 'friendship.unblocked';
  }

  Future<void> _onLoadContactData(
    LoadContactData event,
    Emitter<ContactState> emit,
  ) async {
    final current = state;
    final previousLoaded = current is ContactLoaded ? current : null;

    if (event.showLoading || previousLoaded == null) {
      emit(ContactLoading());
    } else {
      emit(previousLoaded.copyWith(isRefreshing: true));
    }

    final pendingResult = await getPendingRequestsUseCase();
    final pendingMap = pendingResult.fold<Map<String, List<String>>>(
      (failure) {
        debugPrint('[ContactBloc] getPendingRequests failed: ${failure.message}');
        emit(ContactError(failure.message));
        return const <String, List<String>>{};
      },
      (map) => map,
    );

    if (state is ContactError) {
      return;
    }

    final incomingIds = pendingMap['incoming'] ?? const <String>[];
    final outgoingIds = pendingMap['outgoing'] ?? const <String>[];

    final incomingUsers = await _resolveUsers(incomingIds);
    final outgoingUsers = await _resolveUsers(outgoingIds);

    final friendsResult = await getFriendsListUseCase();
    final friends = friendsResult.fold<List<FriendUser>>(
      (failure) {
        debugPrint('[ContactBloc] getFriendsList failed: ${failure.message}');
        emit(ContactError(failure.message));
        return const <FriendUser>[];
      },
      (items) {
        final sorted = [...items]
          ..sort((a, b) =>
              a.user.displayName.toLowerCase().compareTo(b.user.displayName.toLowerCase()));
        return sorted;
      },
    );

    if (state is ContactError) {
      return;
    }

    final busy = previousLoaded?.busyUserIds ?? const <String>{};
    emit(ContactLoaded(
      incomingRequests: incomingUsers,
      outgoingRequests: outgoingUsers,
      friends: friends,
      busyUserIds: busy,
      isRefreshing: false,
    ));
  }

  Future<List<MyUser>> _resolveUsers(List<String> ids) async {
    final users = <MyUser>[];
    for (final id in ids) {
      final user = await _resolveUser(id);
      if (user != null) {
        users.add(user);
      }
    }

    users.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    return users;
  }

  void _setBusy(String userId, Emitter<ContactState> emit) {
    final current = state;
    if (current is! ContactLoaded) {
      return;
    }
    emit(current.copyWith(
      busyUserIds: {...current.busyUserIds, userId},
    ));
  }

  void _clearBusy(String userId, Emitter<ContactState> emit) {
    final current = state;
    if (current is! ContactLoaded) {
      return;
    }
    final next = {...current.busyUserIds}..remove(userId);
    emit(current.copyWith(busyUserIds: next));
  }

  Future<void> _onAcceptRequest(
    AcceptIncomingRequest event,
    Emitter<ContactState> emit,
  ) async {
    _setBusy(event.requesterId, emit);
    final result = await acceptFriendRequestUseCase(event.requesterId);
    result.fold(
      (failure) {
        _clearBusy(event.requesterId, emit);
        emit(ContactError(failure.message));
      },
      (_) => add(const LoadContactData(showLoading: false)),
    );
  }

  Future<void> _onDeclineRequest(
    DeclineIncomingRequest event,
    Emitter<ContactState> emit,
  ) async {
    _setBusy(event.requesterId, emit);
    final result = await rejectFriendRequestUseCase(event.requesterId);
    result.fold(
      (failure) {
        _clearBusy(event.requesterId, emit);
        emit(ContactError(failure.message));
      },
      (_) => add(const LoadContactData(showLoading: false)),
    );
  }

  Future<void> _onCancelOutgoingRequest(
    CancelOutgoingRequest event,
    Emitter<ContactState> emit,
  ) async {
    _setBusy(event.targetUserId, emit);
    final result = await rejectFriendRequestUseCase(event.targetUserId);
    result.fold(
      (failure) {
        _clearBusy(event.targetUserId, emit);
        emit(ContactError(failure.message));
      },
      (_) => add(const LoadContactData(showLoading: false)),
    );
  }

  Future<void> _onRemoveFriend(
    RemoveFriend event,
    Emitter<ContactState> emit,
  ) async {
    _setBusy(event.targetUserId, emit);
    final result = await removeFriendshipUseCase(event.targetUserId);
    result.fold(
      (failure) {
        _clearBusy(event.targetUserId, emit);
        emit(ContactError(failure.message));
      },
      (_) => add(const LoadContactData(showLoading: false)),
    );
  }

  Future<MyUser?> _resolveUser(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final result = await getUserByIdUseCase(normalized);
    return result.fold(
      (failure) {
        debugPrint('[ContactBloc] getUserById failed for $normalized: ${failure.message}');
        return null;
      },
      (user) {
        debugPrint('[ContactBloc] resolved user: ${user.id} / ${user.username}');
        return user;
      },
    );
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    return super.close();
  }
}
