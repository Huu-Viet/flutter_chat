part of 'outgoing_call_bloc.dart';

sealed class OutgoingCallEvent extends Equatable {
  const OutgoingCallEvent();

  @override
  List<Object?> get props => [];
}

final class OutgoingCallRequested extends OutgoingCallEvent {
  final String conversationId;
  final String callerId;
  final String receiverId;

  const OutgoingCallRequested({
    required this.conversationId,
    required this.callerId,
    required this.receiverId,
  });

  @override
  List<Object?> get props => [conversationId, callerId, receiverId];
}

final class OutgoingCallStatusConsumed extends OutgoingCallEvent {
  const OutgoingCallStatusConsumed();
}
