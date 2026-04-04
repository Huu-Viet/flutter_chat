import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';

part 'set_profile_event.dart';
part 'set_profile_state.dart';

class SetProfileBloc extends Bloc<SetProfileEvent, SetProfileState> {
  final SetUserInfoUseCase setUserInfoUseCase;
  final GetFullCurrentUserUseCase getCurrentUserUseCase;

  SetProfileBloc(
      this.setUserInfoUseCase,
      this.getCurrentUserUseCase,
  ) : super(SetProfileInitial()) {
    on<SetProfileSubmitted>((event, emit) async {
      emit(SetProfileLoading());
      try {
        await setUserInfoUseCase(event.myUser);
        emit(SetProfileSuccess());
      } catch (e) {
        emit(SetProfileFailure(e.toString()));
      }
    });

    on<SetProfileGetPreviousInfo>((event, emit) async {
      try {
        final result = await getCurrentUserUseCase();
        result.fold(
          (failure) => emit(SetProfileFailure(failure.message)),
          (myUser) => emit(SetProfilePreviousInfoLoaded(myUser)),
        );
      } catch (e) {
        emit(SetProfileFailure(e.toString()));
      }
    });
  }
}
