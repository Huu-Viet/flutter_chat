part of 'add_friend_bloc.dart';

sealed class AddFriendEvent extends Equatable {
  const AddFriendEvent();

  @override
  List<Object?> get props => [];
}

final class AddFriendQueryChanged extends AddFriendEvent {
  final String query;

  const AddFriendQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class AddFriendResetRequested extends AddFriendEvent {
  const AddFriendResetRequested();
}

final class AddFriendSearchRequested extends AddFriendEvent {
  const AddFriendSearchRequested();
}
