part of 'contact_bloc.dart';

sealed class ContactEvent extends Equatable {
  const ContactEvent();
}

final class GetPendingRequests extends ContactEvent {
  @override
  List<Object?> get props => [];
}

final class AcceptRequest extends ContactEvent {
  final String requesterId;

  const AcceptRequest(this.requesterId);

  @override
  List<Object?> get props => [requesterId];
}

final class DeclineRequest extends ContactEvent {
  final String requesterId;

  const DeclineRequest(this.requesterId);

  @override
  List<Object?> get props => [requesterId];
}
