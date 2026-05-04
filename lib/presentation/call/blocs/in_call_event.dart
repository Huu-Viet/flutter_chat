part of 'in_call_bloc.dart';

sealed class InCallEvent extends Equatable {
  const InCallEvent();

  @override
  List<Object?> get props => [];
}

final class InCallOutgoingStarted extends InCallEvent {
  final CallInfo call;
  final bool isGroupCall;

  const InCallOutgoingStarted(this.call, {this.isGroupCall = false});

  @override
  List<Object?> get props => [call, isGroupCall];
}

final class InCallIncomingAccepted extends InCallEvent {
  final CallInfo call;
  final bool isGroupCall;

  const InCallIncomingAccepted(this.call, {this.isGroupCall = false});

  @override
  List<Object?> get props => [call, isGroupCall];
}

final class InCallIncomingDeclined extends InCallEvent {
  final String callId;

  const InCallIncomingDeclined(this.callId);

  @override
  List<Object?> get props => [callId];
}

final class InCallRejoinRequested extends InCallEvent {
  final CallInfo call;
  final String roomName;

  const InCallRejoinRequested(this.call, {this.roomName = ''});

  @override
  List<Object?> get props => [call, roomName];
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

final class InCallLeaveRequested extends InCallEvent {
  const InCallLeaveRequested();
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
  /// True when the change was caused by a track or participant event that
  /// requires the video stage to re-render. False for local mic/camera or
  /// generic room events that do not affect remote video tiles.
  final bool videoChanged;
  const _InCallRoomChanged({this.videoChanged = false});

  @override
  List<Object?> get props => [videoChanged];
}

final class _InCallRemoteParticipantLeft extends InCallEvent {
  const _InCallRemoteParticipantLeft();
}
