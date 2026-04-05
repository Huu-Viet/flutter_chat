part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

final class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();

  @override
  List<Object?> get props => [];
}

final class RefreshProfileEvent extends ProfileEvent {
  const RefreshProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileUserUpdatedEvent extends ProfileEvent {
  final MyUser myUser;

  const ProfileUserUpdatedEvent(this.myUser);

  @override
  List<Object?> get props => [myUser];
}

final class ProfileUserStreamErrorEvent extends ProfileEvent {
  final String message;

  const ProfileUserStreamErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
