import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc() : super(CallInitial()) {
    // on<CallStarted>(_onCallStarted);
  }

  // Future<void> _onCallStarted(CallStarted event, Emitter<CallState> emit) async {
  //   emit(CallLoading());
  //
  //   try {
  //     await _sendCallRequestUseCase(event.deviceToken, "test message", "test_channel_id");
  //   } on Exception catch (e) {
  //     emit(CallFailure(e.toString()));
  //   }
  // }
}
