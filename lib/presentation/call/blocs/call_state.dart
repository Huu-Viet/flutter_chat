part of 'call_bloc.dart';

sealed class CallState extends Equatable {
  const CallState();
}

final class CallInitial extends CallState {
  @override
  List<Object> get props => [];
}

final class CallLoading extends CallState {
  @override
  List<Object> get props => [];
}

final class CallSuccess extends CallState {
  @override
  List<Object> get props => [];
}

final class CallFailure extends CallState {
  final String message;

  const CallFailure(this.message);

  @override
  List<Object> get props => [message];
}
