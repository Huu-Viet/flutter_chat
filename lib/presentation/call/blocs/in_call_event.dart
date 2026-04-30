part of 'in_call_bloc.dart';

sealed class InCallEvent extends Equatable {
  const InCallEvent();

  @override
  List<Object?> get props => [];
}

final class InCallOutgoingStarted extends InCallEvent {
  final CallInfo call;

  const InCallOutgoingStarted(this.call);

  @override
  List<Object?> get props => [call];
}

final class InCallIncomingAccepted extends InCallEvent {
  final CallInfo call;

  const InCallIncomingAccepted(this.call);

  @override
  List<Object?> get props => [call];
}

final class InCallIncomingDeclined extends InCallEvent {
  final String callId;

  const InCallIncomingDeclined(this.callId);

  @override
  List<Object?> get props => [callId];
}

final class InCallRemoteAccepted extends InCallEvent {
  final String callId;

  const InCallRemoteAccepted(this.callId);

  @override
  List<Object?> get props => [callId];
}

final class InCallRemoteDeclined extends InCallEvent {
  final String callId;

  const InCallRemoteDeclined(this.callId);

  @override
  List<Object?> get props => [callId];
}

final class InCallRemoteEnded extends InCallEvent {
  final String callId;

  const InCallRemoteEnded(this.callId);

  @override
  List<Object?> get props => [callId];
}

final class InCallEndRequested extends InCallEvent {
  const InCallEndRequested();
}

final class InCallToggleMicrophoneRequested extends InCallEvent {
  const InCallToggleMicrophoneRequested();
}

final class InCallToggleCameraRequested extends InCallEvent {
  const InCallToggleCameraRequested();
}

final class InCallToggleSpeakerRequested extends InCallEvent {
  const InCallToggleSpeakerRequested();
}

final class InCallErrorCleared extends InCallEvent {
  const InCallErrorCleared();
}

final class InCallEndStatusConsumed extends InCallEvent {
  const InCallEndStatusConsumed();
}

final class _InCallRoomChanged extends InCallEvent {
  const _InCallRoomChanged();
}

final class _InCallRemoteParticipantLeft extends InCallEvent {
  const _InCallRemoteParticipantLeft();
}
