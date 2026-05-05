part of 'contact_bloc.dart';

sealed class ContactState extends Equatable {
  const ContactState();

  @override
  List<Object> get props => [];
}

final class ContactInitial extends ContactState {}

final class ContactLoading extends ContactState {}

final class ContactLoaded extends ContactState {
  final List<MyUser> incomingRequests;
  final List<MyUser> outgoingRequests;
  final List<FriendUser> friends;
  final Set<String> busyUserIds;
  final bool isRefreshing;

  const ContactLoaded({
    required this.incomingRequests,
    required this.outgoingRequests,
    required this.friends,
    this.busyUserIds = const <String>{},
    this.isRefreshing = false,
  });

  ContactLoaded copyWith({
    List<MyUser>? incomingRequests,
    List<MyUser>? outgoingRequests,
    List<FriendUser>? friends,
    Set<String>? busyUserIds,
    bool? isRefreshing,
  }) {
    return ContactLoaded(
      incomingRequests: incomingRequests ?? this.incomingRequests,
      outgoingRequests: outgoingRequests ?? this.outgoingRequests,
      friends: friends ?? this.friends,
      busyUserIds: busyUserIds ?? this.busyUserIds,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object> get props => [
        incomingRequests,
        outgoingRequests,
        friends,
        busyUserIds,
        isRefreshing,
      ];
}

final class ContactError extends ContactState {
  final String message;

  const ContactError(this.message);

  @override
  List<Object> get props => [message];
}
