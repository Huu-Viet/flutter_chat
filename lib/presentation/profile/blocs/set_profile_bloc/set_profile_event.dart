part of 'set_profile_bloc.dart';

sealed class SetProfileEvent extends Equatable {
  const SetProfileEvent();
}

class SetProfileSubmitted extends SetProfileEvent {
  final MyUser myUser;

  const SetProfileSubmitted({
    required this.myUser
  });

  @override
  List<Object?> get props => [myUser];
}

class SetProfileGetPreviousInfo extends SetProfileEvent {
  @override
  List<Object?> get props => [];
}
