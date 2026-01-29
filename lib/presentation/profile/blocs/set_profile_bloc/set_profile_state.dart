part of 'set_profile_bloc.dart';

sealed class SetProfileState extends Equatable {
  const SetProfileState();
}

final class SetProfileInitial extends SetProfileState {
  @override
  List<Object> get props => [];
}

final class SetProfileLoading extends SetProfileState {
  @override
  List<Object> get props => [];
}

final class SetProfileSuccess extends SetProfileState {
  @override
  List<Object> get props => [];
}

final class SetProfileFailure extends SetProfileState {
  final String errorMessage;

  const SetProfileFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class SetProfilePreviousInfoLoaded extends SetProfileState {
  final MyUser myUser;

  const SetProfilePreviousInfoLoaded(this.myUser);

  @override
  List<Object> get props => [myUser];
}

