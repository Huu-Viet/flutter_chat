part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

final class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();

  @override
  List<Object?> get props => [];
}
