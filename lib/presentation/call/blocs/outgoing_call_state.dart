part of 'outgoing_call_bloc.dart';

enum OutgoingCallStatus { idle, loading, success, failure }

final class OutgoingCallState extends Equatable {
  final OutgoingCallStatus status;
  final CallInfo? call;
  final String? errorMessage;
  final bool isGroupCall;

  const OutgoingCallState({
    this.status = OutgoingCallStatus.idle,
    this.call,
    this.errorMessage,
    this.isGroupCall = false,
  });

  factory OutgoingCallState.initial() => const OutgoingCallState();

  bool get isStarting => status == OutgoingCallStatus.loading;

  OutgoingCallState copyWith({
    OutgoingCallStatus? status,
    CallInfo? call,
    bool clearCall = false,
    String? errorMessage,
    bool clearError = false,
    bool? isGroupCall,
  }) {
    return OutgoingCallState(
      status: status ?? this.status,
      call: clearCall ? null : (call ?? this.call),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isGroupCall: isGroupCall ?? this.isGroupCall,
    );
  }

  @override
  List<Object?> get props => [status, call, errorMessage, isGroupCall];
}
