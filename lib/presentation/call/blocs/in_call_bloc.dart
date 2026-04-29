import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/call/export.dart';

part 'in_call_event.dart';
part 'in_call_state.dart';

class InCallBloc extends Bloc<InCallEvent, InCallState> {
  final EndCallUseCase _endCallUseCase;
  final CallRepository _callRepository;

  InCallBloc({
    required EndCallUseCase endCallUseCase,
    required CallRepository callRepository,
  }) : _endCallUseCase = endCallUseCase,
       _callRepository = callRepository,
       super(InCallState.initial()) {
    on<InCallSessionChanged>(_onSessionChanged);
    on<InCallEndRequested>(_onEndRequested);
    on<InCallErrorCleared>(_onErrorCleared);
    on<InCallEndStatusConsumed>(_onEndStatusConsumed);
  }

  void _onSessionChanged(
    InCallSessionChanged event,
    Emitter<InCallState> emit,
  ) {
    emit(
      state.copyWith(
        session: event.session,
        isEndingCall: false,
        clearError: true,
        endStatus: InCallEndStatus.idle,
      ),
    );
  }

  Future<void> _onEndRequested(
    InCallEndRequested event,
    Emitter<InCallState> emit,
  ) async {
    final session = state.session;
    if (session == null || state.isEndingCall) return;

    emit(
      state.copyWith(
        isEndingCall: true,
        clearError: true,
        endStatus: InCallEndStatus.idle,
      ),
    );

    final callId = session.call.id;
    if (callId.trim().isEmpty) {
      emit(
        state.copyWith(
          isEndingCall: false,
          errorMessage: 'End call failed: missing call id',
          endStatus: InCallEndStatus.idle,
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
            endStatus: InCallEndStatus.idle,
          ),
        );
      },
      (_) async {
        await _callRepository.leaveSocketCall(callId);
        emit(
          state.copyWith(
            clearSession: true,
            isEndingCall: false,
            clearError: true,
            endStatus: InCallEndStatus.success,
          ),
        );
      },
    );
  }

  void _onErrorCleared(InCallErrorCleared event, Emitter<InCallState> emit) {
    if (state.errorMessage == null) return;
    emit(state.copyWith(clearError: true));
  }

  void _onEndStatusConsumed(
    InCallEndStatusConsumed event,
    Emitter<InCallState> emit,
  ) {
    if (state.endStatus == InCallEndStatus.idle) return;
    emit(state.copyWith(endStatus: InCallEndStatus.idle));
  }
}
