import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/friendship/export.dart';

part 'contact_event.dart';
part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final GetPendingRequestsUseCase getPendingRequestsUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final AcceptFriendRequestUseCase acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase rejectFriendRequestUseCase;

  ContactBloc({
    required this.getPendingRequestsUseCase,
    required this.getUserByIdUseCase,
    required this.acceptFriendRequestUseCase,
    required this.rejectFriendRequestUseCase,
  }) : super(ContactInitial()) {
    on<GetPendingRequests>(_onGetPendingRequests);
    on<AcceptRequest>(_onAcceptRequest);
    on<DeclineRequest>(_onDeclineRequest);
  }

  Future<void> _onGetPendingRequests(
    GetPendingRequests event,
    Emitter<ContactState> emit,
  ) async {
    emit(ContactLoading());

    final result = await getPendingRequestsUseCase();
    final pendingIds = result.fold(
      (failure) {
        debugPrint('[ContactBloc] getPendingRequests failed: ${failure.message}');
        emit(ContactError(failure.message));
        return <String>[];
      },
      (map) {
        final ids = map['incoming'] ?? const <String>[];
        debugPrint('[ContactBloc] incoming request ids: $ids');
        return ids;
      },
    );

    if (pendingIds.isEmpty && state is ContactError) {
      return;
    }

    final users = <MyUser>[];
    for (final requesterId in pendingIds) {
      final user = await _resolveUser(requesterId);
      if (user != null) {
        users.add(user);
      }
    }

    emit(ContactLoaded(users));
  }

  Future<void> _onAcceptRequest(
    AcceptRequest event,
    Emitter<ContactState> emit,
  ) async {
    final result = await acceptFriendRequestUseCase(event.requesterId);
    result.fold(
      (failure) => emit(ContactError(failure.message)),
      (_) => add(GetPendingRequests()),
    );
  }

  Future<void> _onDeclineRequest(
    DeclineRequest event,
    Emitter<ContactState> emit,
  ) async {
    final result = await rejectFriendRequestUseCase(event.requesterId);
    result.fold(
      (failure) => emit(ContactError(failure.message)),
      (_) => add(GetPendingRequests()),
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
}
