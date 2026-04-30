part of 'in_call_bloc.dart';

enum InCallEndStatus { idle, success }

final class InCallState extends Equatable {
  final CallSession? session;
  final Room? room;
  final bool isAcceptingCall;
  final bool isEndingCall;
  final bool isConnectingRoom;
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final bool isSpeakerOn;
  final bool isMicUpdating;
  final bool isCameraUpdating;
  final String? errorMessage;
  final String? mediaErrorMessage;
  final InCallEndStatus endStatus;
  final String? endedCallId;
  final int mediaRevision;

  const InCallState({
    required this.session,
    this.room,
    this.isAcceptingCall = false,
    this.isEndingCall = false,
    this.isConnectingRoom = false,
    this.isMicEnabled = true,
    this.isCameraEnabled = false,
    this.isSpeakerOn = true,
    this.isMicUpdating = false,
    this.isCameraUpdating = false,
    this.errorMessage,
    this.mediaErrorMessage,
    this.endStatus = InCallEndStatus.idle,
    this.endedCallId,
    this.mediaRevision = 0,
  });

  factory InCallState.initial() => const InCallState(session: null);

  bool get hasSession => session != null;

  InCallState copyWith({
    CallSession? session,
    bool clearSession = false,
    Room? room,
    bool clearRoom = false,
    bool? isAcceptingCall,
    bool? isEndingCall,
    bool? isConnectingRoom,
    bool? isMicEnabled,
    bool? isCameraEnabled,
    bool? isSpeakerOn,
    bool? isMicUpdating,
    bool? isCameraUpdating,
    String? errorMessage,
    bool clearError = false,
    String? mediaErrorMessage,
    bool clearMediaError = false,
    InCallEndStatus? endStatus,
    String? endedCallId,
    bool clearEndedCallId = false,
    int? mediaRevision,
    bool bumpMediaRevision = false,
  }) {
    return InCallState(
      session: clearSession ? null : (session ?? this.session),
      room: clearRoom ? null : (room ?? this.room),
      isAcceptingCall: isAcceptingCall ?? this.isAcceptingCall,
      isEndingCall: isEndingCall ?? this.isEndingCall,
      isConnectingRoom: isConnectingRoom ?? this.isConnectingRoom,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isMicUpdating: isMicUpdating ?? this.isMicUpdating,
      isCameraUpdating: isCameraUpdating ?? this.isCameraUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mediaErrorMessage: clearMediaError
          ? null
          : (mediaErrorMessage ?? this.mediaErrorMessage),
      endStatus: endStatus ?? this.endStatus,
      endedCallId: clearEndedCallId ? null : (endedCallId ?? this.endedCallId),
      mediaRevision: bumpMediaRevision
          ? this.mediaRevision + 1
          : (mediaRevision ?? this.mediaRevision),
    );
  }

  @override
  List<Object?> get props => [
    session,
    room,
    isAcceptingCall,
    isEndingCall,
    isConnectingRoom,
    isMicEnabled,
    isCameraEnabled,
    isSpeakerOn,
    isMicUpdating,
    isCameraUpdating,
    errorMessage,
    mediaErrorMessage,
    endStatus,
    endedCallId,
    mediaRevision,
  ];
}

final class InCallEnded extends InCallState {
  const InCallEnded({super.endedCallId, super.mediaRevision = 0})
    : super(
        session: null,
        room: null,
        isAcceptingCall: false,
        isEndingCall: false,
        isConnectingRoom: false,
        isMicEnabled: false,
        isCameraEnabled: false,
        isSpeakerOn: true,
        isMicUpdating: false,
        isCameraUpdating: false,
        errorMessage: null,
        mediaErrorMessage: null,
        endStatus: InCallEndStatus.success,
      );
}
