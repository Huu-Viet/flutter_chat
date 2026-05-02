import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/app_permission.dart';
import 'package:flutter_chat/features/call/export.dart';
import 'package:livekit_client/livekit_client.dart';

part 'in_call_event.dart';
part 'in_call_state.dart';

class InCallBloc extends Bloc<InCallEvent, InCallState> {
  final AcceptIncomingCallUseCase _acceptIncomingCallUseCase;
  final EndCallUseCase _endCallUseCase;
  final CallRepository _callRepository;

  EventsListener<RoomEvent>? _roomListener;
  VoidCallback? _roomRefreshListener;
  final Map<Participant, VoidCallback> _participantListeners = {};

  InCallBloc({
    required AcceptIncomingCallUseCase acceptIncomingCallUseCase,
    required EndCallUseCase endCallUseCase,
    required CallRepository callRepository,
  }) : _acceptIncomingCallUseCase = acceptIncomingCallUseCase,
       _endCallUseCase = endCallUseCase,
       _callRepository = callRepository,
       super(InCallState.initial()) {
    on<InCallOutgoingStarted>(_onOutgoingStarted);
    on<InCallIncomingAccepted>(_onIncomingAccepted);
    on<InCallIncomingDeclined>(_onIncomingDeclined);
    on<InCallRemoteAccepted>(_onRemoteAccepted);
    on<InCallRemoteDeclined>(_onRemoteDeclined);
    on<InCallRemoteEnded>(_onRemoteEnded);
    on<InCallEndRequested>(_onEndRequested);
    on<InCallLeaveRequested>(_onLeaveRequested);
    on<InCallToggleMicrophoneRequested>(_onToggleMicrophoneRequested);
    on<InCallToggleCameraRequested>(_onToggleCameraRequested);
    on<InCallToggleSpeakerRequested>(_onToggleSpeakerRequested);
    on<InCallErrorCleared>(_onErrorCleared);
    on<InCallEndStatusConsumed>(_onEndStatusConsumed);
    on<_InCallRoomChanged>(_onRoomChanged);
    on<_InCallRemoteParticipantLeft>(_onRemoteParticipantLeft);
  }

  void _onOutgoingStarted(
    InCallOutgoingStarted event,
    Emitter<InCallState> emit,
  ) {
    emit(
      state.copyWith(
        session: CallSession(
          call: event.call,
          token: '',
          roomName: '',
          liveKitUrl: '',
          isIncoming: false,
          isGroupCall: event.isGroupCall,
        ),
        isAcceptingCall: false,
        isEndingCall: false,
        isConnectingRoom: false,
        clearError: true,
        clearMediaError: true,
        endStatus: InCallEndStatus.idle,
        clearEndedCallId: true,
      ),
    );
  }

  Future<void> _onIncomingAccepted(
    InCallIncomingAccepted event,
    Emitter<InCallState> emit,
  ) async {
    if (state.isAcceptingCall) return;

    emit(
      state.copyWith(
        isAcceptingCall: true,
        clearError: true,
        clearMediaError: true,
        endStatus: InCallEndStatus.idle,
        clearEndedCallId: true,
      ),
    );

    final result = await _acceptIncomingCallUseCase(event.call.id);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isAcceptingCall: false,
            errorMessage: 'Accept call failed: ${failure.message}',
          ),
        );
      },
      (acceptedCall) async {
        final session = _sessionFromAcceptedCall(
          acceptedCall,
          isIncoming: true,
          isGroupCall: event.isGroupCall,
        );
        emit(
          state.copyWith(
            session: session,
            isAcceptingCall: false,
            isEndingCall: false,
            clearError: true,
            clearMediaError: true,
          ),
        );
        await _connectLiveKitRoom(session, emit);
      },
    );
  }

  Future<void> _onIncomingDeclined(
    InCallIncomingDeclined event,
    Emitter<InCallState> emit,
  ) async {
    final callId = event.callId.trim();
    if (callId.isEmpty) return;

    emit(state.copyWith(isEndingCall: true, clearError: true));
    final result = await _callRepository.declineCall(callId);
    await _callRepository.leaveSocketCall(callId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isEndingCall: false,
          errorMessage: 'Decline call failed: ${failure.message}',
        ),
      ),
      (_) => emit(_endedState(callId)),
    );
  }

  Future<void> _onRemoteAccepted(
    InCallRemoteAccepted event,
    Emitter<InCallState> emit,
  ) async {
    final callId = event.callId.trim();
    if (callId.isEmpty) return;
    if (state.session?.call.id == callId &&
        state.session?.token.isNotEmpty == true) {
      return;
    }

    emit(
      state.copyWith(
        isAcceptingCall: true,
        clearError: true,
        clearMediaError: true,
        endStatus: InCallEndStatus.idle,
        clearEndedCallId: true,
      ),
    );

    await _callRepository.joinSocketCall(callId);
    final call = await _resolveCallInfo(callId);
    if (call == null) {
      emit(
        state.copyWith(
          isAcceptingCall: false,
          errorMessage: 'Join call failed: call record unavailable',
        ),
      );
      return;
    }

    final tokenResult = await _callRepository.getCallToken(callId);
    await tokenResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            isAcceptingCall: false,
            errorMessage: 'Join call failed: ${failure.message}',
          ),
        );
      },
      (token) async {
        final session = CallSession(
          call: call,
          token: token.token,
          roomName: token.roomName,
          liveKitUrl: token.liveKitUrl,
          isIncoming: false,
          isGroupCall: _isGroupCall(call),
        );
        emit(
          state.copyWith(
            session: session,
            isAcceptingCall: false,
            isEndingCall: false,
            clearError: true,
            clearMediaError: true,
          ),
        );
        await _connectLiveKitRoom(session, emit);
      },
    );
  }

  Future<void> _onRemoteDeclined(
    InCallRemoteDeclined event,
    Emitter<InCallState> emit,
  ) async {
    final session = state.session;
    if (session != null &&
        session.call.id == event.callId &&
        session.isGroupCall) {
      return;
    }
    await _finishRemoteCall(event.callId, emit);
  }

  Future<void> _onRemoteEnded(
    InCallRemoteEnded event,
    Emitter<InCallState> emit,
  ) async {
    await _finishRemoteCall(event.callId, emit);
  }

  Future<void> _onEndRequested(
    InCallEndRequested event,
    Emitter<InCallState> emit,
  ) async {
    final session = state.session;
    if (session == null || state.isEndingCall) return;
    if (session.isGroupCall) {
      add(const InCallLeaveRequested());
      return;
    }

    emit(
      state.copyWith(
        isEndingCall: true,
        clearError: true,
        endStatus: InCallEndStatus.idle,
      ),
    );

    final callId = session.call.id.trim();
    if (callId.isEmpty) {
      emit(
        state.copyWith(
          isEndingCall: false,
          errorMessage: 'End call failed: missing call id',
        ),
      );
      return;
    }

    final result = await _endCallUseCase(callId);
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            isEndingCall: false,
            errorMessage: 'End call failed: ${failure.message}',
          ),
        );
      },
      (_) async {
        await _callRepository.leaveSocketCall(callId);
        await _disposeLiveKitRoom();
        emit(_endedState(callId));
      },
    );
  }

  Future<void> _onLeaveRequested(
    InCallLeaveRequested event,
    Emitter<InCallState> emit,
  ) async {
    final session = state.session;
    if (session == null || state.isEndingCall) return;

    final callId = session.call.id.trim();
    if (callId.isEmpty) return;

    emit(
      state.copyWith(
        isEndingCall: true,
        clearError: true,
        endStatus: InCallEndStatus.idle,
      ),
    );

    await _callRepository.leaveSocketCall(callId);
    await _disposeLiveKitRoom();
    emit(_endedState(session.isGroupCall ? null : callId));
  }

  Future<void> _onToggleMicrophoneRequested(
    InCallToggleMicrophoneRequested event,
    Emitter<InCallState> emit,
  ) async {
    final localParticipant = state.room?.localParticipant;
    if (localParticipant == null || state.isMicUpdating) return;

    final enabled = !state.isMicEnabled;
    if (enabled) {
      final hasPermission = await AppPermission.requestVoiceRecordPermission();
      if (!hasPermission) {
        emit(
          state.copyWith(
            mediaErrorMessage: 'Microphone permission is required to unmute.',
          ),
        );
        return;
      }
    }

    emit(state.copyWith(isMicUpdating: true));
    try {
      await localParticipant.setMicrophoneEnabled(enabled);
      final mediaState = _readLocalMediaState(state.room);
      emit(
        state.copyWith(
          isMicEnabled: mediaState.micEnabled,
          isCameraEnabled: mediaState.cameraEnabled,
          isMicUpdating: false,
          clearMediaError: true,
          bumpMediaRevision: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isMicUpdating: false,
          mediaErrorMessage: 'Could not update microphone: $error',
        ),
      );
    }
  }

  Future<void> _onToggleCameraRequested(
    InCallToggleCameraRequested event,
    Emitter<InCallState> emit,
  ) async {
    final localParticipant = state.room?.localParticipant;
    if (localParticipant == null || state.isCameraUpdating) return;

    final enabled = !state.isCameraEnabled;
    if (enabled) {
      final hasPermission = await AppPermission.requestCameraPermission();
      if (!hasPermission) {
        emit(
          state.copyWith(
            mediaErrorMessage:
                'Camera permission is required to turn on video.',
          ),
        );
        return;
      }
    }

    emit(state.copyWith(isCameraUpdating: true));
    try {
      await localParticipant.setCameraEnabled(enabled);
      final mediaState = _readLocalMediaState(state.room);
      emit(
        state.copyWith(
          isMicEnabled: mediaState.micEnabled,
          isCameraEnabled: mediaState.cameraEnabled,
          isCameraUpdating: false,
          clearMediaError: true,
          bumpMediaRevision: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isCameraUpdating: false,
          mediaErrorMessage: 'Could not update camera: $error',
        ),
      );
    }
  }

  Future<void> _onToggleSpeakerRequested(
    InCallToggleSpeakerRequested event,
    Emitter<InCallState> emit,
  ) async {
    final enabled = !state.isSpeakerOn;
    try {
      await Hardware.instance.setSpeakerphoneOn(enabled);
      emit(state.copyWith(isSpeakerOn: enabled));
    } catch (error) {
      emit(
        state.copyWith(mediaErrorMessage: 'Could not update speaker: $error'),
      );
    }
  }

  void _onErrorCleared(InCallErrorCleared event, Emitter<InCallState> emit) {
    if (state.errorMessage == null && state.mediaErrorMessage == null) return;
    emit(state.copyWith(clearError: true, clearMediaError: true));
  }

  void _onEndStatusConsumed(
    InCallEndStatusConsumed event,
    Emitter<InCallState> emit,
  ) {
    if (state.endStatus == InCallEndStatus.idle) return;
    emit(
      state.copyWith(endStatus: InCallEndStatus.idle, clearEndedCallId: true),
    );
  }

  void _onRoomChanged(_InCallRoomChanged event, Emitter<InCallState> emit) {
    final room = state.room;
    if (room == null) return;
    _attachParticipantListeners(room);
    final mediaState = _readLocalMediaState(room);
    emit(
      state.copyWith(
        isMicEnabled: mediaState.micEnabled,
        isCameraEnabled: mediaState.cameraEnabled,
        bumpMediaRevision: true,
      ),
    );
  }

  Future<void> _onRemoteParticipantLeft(
    _InCallRemoteParticipantLeft event,
    Emitter<InCallState> emit,
  ) async {
    final session = state.session;
    final room = state.room;
    if (session == null || room == null) return;

    if (session.isGroupCall || room.remoteParticipants.isNotEmpty) return;

    final callId = session.call.id.trim();
    if (callId.isEmpty) return;

    await _endCallUseCase(callId);
    await _finishRemoteCall(callId, emit);
  }

  Future<void> _finishRemoteCall(
    String callId,
    Emitter<InCallState> emit,
  ) async {
    final normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) return;

    await _callRepository.leaveSocketCall(normalizedCallId);
    await _disposeLiveKitRoom();
    emit(_endedState(normalizedCallId));
  }

  InCallEnded _endedState(String? callId) {
    final normalizedCallId = callId?.trim();
    return InCallEnded(
      endedCallId: normalizedCallId == null || normalizedCallId.isEmpty
          ? null
          : normalizedCallId,
      mediaRevision: state.mediaRevision + 1,
    );
  }

  Future<void> _connectLiveKitRoom(
    CallSession session,
    Emitter<InCallState> emit,
  ) async {
    final token = session.token.trim();
    final liveKitUrl = session.liveKitUrl.trim();
    if (token.isEmpty || liveKitUrl.isEmpty) {
      emit(
        state.copyWith(
          isAcceptingCall: false,
          isConnectingRoom: false,
          mediaErrorMessage: 'Could not join call media: missing LiveKit token',
        ),
      );
      return;
    }

    await _disposeLiveKitRoom();

    emit(
      state.copyWith(
        clearRoom: true,
        isConnectingRoom: true,
        isMicEnabled: true,
        isCameraEnabled: false,
        isSpeakerOn: true,
        isMicUpdating: false,
        isCameraUpdating: false,
        clearMediaError: true,
        bumpMediaRevision: true,
      ),
    );

    final hasMicrophonePermission =
        await AppPermission.requestVoiceRecordPermission();
    if (!hasMicrophonePermission) {
      emit(
        state.copyWith(
          isConnectingRoom: false,
          isMicEnabled: false,
          mediaErrorMessage:
              'Microphone permission is required to join the call.',
        ),
      );
      return;
    }

    final room = Room(roomOptions: const RoomOptions());
    final listener = room.createListener();
    void refreshRoom() => add(const _InCallRoomChanged());

    _roomRefreshListener = refreshRoom;
    room.addListener(refreshRoom);
    listener
      ..on<ParticipantConnectedEvent>((_) => refreshRoom())
      ..on<ParticipantDisconnectedEvent>((event) {
        _removeParticipantListener(event.participant);
        refreshRoom();
        add(const _InCallRemoteParticipantLeft());
      })
      ..on<ActiveSpeakersChangedEvent>((_) => refreshRoom())
      ..on<TrackPublishedEvent>((_) => refreshRoom())
      ..on<TrackUnpublishedEvent>((_) => refreshRoom())
      ..on<LocalTrackPublishedEvent>((_) => refreshRoom())
      ..on<LocalTrackUnpublishedEvent>((_) => refreshRoom())
      ..on<TrackSubscribedEvent>((_) => refreshRoom())
      ..on<TrackUnsubscribedEvent>((_) => refreshRoom())
      ..on<TrackMutedEvent>((_) => refreshRoom())
      ..on<TrackUnmutedEvent>((_) => refreshRoom())
      ..on<ParticipantEvent>((_) => refreshRoom())
      ..on<RoomDisconnectedEvent>((_) => refreshRoom())
      ..on<AudioPlaybackStatusChanged>((_) async {
        if (!room.canPlaybackAudio) {
          await room.startAudio();
        }
      });

    _roomListener = listener;
    _attachParticipantListeners(room);

    try {
      await room.prepareConnection(liveKitUrl, token);
      await room.connect(
        liveKitUrl,
        token,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );
      await room.localParticipant?.setMicrophoneEnabled(true);
      await Hardware.instance.setSpeakerphoneOn(true);
      _attachParticipantListeners(room);
      final mediaState = _readLocalMediaState(room);
      emit(
        state.copyWith(
          room: room,
          isConnectingRoom: false,
          isMicEnabled: mediaState.micEnabled,
          isCameraEnabled: mediaState.cameraEnabled,
          isSpeakerOn: true,
          clearMediaError: true,
          bumpMediaRevision: true,
        ),
      );
    } catch (error) {
      await _disposeRoom(room, listener, refreshRoom);
      _roomListener = null;
      _roomRefreshListener = null;
      if (isClosed) return;
      emit(
        state.copyWith(
          clearRoom: true,
          isConnectingRoom: false,
          isMicUpdating: false,
          isCameraUpdating: false,
          mediaErrorMessage: 'Could not connect call media: $error',
          bumpMediaRevision: true,
        ),
      );
    }
  }

  Future<CallInfo?> _resolveCallInfo(String callId) async {
    final currentCall = state.session?.call;
    if (currentCall != null && currentCall.id.trim() == callId) {
      return currentCall;
    }

    final result = await _callRepository.fetchSingleCallRecord(callId);
    return result.fold((_) => null, (call) => call);
  }

  CallSession _sessionFromAcceptedCall(
    CallAccept acceptedCall, {
    required bool isIncoming,
    required bool isGroupCall,
  }) {
    return CallSession(
      call: acceptedCall.call,
      token: acceptedCall.token,
      roomName: acceptedCall.roomName,
      liveKitUrl: acceptedCall.liveKitUrl,
      isIncoming: isIncoming,
      isGroupCall: isGroupCall || _isGroupCall(acceptedCall.call),
    );
  }

  bool _isGroupCall(CallInfo call) => call.participants.length > 2;

  Future<void> _disposeLiveKitRoom() async {
    final room = state.room;
    final listener = _roomListener;
    final roomRefreshListener = _roomRefreshListener;
    _roomListener = null;
    _roomRefreshListener = null;
    for (final entry in _participantListeners.entries) {
      entry.key.removeListener(entry.value);
    }
    _participantListeners.clear();
    if (room != null && roomRefreshListener != null) {
      await _disposeRoom(room, listener, roomRefreshListener);
      return;
    }
    if (listener != null) {
      await listener.dispose();
    }
  }

  Future<void> _disposeRoom(
    Room room,
    EventsListener<RoomEvent>? listener,
    VoidCallback roomRefreshListener,
  ) async {
    room.removeListener(roomRefreshListener);
    if (listener != null) {
      await listener.dispose();
    }
    await room.disconnect();
    await room.dispose();
  }

  void _attachParticipantListeners(Room room) {
    final participants = <Participant>[
      ...room.remoteParticipants.values,
      if (room.localParticipant != null) room.localParticipant!,
    ];
    final currentParticipants = participants.toSet();
    final staleParticipants = _participantListeners.keys
        .where((participant) => !currentParticipants.contains(participant))
        .toList();
    for (final participant in staleParticipants) {
      _removeParticipantListener(participant);
    }
    for (final participant in participants) {
      if (_participantListeners.containsKey(participant)) continue;
      void listener() {
        if (!isClosed) add(const _InCallRoomChanged());
      }

      participant.addListener(listener);
      _participantListeners[participant] = listener;
    }
  }

  void _removeParticipantListener(Participant participant) {
    final listener = _participantListeners.remove(participant);
    if (listener != null) {
      participant.removeListener(listener);
    }
  }

  _LocalMediaState _readLocalMediaState(Room? room) {
    final localParticipant = room?.localParticipant;
    if (localParticipant == null) {
      return _LocalMediaState(
        micEnabled: state.isMicEnabled,
        cameraEnabled: state.isCameraEnabled,
      );
    }
    return _LocalMediaState(
      micEnabled: _hasActiveLocalAudio(localParticipant),
      cameraEnabled: _hasActiveLocalVideo(localParticipant),
    );
  }

  bool _hasActiveLocalAudio(LocalParticipant participant) {
    for (final publication in participant.audioTrackPublications) {
      if (!publication.muted && publication.subscribed) return true;
    }
    return false;
  }

  bool _hasActiveLocalVideo(LocalParticipant participant) {
    for (final publication in participant.videoTrackPublications) {
      if (publication.isScreenShare) continue;
      if (!publication.muted && publication.subscribed) return true;
    }
    return false;
  }

  @override
  Future<void> close() async {
    await _disposeLiveKitRoom();
    return super.close();
  }
}

class _LocalMediaState {
  final bool micEnabled;
  final bool cameraEnabled;

  const _LocalMediaState({
    required this.micEnabled,
    required this.cameraEnabled,
  });
}
