import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/auth/export.dart';
import 'package:flutter_chat/features/upload_media/export.dart';

part 'set_profile_event.dart';
part 'set_profile_state.dart';

class SetProfileBloc extends Bloc<SetProfileEvent, SetProfileState> {
  final SetUserInfoUseCase setUserInfoUseCase;
  final UploadMediaUseCase uploadMediaUseCase;

  SetProfileBloc({
    required this.setUserInfoUseCase,
    required this.uploadMediaUseCase,
    required MyUser initialUser,
  }) : super(SetProfileState.initial(initialUser)) {
    on<SetProfileFirstNameChanged>((event, emit) {
      emit(state.copyWith(
        firstName: event.value,
        isSuccess: false,
      ));
    });

    on<SetProfileLastNameChanged>((event, emit) {
      emit(state.copyWith(
        lastName: event.value,
        isSuccess: false,
      ));
    });

    on<SetProfileUserNameChanged>((event, emit) {
      emit(state.copyWith(
        userName: event.value,
        isSuccess: false,
      ));
    });

    on<SetProfileAvatarUploadRequested>((event, emit) async {
      emit(state.copyWith(
        isAvatarUploading: true,
        clearError: true,
        isSuccess: false,
      ));

      final result = await uploadMediaUseCase(
        event.filePath,
        'image',
        event.fileSize,
        null
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            isAvatarUploading: false,
            errorMessage: failure.message,
          ));
        },
        (mediaInfo) {
          if (mediaInfo.mediaId == null || mediaInfo.mediaId!.isEmpty) {
            emit(state.copyWith(
              isAvatarUploading: false,
              errorMessage: 'Upload image failed: missing mediaId',
            ));
            return;
          }

          emit(state.copyWith(
            avatarMediaId: mediaInfo.mediaId,
            avatarLocalPath: event.filePath,
            isAvatarUploading: false,
            clearError: true,
          ));
        },
      );
    });

    on<SetProfileSubmitted>((event, emit) async {
      if (!state.canSubmit) {
        return;
      }

      emit(state.copyWith(
        isSubmitting: true,
        clearError: true,
        isSuccess: false,
      ));

      final updatedUser = state.initialUser.copyWith(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        username: state.userName.trim(),
        avatarMediaId: state.avatarMediaId,
      );

      final result = await setUserInfoUseCase(updatedUser);

      result.fold(
        (failure) {
          emit(state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
          ));
        },
        (_) {
          emit(state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            clearError: true,
          ));
        },
      );
    });
  }
}
