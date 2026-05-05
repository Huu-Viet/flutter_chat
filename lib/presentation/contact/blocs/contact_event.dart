part of 'contact_bloc.dart';

sealed class ContactEvent extends Equatable {
  const ContactEvent();
}

final class LoadContactData extends ContactEvent {
  final bool showLoading;

  const LoadContactData({this.showLoading = true});

  @override
  List<Object?> get props => [showLoading];
}

final class AcceptIncomingRequest extends ContactEvent {
  final String requesterId;

  const AcceptIncomingRequest(this.requesterId);

  @override
  List<Object?> get props => [requesterId];
}

final class DeclineIncomingRequest extends ContactEvent {
  final String requesterId;

  const DeclineIncomingRequest(this.requesterId);

  @override
  List<Object?> get props => [requesterId];
}

final class CancelOutgoingRequest extends ContactEvent {
  final String targetUserId;

  const CancelOutgoingRequest(this.targetUserId);

  @override
  List<Object?> get props => [targetUserId];
}

final class RemoveFriend extends ContactEvent {
  final String targetUserId;

  const RemoveFriend(this.targetUserId);

  @override
  List<Object?> get props => [targetUserId];
}
