part of 'add_friend_bloc.dart';

sealed class AddFriendState extends Equatable {
  final String query;
  final List<MyUser> users;
  final bool hasSearched;
  final String? busyUserId;

  const AddFriendState({
    required this.query,
    required this.users,
    required this.hasSearched,
    required this.busyUserId,
  });

  @override
  List<Object?> get props => [query, users, hasSearched, busyUserId];
}

final class AddFriendInitial extends AddFriendState {
  const AddFriendInitial()
      : super(
          query: '',
          users: const <MyUser>[],
          hasSearched: false,
          busyUserId: null,
        );

  @override
  List<Object?> get props => [query, users, hasSearched, busyUserId];
}

final class AddFriendLoading extends AddFriendState {
  const AddFriendLoading({
    required super.query,
    required super.users,
    required super.hasSearched,
    required super.busyUserId,
  });

  @override
  List<Object?> get props => [query, users, hasSearched, busyUserId];
}

final class AddFriendLoaded extends AddFriendState {
  const AddFriendLoaded({
    required super.query,
    required super.users,
    required super.hasSearched,
    required super.busyUserId,
  });

  @override
  List<Object?> get props => [query, users, hasSearched, busyUserId];
}

final class AddFriendFailure extends AddFriendState {
  final String message;

  const AddFriendFailure({
    required this.message,
    required super.query,
    required super.users,
    required super.hasSearched,
    required super.busyUserId,
  });

  @override
  List<Object?> get props => [message, query, users, hasSearched, busyUserId];
}
