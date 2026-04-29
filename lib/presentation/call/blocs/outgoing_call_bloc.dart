import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/features/call/export.dart';

part 'outgoing_call_event.dart';
part 'outgoing_call_state.dart';

class OutgoingCallBloc extends Bloc<OutgoingCallEvent, OutgoingCallState> {
  final StartOutgoingCallUseCase _startOutgoingCallUseCase;

  OutgoingCallBloc({required StartOutgoingCallUseCase startOutgoingCallUseCase})
    : _startOutgoingCallUseCase = startOutgoingCallUseCase,
      super(OutgoingCallState.initial()) {
    on<OutgoingCallRequested>(_onRequested);
    on<OutgoingCallStatusConsumed>(_onStatusConsumed);
  }

  Future<void> _onRequested(
    OutgoingCallRequested event,
    Emitter<OutgoingCallState> emit,
  ) async {
    if (state.isStarting) return;

    emit(
      state.copyWith(
        status: OutgoingCallStatus.loading,
        clearError: true,
        clearCall: true,
      ),
    );

    final result = await _startOutgoingCallUseCase(
      conversationId: event.conversationId,
      callerId: event.callerId,
      receiverId: event.receiverId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OutgoingCallStatus.failure,
          errorMessage: 'Start call failed: ${failure.message}',
        ),
      ),
      (call) => emit(
        state.copyWith(
          status: OutgoingCallStatus.success,
          call: call,
          clearError: true,
        ),
      ),
    );
  }

  void _onStatusConsumed(
    OutgoingCallStatusConsumed event,
    Emitter<OutgoingCallState> emit,
  ) {
    if (state.status == OutgoingCallStatus.idle) return;
    emit(
      state.copyWith(
        status: OutgoingCallStatus.idle,
        clearError: true,
        clearCall: true,
      ),
    );
  }
}
