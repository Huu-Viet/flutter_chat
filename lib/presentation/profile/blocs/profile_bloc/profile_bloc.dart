import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/application/realtime/orchestrator.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;
  final GetLocalCurrentUserDataUseCase getLocalCurrentUserDataUseCase;
  final SyncCurrentUserFromRemoteUseCase syncCurrentUserFromRemoteUseCase;
  final SignOutUseCase signOutUseCase;
  final ClearLocalAppDataUseCase clearLocalAppDataUseCase;
  final DisconnectRealtimeGatewayUseCase disconnectRealtimeGatewayUseCase;
  StreamSubscription? _userSubscription;

  ProfileBloc(
    this.getCurrentUserIdUseCase,
    this.getLocalCurrentUserDataUseCase,
    this.syncCurrentUserFromRemoteUseCase,
    this.signOutUseCase,
    this.clearLocalAppDataUseCase,
    this.disconnectRealtimeGatewayUseCase,
  ) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<ProfileUserUpdatedEvent>(_onProfileUserUpdated);
    on<ProfileUserStreamErrorEvent>(_onProfileUserStreamError);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    await _userSubscription?.cancel();

    final currentUserIdResult = await getCurrentUserIdUseCase();
    var currentUserId = currentUserIdResult.fold((_) => null, (id) => id);
    var bootstrappedFromRemote = false;

    if (currentUserId == null || currentUserId.isEmpty) {
      await syncCurrentUserFromRemoteUseCase();
      bootstrappedFromRemote = true;
      final refreshedUserIdResult = await getCurrentUserIdUseCase();
      currentUserId = refreshedUserIdResult.fold((_) => null, (id) => id);
    }

    if (currentUserId != null && currentUserId.isNotEmpty) {
      _userSubscription = getLocalCurrentUserDataUseCase(currentUserId).listen((result) {
        result.fold(
          (failure) => add(ProfileUserStreamErrorEvent(failure.message)),
          (myUser) => add(ProfileUserUpdatedEvent(myUser)),
        );
      });
    }

    if (!bootstrappedFromRemote) {
      await syncCurrentUserFromRemoteUseCase();
    }
  }

  Future<void> _onRefreshProfile(RefreshProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    await syncCurrentUserFromRemoteUseCase();
  }

  void _onProfileUserUpdated(
    ProfileUserUpdatedEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(ProfileLoaded(event.myUser));
  }

  void _onProfileUserStreamError(
    ProfileUserStreamErrorEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is! ProfileLoaded) {
      emit(ProfileError(event.message));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    await disconnectRealtimeGatewayUseCase();
    await signOutUseCase();
    await clearLocalAppDataUseCase();
    emit (ProfileSignOutComplete());
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
