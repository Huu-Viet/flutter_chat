part of 'outgoing_call_bloc.dart';

sealed class OutgoingCallEvent extends Equatable {
  const OutgoingCallEvent();

  @override
  List<Object?> get props => [];
}

final class OutgoingCallRequested extends OutgoingCallEvent {
  final String conversationId;
  final String callerId;
  final List<String> calleeIds;

  const OutgoingCallRequested({
    required this.conversationId,
    required this.callerId,
    required this.calleeIds,
  });

  @override
  List<Object?> get props => [conversationId, callerId, calleeIds];
}

final class OutgoingCallStatusConsumed extends OutgoingCallEvent {
  const OutgoingCallStatusConsumed();
}
