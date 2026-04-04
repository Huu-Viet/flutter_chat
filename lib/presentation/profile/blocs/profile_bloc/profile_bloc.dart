import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetFullCurrentUserUseCase getCurrentUserUseCase;

  ProfileBloc(
    this.getCurrentUserUseCase
  ) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (myUser) => emit(ProfileLoaded(myUser)),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
