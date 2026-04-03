part of 'call_bloc.dart';

sealed class CallEvent extends Equatable {
  const CallEvent();
}

final class CallStarted extends CallEvent {
  final String deviceToken;

  const CallStarted(this.deviceToken);

  @override
  List<Object> get props => [deviceToken];
}
