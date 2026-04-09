part of 'set_profile_bloc.dart';

sealed class SetProfileEvent extends Equatable {
  const SetProfileEvent();
}

final class SetProfileFirstNameChanged extends SetProfileEvent {
  final String value;

  const SetProfileFirstNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class SetProfileLastNameChanged extends SetProfileEvent {
  final String value;

  const SetProfileLastNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class SetProfileUserNameChanged extends SetProfileEvent {
  final String value;

  const SetProfileUserNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class SetProfileAvatarUploadRequested extends SetProfileEvent {
  final String filePath;
  final int fileSize;

  const SetProfileAvatarUploadRequested({
    required this.filePath,
    required this.fileSize,
  });

  @override
  List<Object?> get props => [filePath, fileSize];
}

final class SetProfileSubmitted extends SetProfileEvent {
  const SetProfileSubmitted();

  @override
  List<Object?> get props => [];
}
