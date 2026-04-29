part of 'in_call_bloc.dart';

enum InCallEndStatus {
  idle,
  success,
}

final class InCallState extends Equatable {
  final CallSession? session;
  final bool isEndingCall;
  final String? errorMessage;
  final InCallEndStatus endStatus;

  const InCallState({
    required this.session,
    this.isEndingCall = false,
    this.errorMessage,
    this.endStatus = InCallEndStatus.idle,
  });

  factory InCallState.initial() => const InCallState(session: null);

  InCallState copyWith({
    CallSession? session,
    bool clearSession = false,
    bool? isEndingCall,
    String? errorMessage,
    bool clearError = false,
    InCallEndStatus? endStatus,
  }) {
    return InCallState(
      session: clearSession ? null : (session ?? this.session),
      isEndingCall: isEndingCall ?? this.isEndingCall,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      endStatus: endStatus ?? this.endStatus,
    );
  }

  @override
  List<Object?> get props => [session, isEndingCall, errorMessage, endStatus];
}
